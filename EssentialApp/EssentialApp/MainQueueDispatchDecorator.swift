//
//  MainQueueDispatchDecorator.swift
//  EssentialFeediOS
//
//  Created by Aleksandr Kornjushko on 14.11.2022.
//

import Foundation
import EssentialFeed

final class MainQueueDispatchDecorator<T> {
  private let decoratee: T

  init(decoratee: T) {
    self.decoratee = decoratee
  }

  func dispatch(completion: @escaping () -> Void) {
    guard Thread.isMainThread else {
      return DispatchQueue.main.async(execute: completion)
    }

    completion()
  }
}

// if decoratee conforms to FeedLoader then we also conforms to FeedLoader and dispatch the work in main thread
extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
  func load(completion: @escaping (FeedLoader.Result) -> Void) {
    decoratee.load { [weak self] result in
      self?.dispatch { completion(result) }
    }
  }
}

extension MainQueueDispatchDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
  func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
    return decoratee.loadImageData(from: url) { [weak self] result in
      self?.dispatch { completion(result) }
    }
  }
}
