//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Aleksandr Kornjushko on 28.11.2022.
//

import EssentialFeed

// FeedLoaderCacheDecorator is a FeedLoader
public final class FeedLoaderCacheDecorator: FeedLoader {
  private let decoratee: FeedLoader
  private let cache: FeedCache

  // instantiate another loader which is the decoratee - the loader we are decorating. Step by step we inject save operation to it.
  public init(decoratee: FeedLoader, cache: FeedCache) {
    self.decoratee = decoratee
    self.cache = cache
  }

  public func load(completion: @escaping (FeedLoader.Result) -> Void) {
    // we need to forward message to the decoratee
    decoratee.load { [weak self] result in
      // map will be executed only in success case
      completion(result.map { feed in
        self?.cache.saveIgnoringResult(feed)
        return feed
      })
    }
  }
}

private extension FeedCache {
  // we dont care about result
  func saveIgnoringResult(_ feed: [FeedImage]) {
    save(feed) { _ in }
  }
}
