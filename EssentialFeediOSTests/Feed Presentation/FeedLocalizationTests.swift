//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Aleksandr Kornjushko on 11.11.2022.
//

import XCTest
@testable import EssentialFeediOS

final class FeedLocalizationTests: XCTestCase {

  func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
    // 1 define localized table for testing
    let table = "Feed"
    // 2 create main presentation Bundle where localzied tables live
    let presentationBundle = Bundle(for: FeedPresenter.self)
    // 3 find all localization bundles in the main presentation Bundle (means all supported languages)
    let localizationBundles = allLocalizationBundles(in: presentationBundle)
    // 4 find all possible keys in the Feed table
    let localizedStringKeys = allLocalizedStringKeys(in: localizationBundles, table: table)

    // 5 iterate through all localization bundles making sure every localized key has a localized value in all supported localizations
    localizationBundles.forEach { (bundle, localization) in
      localizedStringKeys.forEach { key in
        let language = Locale.current.localizedString(forLanguageCode: localization) ?? ""
        let localizedString = bundle.localizedString(forKey: key, value: nil, table: table)

        if localizedString == key {
          XCTFail("Missing \(language) (\(localization)) localized string for key: '\(key)' in table: '\(table)'")
        }
      }
    }
  }

  //MARK: - Helpers

  private typealias LocalizedBundles = (bundle: Bundle, localization: String)

  private func allLocalizationBundles(in bundle: Bundle, file: StaticString = #filePath, line: UInt = #line) -> [LocalizedBundles] {
    return bundle.localizations.compactMap { localization in
      guard
        let path = bundle.path(forResource: localization, ofType: "lproj"),
        let localizedBundle = Bundle(path: path)
      else {
        XCTFail("Couldn't find bundle for localization: \(localization)", file: file, line: line)
        return nil
      }

      return (localizedBundle, localization)
    }
  }

  private func allLocalizedStringKeys(in bundles: [LocalizedBundles], table: String, file: StaticString = #filePath, line: UInt = #line) -> Set<String> {
    return bundles.reduce([]) { (acc, current) in
      guard
        let path = current.bundle.path(forResource: table, ofType: "strings"),
        let strings = NSMutableDictionary(contentsOfFile: path),
        let keys = strings.allKeys as? [String]
      else {
        XCTFail("Couldn't load localized strings for localization: \(current.localization)", file: file, line: line)
        return acc
      }

      return acc.union(Set(keys))
    }
  }
}
