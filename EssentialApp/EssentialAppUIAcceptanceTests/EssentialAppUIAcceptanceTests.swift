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

    app.launch()

    let feedCells = app.cells.matching(identifier: "feed-image-cell")
    XCTAssertEqual(feedCells.count, 22)

    let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch
    XCTAssertTrue(firstImage.exists)
  }
}
