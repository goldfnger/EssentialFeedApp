//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Aleksandr Kornjushko on 14.11.2022.
//

import Combine
import EssentialFeed
import EssentialFeediOS

final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
  private let loader: () -> AnyPublisher<Resource, Error>
  private var cancellable: Cancellable?
  // generic presenter should match the Resource type array of FeedImage and view type is FeedViewAdapter(which holds logic of view to display feed)
  // refactored to generic type so as FeedImage now we have Resource type and for view now we have generic ResourceView
  var presenter: LoadResourcePresenter<Resource, View>?

  init(loader: @escaping() -> AnyPublisher<Resource, Error>) {
    self.loader = loader
  }

  // this generic func now can be used for loading images, comments feed or whatever we need in the future
  func loadResource() {
    presenter?.didStartLoading()

    // sink is used to subscribe to the 'Publisher' and start the operation.
    // we need to hold(cancellable = ...) the result of the subscription which is 'Cancellable'. if we dont hold the Cancellable it will be deallocated, if it will be deallocated then it cancels the whole subscription.
    cancellable = loader()
      .dispatchOnMainQueue()
      .sink(
        receiveCompletion: { [weak self] completion in
          // if publisher completes
          switch completion {
            // we do nothing
          case .finished: break
            
            // if error occurs
          case let .failure(error):
            self?.presenter?.didFinishLoading(with: error)
          }
          // success value
        }, receiveValue: { [weak self] resource in
          self?.presenter?.didFinishLoading(with: resource)
        })
  }
}

extension LoadResourcePresentationAdapter: FeedImageCellControllerDelegate {
  func didRequestImage() {
    loadResource()
  }

  func didCancelImageRequest() {
    cancellable?.cancel()
    cancellable = nil
  }
}
