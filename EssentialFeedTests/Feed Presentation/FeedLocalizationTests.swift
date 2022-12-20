//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Aleksandr Kornjushko on 11.11.2022.
//

import XCTest
@testable import EssentialFeed

final class FeedLocalizationTests: XCTestCase {

  func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
    let table = "Feed"
    let bundle = Bundle(for: FeedPresenter.self)

    assertLocalizedKeyAndValuesExist(in: bundle, table)
  }
}
