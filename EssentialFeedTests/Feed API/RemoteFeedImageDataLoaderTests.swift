//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Aleksandr Kornjushko on 22.11.2022.
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {
  init(client: Any) {

  }
}
final class RemoteFeedImageDataLoaderTests: XCTestCase {

  func test_init_doesNotPerformAnyURLRequest() {
    let (_, client) = makeSUT()

    XCTAssertTrue(client.requestedURLs.isEmpty)
  }

  //MARK: - Helpers

  private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteFeedImageDataLoader(client: client)
    trackForMemoryLeaks(sut, file: file, line: line)
    trackForMemoryLeaks(client, file: file, line: line)
    return (sut, client)
  }

  private class HTTPClientSpy {
    var requestedURLs = [URL]()
  }
}
