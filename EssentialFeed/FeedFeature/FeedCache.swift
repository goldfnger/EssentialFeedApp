//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 28.11.2022.
//

import Foundation

public protocol FeedCache {
  // same interface as in LocalFeedLoader for saving
  typealias Result = Swift.Result<Void, Error>

  func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
