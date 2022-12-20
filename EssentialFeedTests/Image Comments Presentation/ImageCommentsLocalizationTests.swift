//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Aleksandr Kornjushko on 20.12.2022.
//

import XCTest
import EssentialFeed

final class ImageCommentsLocalizationTests: XCTestCase {

  func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
    let table = "ImageComments"
    let bundle = Bundle(for: ImageCommentsPresenter.self)

    assertLocalizedKeyAndValuesExist(in: bundle, table)
  }
}
