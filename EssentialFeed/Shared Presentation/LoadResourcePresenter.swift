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
  private let loadingView: ResourceLoadingView
  private let errorView: FeedErrorView
  private let mapper: Mapper

  public init(resourceView: View, loadingView: ResourceLoadingView, errorView: FeedErrorView, mapper: @escaping Mapper) {
    self.resourceView = resourceView
    self.loadingView = loadingView
    self.errorView = errorView
    self.mapper = mapper
  }

  public static var loadError: String {
     return NSLocalizedString("GENERIC_CONNECTION_ERROR",
        tableName: "Shared",
        // Self.self = AnyPresenter.self, example FeedPresenter.self
        bundle: Bundle(for: Self.self),
        comment: "Error message displayed when we can't load the resource from the server")
   }

  // data in -> creates view models -> data out to the UI

  // Void -> creates view models -> sends to the UI
  public func didStartLoading() {
    errorView.display(.noError)
    loadingView.display(ResourceLoadingViewModel(isLoading: true))
  }

  // [FeedImage] -> creates view models -> sends to the UI
  // [ImageComment] -> creates view models -> sends to the UI
  // Data -> UIImage -> send to the UI

  // Resource -> create ResourceViewModel -> sends to the UI
  public func didFinishLoading(with resource: Resource) {
    resourceView.display(mapper(resource))
    loadingView.display(ResourceLoadingViewModel(isLoading: false))
  }

  // Error -> creates view models -> sends to the UI
  public func didFinishLoading(with error: Error) {
    errorView.display(.error(message: Self.loadError))
    loadingView.display(ResourceLoadingViewModel(isLoading: false))
  }

}
