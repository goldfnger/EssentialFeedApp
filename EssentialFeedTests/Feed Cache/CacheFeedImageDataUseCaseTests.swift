//
//  CacheFeedImageDataUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Aleksandr Kornjushko on 23.11.2022.
//

import XCTest
import EssentialFeed

class CacheFeedImageDataUseCaseTests: XCTestCase {

  func test_init_doesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()

    XCTAssertTrue(store.receivedMessages.isEmpty)
  }

  func test_saveImageDataForURL_requestsImageDataInsertionForURL() {
    let (sut, store) = makeSUT()
    let url = anyURL()
    let data = anyData()

    // we dont care about the result, because we are testing it in other tests
    try? sut.save(data, for: url)

    XCTAssertEqual(store.receivedMessages, [.insert(data: data, for: url)])
  }

  func test_saveImageDataFromURL_failsOnStoreInsertionError() {
    let (sut, store) = makeSUT()

    expect(sut, toCompleteWith: failed(), when: {
      let insertionError = anyNSError()
      store.completeInsertion(with: insertionError)
    })
  }

  func test_saveImageDataFromURL_succeedsOnSuccessfulStoreInsertion() {
    let (sut, store) = makeSUT()

    expect(sut, toCompleteWith: .success(()), when: {
      store.completeInsertionSuccessfully()
    })
  }

  // if we have a sync APIs they will never be allocated during an implementation or during an action. it cant happen.

  //MARK: - Helpers

  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
    let store = FeedImageDataStoreSpy()
    let sut = LocalFeedImageDataLoader(store: store)
    trackForMemoryLeaks(store, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, store)
  }


  private func failed() -> Result<Void, Error> {
    return .failure(LocalFeedImageDataLoader.SaveError.failed)
  }

  private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: Result<Void, Error>, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
    // while refactoring to Sync API, now we need to 'first' setup the 'stub' and 'then' call the 'method' below
    action()

    let receivedResult = Result { try sut.save(anyData(), for: anyURL()) }

    switch (receivedResult, expectedResult) {
    case (.success, .success):
      break

    case (.failure(let receivedError as LocalFeedImageDataLoader.SaveError),
          .failure(let expectedError as LocalFeedImageDataLoader.SaveError)):
      XCTAssertEqual(receivedError, expectedError, file: file, line: line)

    default:
      XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
    }
  }
}
