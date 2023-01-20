//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Aleksandr Kornjushko on 25.11.2022.
//

import os
import UIKit
import CoreData
import Combine
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  // background concurrent scheduler
  private lazy var scheduler: AnyDispatchQueueScheduler = DispatchQueue(
    label: "com.ak.sfod.EssentialFeed.queue",
    qos:  .userInitiated,
    attributes: .concurrent
  ).eraseToAnyScheduler()
  
  private lazy var httpClient: HTTPClient = {
    URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
  }()

  // default Apple logging library. requires 'import os'
  private lazy var logger = Logger(subsystem: "com.ak.sfod.EssentialApp", category: "main")

  private lazy var store: FeedStore & FeedImageDataStore = {
    do {
      return try CoreDataFeedStore(
        storeURL: NSPersistentContainer
          .defaultDirectoryURL()
          .appendingPathComponent("feed-store.sqlite"))
    } catch {
      assertionFailure("Failed to instantiate CoreData store with error \(error.localizedDescription)")
      logger.fault("Failed to instantiate CoreData store with error \(error.localizedDescription)")
      return NullStore()
    }
  }()

  private lazy var baseURL: URL = {
    return URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
  }()

  private lazy var remoteFeedLoader = httpClient.getPublisher(url: baseURL).tryMap(FeedItemsMapper.map)

  private lazy var localFeedLoader = {
    LocalFeedLoader(store: store, currentDate: Date.init)
  }()

  private lazy var  navigationController = UINavigationController(
    rootViewController: FeedUIComposer.feedComposedWith(
      feedLoader: makeRemoteFeedLoaderWithLocalFallBack,
      imageLoader: makeLocalImageLoaderWithRemoteFallback,
      selection: showComments))

  convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore, scheduler: AnyDispatchQueueScheduler) {
    self.init()
    self.httpClient = httpClient
    self.store = store
    self.scheduler = scheduler
  }

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let scene = (scene as? UIWindowScene) else { return }

    window = UIWindow(windowScene: scene)
    configureWindow()
  }

  func configureWindow() {
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()
  }

  func sceneWillResignActive(_ scene: UIScene) {
    do {
      try localFeedLoader.validateCache()
    } catch {
      logger.error("Failed to validate cache with error: \(error.localizedDescription)")
    }
  }

  // SceneDelegate listen to the event when an image is selected
  private func showComments(for image: FeedImage) {
    // creates the URL
    let url = ImageCommentsEndpoint.get(image.id).url(baseURL: baseURL)

    // and present it in the navigationController
    let comments = CommentsUIComposer.commentsComposedWith(commentsLoader: makeRemoteCommentsLoader(url: url))
    navigationController.pushViewController(comments, animated: true)
  }

  // should return a function that takes nothing and return 'Publisher'
  private func makeRemoteCommentsLoader(url: URL) -> () -> AnyPublisher<[ImageComment], Error> {
    return { [httpClient] in
      return httpClient
        .getPublisher(url: url)
        .tryMap(ImageCommentsMapper.map)
        .eraseToAnyPublisher()
    }
  }

  private func makeRemoteFeedLoaderWithLocalFallBack() -> AnyPublisher<Paginated<FeedImage>, Error> {
    makeRemoteFeedLoader()
    // [ side-effect ]
      .caching(to: localFeedLoader) // [     caching     ]
      .fallback(to: localFeedLoader.loadPublisher)
      .map(makeFirstPage)
      .subscribe(on: scheduler)
      .eraseToAnyPublisher()
  }

  // we need to call this method recursively
  // not to keeping items in memory
  private func makeRemoteLoadMoreLoader(last: FeedImage?) -> AnyPublisher<Paginated<FeedImage>, Error> {
    // makeRemoteLoadMoreLoader it creates a remote feed loader after the last item
    // 1)) load first from the cache
    localFeedLoader.loadPublisher()
    // 7) another way to do mentioned steps is to use 'zip publisher'
    // 2)) and then from the feed loader
      .zip(makeRemoteFeedLoader(after: last))
//    // every time we need a new 'items' we can load them from the cache
//    // we receive newItems from 'makeRemoteFeedLoader' after last item
//    // 2) then we load the cache
//      .flatMap({ [localFeedLoader] newItems in
//        // load publisher from the local feed loader which is the cache and 'map' 'cachedItems' that we receive from the 'localFeedLoader'
//        // 3) we get 'result' of the 'newItems' and the 'cache'
//        localFeedLoader.loadPublisher().map { cachedItems in
//          // and here we can return 'newItems'
//          // 4) and we combine them into a tuple
//          (newItems, cachedItems)
//        }
//      })
//    // it gets the new items
//    // 5) we are going to have a tuple of 'newItems'
      .map { (cachedItems, newItems) in
        // and combine
        // we append the 'lastItems(items)' with the 'newItems'
        // and keep appending all the elements until 'newItems' is empty which means we reached the end of the pagination
        // 6) and we can combine 'cachedItems' with 'newItems'
        (cachedItems + newItems, newItems.last)
      }
    // then makes a page
      .map(makePage)
    // only for testing purpose
      /*.delay(for: 2, scheduler: DispatchQueue.main)*/ // thats how we can test and make sure in builded app that spinner is shown when new page is loading
      /*.flatMap({ _ in
        Fail(error: NSError())
      })*/ // thats how we can test and make sure that error appears if loading is failed
      .caching(to: localFeedLoader)
      .subscribe(on: scheduler)
      .eraseToAnyPublisher()
  }

  // we need to call this method recursively
  private func makeRemoteFeedLoader(after: FeedImage? = nil) -> AnyPublisher<[FeedImage], Error> {
    let url = FeedEndpoint.get(after: after).url(baseURL: baseURL)

    // wrapping the load function into Combine
    // [ side-effect ]
    // 2. and we load again.
    return httpClient
      .getPublisher(url: url) // [ network request ]
    // -pure function-
      .tryMap(FeedItemsMapper.map)  // -     mapping     -
      .eraseToAnyPublisher()
  }

  private func makeFirstPage(items: [FeedImage]) -> Paginated<FeedImage> {
    makePage(items: items, last: items.last)
  }

  private func makePage(items: [FeedImage], last: FeedImage?)-> Paginated<FeedImage> {
    // only create this 'loadMorePublisher' if have a last item in the items
    // 1. we load the first items
    // and here we calling recursively the same function
    Paginated(items: items,
              // when loading a new page last items is a 'newItems.last', because 'lastItem' can be empty and if 'newItems' is empty it means we reached the end
              loadMorePublisher: last.map { last in
      { self.makeRemoteLoadMoreLoader(last: last) }
    })
  }

  private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
    // 3. we can decorate specific instances, for example if we want to monitor only image request
    // when we loading an image we also create decorated instance
