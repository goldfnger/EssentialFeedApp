//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 26.10.2022.
//

import Foundation

public final class CoreDataFeedStore: FeedStore {
  public init() {}

  public func retrieve(completion: @escaping RetrievalCompletions) {
    completion(.empty)
  }

  public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {

  }

  public func deleteCachedFeed(completion: @escaping DeletionCompletion) {

  }
}
