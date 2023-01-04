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

  private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>

  public static func feedComposedWith(
    feedLoader: @escaping() -> AnyPublisher<Paginated<FeedImage>, Error>,
    imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
    selection: @escaping (FeedImage) -> Void = { _ in }
  ) -> ListViewController {
    // when we loading the feed using generic:
    // Resource = [FeedImage] and the View = FeedViewAdapter
    // we moved type definition to the one level above which makes LoadResourcePresentationAdapter generic over the Resource and the ResourceView
    let presentationAdapter = FeedPresentationAdapter(loader: feedLoader)

    let feedController = makeFeedViewController(title: FeedPresenter.title)
    feedController.onRefresh = presentationAdapter.loadResource
    
    presentationAdapter.presenter = LoadResourcePresenter(
      resourceView: FeedViewAdapter(controller: feedController,
                                    imageLoader: imageLoader,
                                    selection: selection),
      loadingView: WeakRefVirtualProxy(feedController),
      errorView: WeakRefVirtualProxy(feedController),
      // pass directly so the feed view adapter we get the paginated feed image as the view model
      mapper: { $0 })

    return feedController
  }

  private static func makeFeedViewController(title: String) -> ListViewController {
    let bundle = Bundle(for: ListViewController.self)
    let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
    let feedController = storyboard.instantiateInitialViewController() as! ListViewController
    feedController.title = title
    return feedController
  }
}
