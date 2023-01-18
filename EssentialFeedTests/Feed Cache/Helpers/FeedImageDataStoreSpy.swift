//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Aleksandr Kornjushko on 23.11.2022.
//

import Foundation
import EssentialFeed

class FeedImageDataStoreSpy: FeedImageDataStore {
  enum Message: Equatable {
    case insert(data: Data, for: URL)
    case retrieve(dataFor: URL)
  }

  private(set) var receivedMessages = [Message]()
  private var retrievalCompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
  // stub insertionResult of type Void or Error
  private var insertionResult: Result<Void, Error>?

  // synchronous. in sync API we need to Stub value before the method is invoked! because we need to return a value immediately!
  func insert(_ data: Data, for url: URL) throws {
    // return synchronously immediately so we need to stub this result before invoking the method
    receivedMessages.append(.insert(data: data, for: url))
    // we need instead of 'capturing' the 'completion blocks' we need to 'stub' the 'result' 'upfront', because we need to return something either error or void.
    // we call 'try' 'insertionResult' 'get', if there is an error it throws, otherwise it return void
    try insertionResult?.get()
  }

  func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void) {
    receivedMessages.append(.retrieve(dataFor: url))
    retrievalCompletions.append(completion)
  }

  func completeRetrieval(with error: Error, at index: Int = 0) {
    retrievalCompletions[index](.failure(error))
  }

  func completeRetrieval(with data: Data?, at index: Int = 0) {
    retrievalCompletions[index](.success(data))
  }

  func completeInsertion(with error: Error, at index: Int = 0) {
    // just stub
    insertionResult = .failure(error)
  }

  func completeInsertionSuccessfully(at index: Int = 0) {
    // just stub
    insertionResult = .success(())
  }
}
