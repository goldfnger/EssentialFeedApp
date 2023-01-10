//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Aleksandr Kornjushko on 25.11.2022.
//

import UIKit
import CoreData
import Combine
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  
  private lazy var httpClient: HTTPClient = {
    URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
  }()

  private lazy var store: FeedStore & FeedImageDataStore = {
    do {
      return try CoreDataFeedStore(
        storeURL: NSPersistentContainer
          .defaultDirectoryURL()
          .appendingPathComponent("feed-store.sqlite"))
    } catch {
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

  convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
    self.init()
    self.httpClient = httpClient
    self.store = store
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
    localFeedLoader.validateCache { _ in }
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
        // then makes a page
      }.map(makePage)
    // only for testing purpose
      /*.delay(for: 2, scheduler: DispatchQueue.main)*/ // thats how we can test and make sure in builded app that spinner is shown when new page is loading
      /*.flatMap({ _ in
        Fail(error: NSError())
      })*/ // thats how we can test and make sure that error appears if loading is failed
      .caching(to: localFeedLoader)
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
    let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
    let localImageLoader = LocalFeedImageDataLoader(store: store)

    return localImageLoader
      .loadImageDataPublisher(from: url)
      .fallback(to: {
        remoteImageLoader
        .loadImageDataPublisher(from: url)
        .caching(to: localImageLoader, using: url)
      })
  }
}
