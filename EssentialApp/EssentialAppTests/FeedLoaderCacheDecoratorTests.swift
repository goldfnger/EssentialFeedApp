//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Aleksandr Kornjushko on 28.11.2022.
//

import XCTest
import EssentialFeed
import EssentialApp

final class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {

  func test_load_deliversFeedOnLoaderSuccess() {
    let feed = uniqueFeed()
    let sut = makeSUT(loaderResult: .success(feed))

    expect(sut, toCompleteWith: .success(feed))
  }

  func test_load_deliversErrorOnLoaderFailure() {
    let sut = makeSUT(loaderResult: .failure(anyNSError()))

    expect(sut, toCompleteWith: .failure(anyNSError()))
  }

  func test_load_cachesLoadedFeedOnLoaderSuccess() {
    let cache = CacheSpy()
    let feed = uniqueFeed()
    // we stub loader result with a successful feed
    let sut = makeSUT(loaderResult: .success(feed), cache: cache)

    sut.load { _ in }

    XCTAssertEqual(cache.messages, [.save(feed)], "Expect to cache loaded feed on success")
  }

  func test_load_doesNotCacheOnLoaderFailure() {
    let cache = CacheSpy()
    // we stub loader result with a failure error
    let sut = makeSUT(loaderResult: .failure(anyNSError()), cache: cache)

    sut.load { _ in }

    XCTAssertTrue(cache.messages.isEmpty, "Expect to cache loaded feed on success")
  }

  //MARK: - Helpers

  private func makeSUT(loaderResult: FeedLoader.Result, cache: CacheSpy = .init(), file: StaticString = #filePath, line: UInt = #line) -> FeedLoader {
    let loader = FeedLoaderStub(result: loaderResult)
    let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
    trackForMemoryLeaks(loader, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }

  private class CacheSpy: FeedCache {
    private(set) var messages = [Message]()

    enum Message: Equatable {
      case save([FeedImage])
    }

    func save(_ feed: [FeedImage], completion: @escaping (FeedCache.Result) -> Void) {
      // capture message
      messages.append(.save(feed))
      completion(.success(()))
    }
  }
}
