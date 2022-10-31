//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Aleksandr Kornjushko on 17.10.2022.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
  enum ReceivedMessage: Equatable {
    case deleteCacheFeed
    case insert([LocalFeedImage], Date)
    case retrieve
  }

  private(set) var receivedMessages = [ReceivedMessage]()

  private var deletionCompletion = [DeletionCompletion]()
  private var insertionCompletions = [InsertionCompletion]()
  private var retrievalCompletions = [RetrievalCompletions]()

  func deleteCachedFeed(completion: @escaping DeletionCompletion) {
    deletionCompletion.append(completion)
    receivedMessages.append(.deleteCacheFeed)
  }

  func completeDeletion(with error: Error, at index: Int = 0) {
    deletionCompletion[index](.failure(error))
  }

  func completeDeletionSuccessfully(at index: Int = 0) {
    deletionCompletion[index](.success(()))
  }

  func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
    insertionCompletions.append(completion)
    receivedMessages.append(.insert(feed, timestamp))
  }

  func completeInsertion(with error: Error, at index: Int = 0) {
    insertionCompletions[index](.failure(error))
  }

  func completeInsertionSuccessfully(at index: Int = 0) {
    insertionCompletions[index](.success(()))
  }

  func retrieve(completion: @escaping RetrievalCompletions) {
    retrievalCompletions.append(completion)
    receivedMessages.append(.retrieve)
  }

  func completeRetrieval(with error: Error, at index: Int = 0) {
    retrievalCompletions[index](.failure(error))
  }

  func completeRetrievalWithEmptyCache(at index: Int = 0) {
    retrievalCompletions[index](.success(.none))
  }

  func completeRetrieval(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
    retrievalCompletions[index](.success(CachedFeed(feed: feed, timestamp: timestamp)))
  }

}