//    let client = HTTPClientProfilingDecorator(decoratee: httpClient, logger: logger) // 4
    let localImageLoader = LocalFeedImageDataLoader(store: store)

    return localImageLoader
      .loadImageDataPublisher(from: url)
//      .logCacheMisses(url: url, logger: logger)
//      .fallback(to: { [logger] in // 4
      .fallback(to: { [httpClient/*, logger*/, scheduler] in
        // 4. we can use 'logger' into 'Publishers' chain with '.handleEvents' and we dont need to decorate the client anymore
//        var startTime = CACurrentMediaTime() // 4

        httpClient
          .getPublisher(url: url)
//          .logErrors(url: url, logger: logger)
//          .logElapsedTime(url: url, logger: logger)
          .tryMap(FeedImageDataMapper.map)
          .caching(to: localImageLoader, using: url)
          .subscribe(on: scheduler)
          .eraseToAnyPublisher()
      })
    // 'subscribe(on)' 'publisher' allows us to execute work in any provided 'scheduler', in this case 'DispatchQueue.global()' which is concurrent queue ('concurrent' - it will choose whatever thread is idle and run the operation concurrently)
    // if our component is not thread safe we need to always execute operations in a serial 'scheduler' or 'queue' (like created in the beginning of file)
    // 'subscribe(on)' is affecting everything what is executed above it - 'upstream'. but the 'results' when its done will be 'dispatched' with 'DispatchQueue.main'
      .subscribe(on: scheduler)
      .eraseToAnyPublisher()
  }
}

// Combine way to inject logging(or any other) behaviour into the chain
extension Publisher {
  func logCacheMisses(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
     return handleEvents(
      receiveCompletion: { result in
      if case .failure = result {
        logger.trace("Cache miss for url: \(url)")
      }
     }).eraseToAnyPublisher()
  }

  func logErrors(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
     return handleEvents(
      receiveCompletion: { result in
      if case let .failure(error) = result {
        logger.trace("Failed to load url: \(url) with error: \(error.localizedDescription)")
      }
     }).eraseToAnyPublisher()
  }

  func logElapsedTime(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
    var startTime = CACurrentMediaTime()

    return handleEvents(
      receiveSubscription: { _ in
        logger.trace("Started loading url: \(url)")
        startTime = CACurrentMediaTime()
      },
      receiveCompletion: { result in
        let elapsed = CACurrentMediaTime() - startTime
        logger.trace("Finished loading url: \(url) in \(elapsed) seconds")
      }).eraseToAnyPublisher()
  }
}


// 4
/*
// with 'decorator pattern' we can 'inject' the 'logging' by 'decorating' an HTTPClient
// decorator(HTTPClientProfilingDecorator) implements same interface as decoratee(HTTPClient)
private class HTTPClientProfilingDecorator: HTTPClient {
  private let decoratee: HTTPClient
  private let logger: Logger

  public init(decoratee: HTTPClient, logger: Logger) {
    self.decoratee = decoratee
    self.logger = logger
  }

  func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
    // 2. now we 'can add' more 'behaviour' to this 'class' for example we 'can add logging'
    logger.trace("Started loading url: \(url)")

    // 1. simply 'forwarding' the 'message' to the 'decoratee' and doing 'nothing'
    let startTime = CACurrentMediaTime()
    return decoratee.get(from: url) { [logger] result in
      if case let .failure(error) = result {
        logger.trace("Failed to load url: \(url) with error: \(error.localizedDescription)")
      }
      let elapsed = CACurrentMediaTime() - startTime
      logger.trace("Finished loading url: \(url) in \(elapsed) seconds")

      completion(result)
    }
  }
}
*/
