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
    try! CoreDataFeedStore(
      storeURL: NSPersistentContainer
      .defaultDirectoryURL()
      .appendingPathComponent("feed-store.sqlite"))
  }()

  private lazy var localFeedLoader =  {
    LocalFeedLoader(store: store, currentDate: Date.init)
  }()

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
    window?.rootViewController = UINavigationController(
      rootViewController: FeedUIComposer.feedComposedWith(
      feedLoader: makeRemoteFeedLoaderWithLocalFallBack,
      imageLoader: makeLocalImageLoaderWithRemoteFallback))
    window?.makeKeyAndVisible()
  }

  func sceneWillResignActive(_ scene: UIScene) {
    localFeedLoader.validateCache { _ in }
  }

  private func makeRemoteFeedLoaderWithLocalFallBack() -> FeedLoader.Publisher {
    let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!

    let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: httpClient)

    // wrapping the load function into Combine
    return remoteFeedLoader
      .loadPublisher()
      .caching(to: localFeedLoader)
      .fallback(to: localFeedLoader.loadPublisher)
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

public extension FeedImageDataLoader {
  typealias Publisher = AnyPublisher<Data, Error>

  func loadImageDataPublisher(from url: URL) -> Publisher {
    var task: FeedImageDataLoaderTask?

    return Deferred {
      Future { completion in
        // hold reference to task
        task = self.loadImageData(from: url, completion: completion)
      }
    }
    // and if we receive a cancel event - we cancel the task
    // we are using '.handleEvents' to inject a side-effect into the chain (here side-effect if there is a cancel event - cancel the running task)
    .handleEvents(receiveCancel: { task?.cancel() })
    .eraseToAnyPublisher()
  }
}

extension Publisher where Output == Data {
  func caching(to cache: FeedImageDataCache, using url: URL) -> AnyPublisher<Output, Failure> {
    // injecting side effect into the chain
    handleEvents(receiveOutput: { data in
      cache.saveIgnoringResult(data, for: url)
    }).eraseToAnyPublisher()
  }
}

private extension FeedImageDataCache {
  func saveIgnoringResult(_ data: Data, for url: URL) {
    save(data, for: url) { _ in }
  }
}

public extension FeedLoader {
  // Future will be fired instantly once the 'makeRemoteFeedLoaderWithLocalFallBack' is called
  // if we want to fire request only when someone subscribes to it, not on creation of the Publisher, so one way we can defer the execution of the Future is to wrap it into a 'Deferred' publisher
//    return Deferred {
//      Future { completion in
//        remoteFeedLoader.load(completion: completion)
//      }
    // since the types match between RemoteFeedLoader completion block and Future completion block we can just pass the load function for the completion

  // wrapping the load function into Combine Publishers
  typealias Publisher = AnyPublisher<[FeedImage], Error>

  func loadPublisher() -> Publisher {
    return Deferred {
      Future(self.load)
    }
    .eraseToAnyPublisher()
  }
}

extension Publisher {
  func fallback(to fallbackPublisher: @escaping() -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
    // 'self' is the primary and 'fallbackPublisher' is the fallback
    self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
  }
}

extension Publisher where Output == [FeedImage] {
  func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
    handleEvents(receiveOutput: cache.saveIgnoringResult).eraseToAnyPublisher()
  }
}

private extension FeedCache {
  // we dont care about result
  func saveIgnoringResult(_ feed: [FeedImage]) {
    save(feed) { _ in }
  }
}

extension Publisher {
  func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
    receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
  }
}

extension DispatchQueue {

  static var immediateWhenOnMainQueueScheduler: ImmediateWhenOnMainQueueScheduler {
    ImmediateWhenOnMainQueueScheduler()
  }

  struct ImmediateWhenOnMainQueueScheduler: Scheduler {
    typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
    typealias SchedulerOptions = DispatchQueue.SchedulerOptions

    var now: SchedulerTimeType {
      DispatchQueue.main.now
    }

    var minimumTolerance: SchedulerTimeType.Stride {
      DispatchQueue.main.minimumTolerance
    }

    func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
      guard Thread.isMainThread else {
        return DispatchQueue.main.schedule(options: options, action)
      }

      action()
    }

    func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
      DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
    }

    func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
      DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
    }
  }
}
