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
    let url = FeedEndpoint.get().url(baseURL: baseURL)

    // wrapping the load function into Combine
    // [ side-effect ]
    return httpClient
      .getPublisher(url: url) // [ network request ]
    // -pure function-
      .tryMap(FeedItemsMapper.map)  // -     mapping     -
    // [ side-effect ]
      .caching(to: localFeedLoader) // [     caching     ]
      .fallback(to: localFeedLoader.loadPublisher)
    // we get an array of items and we just wrap it in a paginated which does nothing
      .map { items in
        // only create this 'loadMorePublisher' if have a last item in the items
        // 1. we load the first items
        Paginated(items: items, loadMorePublisher:
                    self.makeRemoteLoadMoreLoader(items: items, last: items.last))
      }
      .eraseToAnyPublisher()
  }

  // we need to call this method recursively
  private func makeRemoteLoadMoreLoader(items: [FeedImage], last: FeedImage?) -> (() -> AnyPublisher<Paginated<FeedImage>, Error>)? {
    last.map { lastItem in
      let url = FeedEndpoint.get(after: lastItem).url(baseURL: baseURL)

      // 2. and we load again
      return  { [httpClient] in
        httpClient
          .getPublisher(url: url)
          .tryMap(FeedItemsMapper.map)
          .map { newItems in
            // we append the 'lastItems(items)' with the 'newItems'
            // and keep appending all the elements until 'newItems' is empty which means we reached the end of the pagination
            let allItems = items + newItems
            // and here we calling recursively the same function
            return Paginated(items: allItems,
                             // when loading a new page last items is a 'newItems.last', because lastItem can be empty and if newItems is empty it means we reached the end
                             loadMorePublisher: self.makeRemoteLoadMoreLoader(items: allItems, last: newItems.last))
          }.eraseToAnyPublisher()
      }
    }
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
