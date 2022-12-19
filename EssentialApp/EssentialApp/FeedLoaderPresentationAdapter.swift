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
  var presenter: FeedPresenter?

  init(feedLoader: @escaping() -> AnyPublisher<[FeedImage], Error>) {
    self.feedLoader = feedLoader
  }

  func didRequestFeedRefresh() {
    presenter?.didStartLoadingFeed()

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
            
            // if error occures
          case let .failure(error):
            self?.presenter?.didFinishLoadingFeed(with: error)
          }
          // success value
        }, receiveValue: { [weak self] feed in
          self?.presenter?.didFinishLoadingFeed(with: feed)
        })
  }
}

