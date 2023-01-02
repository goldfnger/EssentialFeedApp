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
    
    let received = FeedEndpoint.get.url(baseURL: baseURL)
    let expected = URL(string: "http://base-url.com/v1/feed")!
    
    XCTAssertEqual(received, expected)
  }
}
