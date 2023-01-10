//
//  NullStore.swift
//  EssentialApp
//
//  Created by Aleksandr Kornjushko on 10.01.2023.
//

import Foundation
import EssentialFeed
// Null Object pattern - complete the operation with the simplest null operation, no result
// it will provide a 'default neutral behaviour' for 'store' if application gets in a weird/bug state. this 'default neutral behaviour' better to do the minimum possible!
class NullStore: FeedStore & FeedImageDataStore {
  func deleteCachedFeed(completion: @escaping DeletionCompletion) {
    // simply complete the operation so the clients wont be hanging forever
    // different 'use cases' may required different behaviours to complete, but for our cases success is the case.
    completion(.success(()))
  }

  func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
    completion(.success(()))
  }

  func retrieve(completion: @escaping RetrievalCompletions) {
    completion(.success(.none))

  }

  func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
    completion(.success(()))
  }

  func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
    completion(.success(.none))
  }
}
