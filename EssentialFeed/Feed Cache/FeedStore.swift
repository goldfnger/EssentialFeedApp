//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 10.10.2022.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
  func deleteCachedFeed() throws
  func insert(_ feed: [LocalFeedImage], timestamp: Date) throws
  func retrieve() throws -> CachedFeed?
}
