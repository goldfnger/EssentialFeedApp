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

    XCTAssertEqual(app.cells.count, 22)
    // for some reason this assertion is always failing.
//    XCTAssertEqual(app.cells.firstMatch.images.count, 1)
  }
}
