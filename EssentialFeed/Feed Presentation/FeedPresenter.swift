//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 21.11.2022.
//

import Foundation

public protocol FeedView {
  func display(_ viewModel: FeedViewModel)
}

public protocol FeedLoadingView {
  func display(_ viewModel: FeedLoadingViewModel)
}

public protocol FeedErrorView {
  func display(_ viewModel: FeedErrorViewModel)
}

public final class FeedPresenter {
  private let feedView: FeedView
  private let loadingView: FeedLoadingView
  private let errorView: FeedErrorView

  public init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
    self.feedView = feedView
    self.loadingView = loadingView
    self.errorView = errorView
  }

  public static var title: String {
    return NSLocalizedString("FEED_VIEW_TITLE",
                             tableName: "Feed",
                             bundle: Bundle(for: FeedPresenter.self),
                             comment: "Title for the feed view")
  }

  private var feedLoadError: String {
     return NSLocalizedString("GENERIC_CONNECTION_ERROR",
        tableName: "Shared",
        bundle: Bundle(for: FeedPresenter.self),
        comment: "Error message displayed when we can't load the image feed from the server")
   }

  // data in -> creates view models -> data out to the UI

  // Void -> creates view models -> sends to the UI
  public func didStartLoadingFeed() {
    errorView.display(.noError)
    loadingView.display(FeedLoadingViewModel(isLoading: true))
  }

  // [FeedImage] -> creates view models -> sends to the UI
  // [ImageComment] -> creates view models -> sends to the UI
  // Data -> UIImage -> send to the UI
  
  // Resource -> create ResourceViewModel -> sends to the UI
  public func didFinishLoadingFeed(with feed: [FeedImage]) {
    feedView.display(FeedViewModel(feed: feed))
    loadingView.display(FeedLoadingViewModel(isLoading: false))
  }

  // Error -> creates view models -> sends to the UI
  public func didFinishLoadingFeed(with error: Error) {
    errorView.display(.error(message: feedLoadError))
    loadingView.display(FeedLoadingViewModel(isLoading: false))
  }
}
