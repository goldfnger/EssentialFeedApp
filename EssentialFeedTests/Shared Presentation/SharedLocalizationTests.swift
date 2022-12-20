//
//  SharedLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Aleksandr Kornjushko on 20.12.2022.
//

import XCTest
import EssentialFeed

final class SharedLocalizationTests: XCTestCase {

  func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
    // 1 define localized table for testing
    let table = "Shared"
    // 2 create main presentation Bundle where localzied tables live
    let bundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)

    // 3, 4, 5 steps in method
    assertLocalizedKeyAndValuesExist(in: bundle, table)
  }

  private class DummyView: ResourceView {
    func display(_ viewModel: Any) {}
  }
}
