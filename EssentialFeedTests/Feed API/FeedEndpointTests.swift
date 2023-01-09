//
//  FeedEndpointTests.swift
//  EssentialFeedTests
//
//  Created by Aleksandr Kornjushko on 02.01.2023.
//

import XCTest
import EssentialFeed
final class FeedEndpointTests: XCTestCase {
  
  func test_feed_endpointURL() {
    let baseURL = URL(string: "http://base-url.com")!
    
    let received = FeedEndpoint.get().url(baseURL: baseURL)

    XCTAssertEqual(received.scheme, "http", "scheme")
    XCTAssertEqual(received.host, "base-url.com", "host")
    XCTAssertEqual(received.path, "/v1/feed", "path")
    XCTAssertEqual(received.query, "limit=10", "query")
  }

  func test_feed_endpointURLAfterGivenImage() {
    let image = uniqueImage()
    let baseURL = URL(string: "http://base-url.com")!

    let received = FeedEndpoint.get(after: image).url(baseURL: baseURL)

    XCTAssertEqual(received.scheme, "http", "scheme")
    XCTAssertEqual(received.host, "base-url.com", "host")
    XCTAssertEqual(received.path, "/v1/feed", "path")
    // here we are using 'contains()' to make sure that if we change the 'order' of the final URL still works, because 'order' is irrelevant in 'queryItems'
    XCTAssertEqual(received.query?.contains("limit=10"), true, "limit query param")
    XCTAssertEqual(received.query?.contains("after_id=\(image.id)"), true, "after_id query param")
  }
}
