//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 10.10.2022.
//

import Foundation

public protocol FeedStore {
  typealias DeletionCompletion = (Error?) -> Void
  typealias InsertionCompletion = (Error?) -> Void
  typealias RetrievalCompletions = (Error?) -> Void

  func deleteCacheFeed(completion: @escaping DeletionCompletion)
  func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
  func retrieve(completion: @escaping RetrievalCompletions)
}
