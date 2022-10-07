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
    store.deleteCacheFeed()
  }
}
class FeedStore {
  var deleteCacheFeedCallCount = 0

  func deleteCacheFeed() {
    deleteCacheFeedCallCount += 1
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

  //MARK: - Helpers

  private func makeSUT() -> (sut: LocalFeedLoader, store: FeedStore) {
    let store = FeedStore()
    let sut = LocalFeedLoader(store: store)
    return (sut, store)
  }

  private func uniqueItem() -> FeedItem {
    return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
  }

  private func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
  }

}
