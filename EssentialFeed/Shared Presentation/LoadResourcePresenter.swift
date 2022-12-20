//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 19.12.2022.
//

import Foundation

public protocol ResourceView {
  associatedtype ResourceViewModel

  func display(_ viewModel: ResourceViewModel)
}

public final class LoadResourcePresenter<Resource, View: ResourceView> {
  // mapper should map from resource to view model
  public typealias Mapper = (Resource) -> View.ResourceViewModel

  private let resourceView: View
  private let loadingView: FeedLoadingView
  private let errorView: FeedErrorView
  private let mapper: Mapper

  public init(resourceView: View, loadingView: FeedLoadingView, errorView: FeedErrorView, mapper: @escaping Mapper) {
    self.resourceView = resourceView
    self.loadingView = loadingView
    self.errorView = errorView
    self.mapper = mapper
  }

  private var feedLoadError: String {
     return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
        tableName: "Feed",
        bundle: Bundle(for: FeedPresenter.self),
        comment: "Error message displayed when we can't load the image feed from the server")
   }

  // data in -> creates view models -> data out to the UI

  // Void -> creates view models -> sends to the UI
  public func didStartLoading() {
    errorView.display(.noError)
    loadingView.display(FeedLoadingViewModel(isLoading: true))
  }

  // [FeedImage] -> creates view models -> sends to the UI
  // [ImageComment] -> creates view models -> sends to the UI
  // Data -> UIImage -> send to the UI

  // Resource -> create ResourceViewModel -> sends to the UI
  public func didFinishLoading(with resource: Resource) {
    resourceView.display(mapper(resource))
    loadingView.display(FeedLoadingViewModel(isLoading: false))
  }

  // Error -> creates view models -> sends to the UI
  public func didFinishLoadingFeed(with error: Error) {
    errorView.display(.error(message: feedLoadError))
    loadingView.display(FeedLoadingViewModel(isLoading: false))
  }

}
