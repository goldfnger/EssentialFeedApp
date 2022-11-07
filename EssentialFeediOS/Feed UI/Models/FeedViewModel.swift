//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Aleksandr Kornjushko on 07.11.2022.
//

import Foundation
import EssentialFeed

final class FeedViewModel {
  typealias Observer<T> = (T) -> Void

  private let feedLoader: FeedLoader

  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }

  // will be used to update loading state
  var onLoadingStateChange: Observer<Bool>?
  // will be used in view controller to update(pass values) UI
  var onFeedLoad: Observer<[FeedImage]>?

  func loadFeed() {
    onLoadingStateChange?(true)
    feedLoader.load { [weak self] result in
      if let feed = try? result.get() {
        self?.onFeedLoad?(feed)
      }
      self?.onLoadingStateChange?(false)
    }
  }
}
