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
  func deleteCachedFeed() throws {
    // simply complete the operation so the clients wont be hanging forever
    // different 'use cases' may required different behaviours to complete, but for our cases success is the case.
  }

  func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date) throws {}

  func retrieve() throws -> CachedFeed? { .none }

  func insert(_ data: Data, for url: URL) throws {}

  func retrieve(dataForURL url: URL) throws -> Data? { .none }
}
