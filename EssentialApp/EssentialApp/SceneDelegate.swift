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

  private var remoteURL: URL = {
    return URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
  }()

  private lazy var remoteFeedLoader = httpClient.getPublisher(url: remoteURL).tryMap(FeedItemsMapper.map)

  private lazy var localFeedLoader = {
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

  private func makeRemoteFeedLoaderWithLocalFallBack() -> AnyPublisher<[FeedImage], Error> {
    // wrapping the load function into Combine
    // [ side-effect ]
    return httpClient
      .getPublisher(url: remoteURL) // [ network request ]
    // -pure function-
      .tryMap(FeedItemsMapper.map)  // -     mapping     -
    // [ side-effect ]
      .caching(to: localFeedLoader) // [     caching     ]
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
