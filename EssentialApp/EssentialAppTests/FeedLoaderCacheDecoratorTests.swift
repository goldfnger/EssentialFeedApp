//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Aleksandr Kornjushko on 28.11.2022.
//

import XCTest
import EssentialFeed

// FeedLoaderCacheDecorator is a FeedLoader
final class FeedLoaderCacheDecorator: FeedLoader {

  private let decoratee: FeedLoader

  // instantiate another loader which is the decoratee - the loader we are decorating. Step by step we inject save operation to it.
  init(decoratee: FeedLoader) {
    self.decoratee = decoratee
  }

  func load(completion: @escaping (FeedLoader.Result) -> Void) {
    // we need to forward message to the decoratee
    decoratee.load(completion: completion)
  }
}

final class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {

  func test_load_deliversFeedOnLoaderSuccess() {
    let feed = uniqueFeed()
    let loader = FeedLoaderStub(result: .success(feed))
    let sut = FeedLoaderCacheDecorator(decoratee: loader)

    expect(sut, toCompleteWith: .success(feed))
  }

  func test_load_deliversErrorOnLoaderFailure() {
    let loader = FeedLoaderStub(result: .failure(anyNSError()))
    let sut = FeedLoaderCacheDecorator(decoratee: loader)

    expect(sut, toCompleteWith: .failure(anyNSError()))
  }
}
