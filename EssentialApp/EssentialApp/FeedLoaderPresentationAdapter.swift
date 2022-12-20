//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Aleksandr Kornjushko on 14.11.2022.
//

import Combine
import EssentialFeed
import EssentialFeediOS

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
  private let feedLoader: () -> AnyPublisher<[FeedImage], Error>
  private var cancellable: Cancellable?
  // generic presenter should match the Resource type array of FeedImage and view type is FeedViewAdapter(which holds logic of view to display feed)
  var presenter: LoadResourcePresenter<[FeedImage], FeedViewAdapter>?

  init(feedLoader: @escaping() -> AnyPublisher<[FeedImage], Error>) {
    self.feedLoader = feedLoader
  }

  func didRequestFeedRefresh() {
    presenter?.didStartLoading()

    // sink is used to subscribe to the 'Publisher' and start the operation.
    // we need to hold(cancellable = ...) the result of the subscription which is 'Cancellable'. if we dont hold the Cancellable it will be deallocated, if it will be deallocated then it cancels the whole subscription.
    cancellable = feedLoader()
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
        }, receiveValue: { [weak self] feed in
          self?.presenter?.didFinishLoading(with: feed)
        })
  }
}

