//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Aleksandr Kornjushko on 07.10.2022.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
  let store: FeedStore

  init(store: FeedStore) {
    self.store = store
  }

  func save(_ items: [FeedItem]) {
    store.deleteCacheFeed { [unowned self] error in
      if error == nil {
        self.store.insert(items)
      }
    }
  }
}

class FeedStore {
  typealias DeletionCompletion = (Error?) -> Void

  var deleteCacheFeedCallCount = 0
  var insertCallCount = 0

  private var deletionCompletion = [DeletionCompletion]()

  func deleteCacheFeed(completion: @escaping DeletionCompletion) {
    deleteCacheFeedCallCount += 1
    deletionCompletion.append(completion)
  }

  func completeDeletion(with error: Error, at index: Int = 0) {
    deletionCompletion[index](error)
  }

  func completeDeletionSuccessfully(at index: Int = 0) {
    deletionCompletion[index](nil)
  }

  func insert(_ items: [FeedItem]) {
    insertCallCount += 1
  }
}

class CacheFeedUseCaseTests: XCTestCase {

  func test_init_doesNotDeleteCacheUponCreation() {
    let (_, store) = makeSUT()

    XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
  }

  func test_save_requestsCacheDeletion() {
    let items = [uniqueItem(), uniqueItem()]
    let (sut, store) = makeSUT()

    sut.save(items)

    XCTAssertEqual(store.deleteCacheFeedCallCount, 1)
  }

  func test_save_doesNotRequestCacheInsertionOnDeletionError() {
    let items = [uniqueItem(), uniqueItem()]
    let (sut, store) = makeSUT()
    let deletionError = anyNSError()

    sut.save(items)
    store.completeDeletion(with: deletionError)

    XCTAssertEqual(store.insertCallCount, 0)
  }

  func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
    let items = [uniqueItem(), uniqueItem()]
    let (sut, store) = makeSUT()

    sut.save(items)
    store.completeDeletionSuccessfully()

    XCTAssertEqual(store.insertCallCount, 1)

  }

  //MARK: - Helpers

  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
    let store = FeedStore()
    let sut = LocalFeedLoader(store: store)

    trackForMemoryLeaks(store, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)

    return (sut, store)
  }

  private func uniqueItem() -> FeedItem {
    return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
  }

  private func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
  }

  private func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
  }
}
