//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Aleksandr Kornjushko on 04.11.2022.
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public final class FeedUIComposer {
  private init() { }

  public static func feedComposedWith(
    feedLoader: @escaping() -> AnyPublisher<[FeedImage], Error>,
    imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher
  ) -> ListViewController {
    // when we loading the feed using generic:
    // Resource = [FeedImage] and the View = FeedViewAdapter
    // we moved type definition to the one level above which makes LoadResourcePresentationAdapter generic over the Resource and the ResourceView
    let presentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>(loader: feedLoader)

    let feedController = makeFeedViewController(
      delegate: presentationAdapter,
      title: FeedPresenter.title)

    presentationAdapter.presenter = LoadResourcePresenter(
      resourceView: FeedViewAdapter(controller: feedController,
                                imageLoader: imageLoader),
      loadingView: WeakRefVirtualProxy(feedController),
      errorView: WeakRefVirtualProxy(feedController),
      mapper: FeedPresenter.map)

    return feedController
  }

  private static func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> ListViewController {
    let bundle = Bundle(for: ListViewController.self)
    let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
    let feedController = storyboard.instantiateInitialViewController() as! ListViewController
    feedController.delegate = delegate
    feedController.title = title
    return feedController
  }
}
