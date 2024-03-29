//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Aleksandr Kornjushko on 23.11.2022.
//

import XCTest
import EssentialFeed

final class LoadFeedImageDataFromCacheUseCaseTests: XCTestCase {

  func test_init_doesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()

    XCTAssertTrue(store.receivedMessages.isEmpty)
  }

  func test_loadImageData_requestsStoreDataForULR() {
    let (sut, store) = makeSUT()
    let url = anyURL()

    _ = try? sut.loadImageData(from: url)

    XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: url)])
  }

  func test_loadImageDataFromURL_failsOnStoreError() {
    let (sut, store) = makeSUT()

    expect(sut, toCompleteWith: failed(), when: {
      let retrievedError = anyNSError()
      store.completeRetrieval(with: retrievedError)
    })
  }

  func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFound() {
    let (sut, store) = makeSUT()

    expect(sut, toCompleteWith: notFound(), when: {
      store.completeRetrieval(with: .none)
    })
  }

  func test_loadImageDataFromURL_deliversStoredDataOnFoundData() {
    let (sut, store) = makeSUT()
    let foundData = anyData()

    expect(sut, toCompleteWith: .success(foundData), when: {
      store.completeRetrieval(with: foundData)
    })
  }

  // also removed test that does not deliver result after cancelling task, because it is synchronous now and cannot be cancelled.
  // we get the cancelling for free when we compose it in the Composition Root

//MARK: - Helpers

  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
    let store = FeedImageDataStoreSpy()
    let sut = LocalFeedImageDataLoader(store: store)
    trackForMemoryLeaks(store, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, store)
  }

  private func failed() -> Result<Data, Error> {
    return .failure(LocalFeedImageDataLoader.LoadError.failed)
  }

  private func notFound() -> Result<Data, Error> {
    return .failure(LocalFeedImageDataLoader.LoadError.notFound)
  }

  private func never(file: StaticString = #file, line: UInt = #line) {
    XCTFail("Expected no no invocations", file: file, line: line)
  }

  private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: Result<Data, Error>, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
    // while refactoring to Sync API, now we need to 'first' setup the 'stub' and 'then' call the 'method' below
    action()

    let receivedResult = Result { try sut.loadImageData(from: anyURL()) }

    switch (receivedResult, expectedResult) {
    case let (.success(receivedData), .success(expectedData)):
      XCTAssertEqual(receivedData, expectedData, file: file, line: line)

    case (.failure(let receivedError as LocalFeedImageDataLoader.LoadError),
          .failure(let expectedError as LocalFeedImageDataLoader.LoadError)):
      XCTAssertEqual(receivedError, expectedError, file: file, line: line)

    default:
      XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
    }
  }
}
