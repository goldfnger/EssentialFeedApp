//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Aleksandr Kornjushko on 17.10.2022.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
  typealias DeletionCompletion = (Error?) -> Void
  typealias InsertionCompletion = (Error?) -> Void

  enum ReceivedMessage: Equatable {
    case deleteCacheFeed
    case insert([LocalFeedImage], Date)
    case retrieve
  }

  private(set) var receivedMessages = [ReceivedMessage]()

  private var deletionCompletion = [DeletionCompletion]()
  private var insertionCompletions = [InsertionCompletion]()
  private var retrievalCompletions = [RetrievalCompletions]()

  func deleteCacheFeed(completion: @escaping DeletionCompletion) {
    deletionCompletion.append(completion)
    receivedMessages.append(.deleteCacheFeed)
  }

  func completeDeletion(with error: Error, at index: Int = 0) {
    deletionCompletion[index](error)
  }

  func completeDeletionSuccessfully(at index: Int = 0) {
    deletionCompletion[index](nil)
  }

  func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
    insertionCompletions.append(completion)
    receivedMessages.append(.insert(feed, timestamp))
  }

  func completeInsertion(with error: Error, at index: Int = 0) {
    insertionCompletions[index](error)
  }

  func completeInsertionSuccessfully(at index: Int = 0) {
    insertionCompletions[index](nil)
  }

  func retrieve(completion: @escaping RetrievalCompletions) {
    retrievalCompletions.append(completion)
    receivedMessages.append(.retrieve)
  }

  func completeRetrieval(with error: Error, at index: Int = 0) {
    retrievalCompletions[index](error)
  }

  func completeRetrievalWithEmptyCache(at index: Int = 0) {
    retrievalCompletions[index](nil)
  }
}
