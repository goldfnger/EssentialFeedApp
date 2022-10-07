//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Aleksandr Kornjushko on 07.10.2022.
//

import XCTest

class LocalFeedLoader {
  init(store: FeedStore) {

  }
}
class FeedStore {
  var deleteCacheFeedCallCount = 0
}

class CacheFeedUseCaseTests: XCTestCase {

  func test() {
    let store = FeedStore()
    _ = LocalFeedLoader(store: store)

    XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
  }
}
