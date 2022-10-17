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
  }

  private(set) var receivedMessages = [ReceivedMessage]()

  private var deletionCompletion = [DeletionCompletion]()
  private var insertionCompletions = [InsertionCompletion]()

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
}
