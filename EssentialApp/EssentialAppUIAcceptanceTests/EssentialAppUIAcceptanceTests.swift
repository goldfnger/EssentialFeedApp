//
//  EssentialAppUIAcceptanceTests.swift
//  EssentialAppUIAcceptanceTests
//
//  Created by Aleksandr Kornjushko on 01.12.2022.
//

import XCTest

final class EssentialAppUIAcceptanceTests: XCTestCase {

  func test_onLaunch_displaysRemoteFeedWhenCustomersHasConnectivity() {
    let app = XCUIApplication()
    app.launchArguments = ["-reset"]
    app.launch()

    let feedCells = app.cells.matching(identifier: "feed-image-cell")
    XCTAssertEqual(feedCells.count, 22)

    let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch
    XCTAssertTrue(firstImage.exists)
  }

  func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
    let onlineApp = XCUIApplication()
    onlineApp.launchArguments = ["-reset"]
    onlineApp.launch()

    let offlineApp = XCUIApplication()
    offlineApp.launchArguments = ["-connectivity", "offline"]
    offlineApp.launch()

    let cachedFeedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
    XCTAssertEqual(cachedFeedCells.count, 22)

    let firstCachedImage = offlineApp.images.matching(identifier: "feed-image-view").firstMatch
    XCTAssertTrue(firstCachedImage.exists)
  }

  func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
    let app = XCUIApplication()
    app.launchArguments = ["-reset", "-connectivity", "offline"]
    app.launch()

    let feedCells = app.cells.matching(identifier: "feed-image-cell")
    XCTAssertEqual(feedCells.count, 0)
  }
}
