//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Aleksandr Kornjushko on 30.09.2022.
//

import XCTest

extension XCTestCase {
  func trackForMemoryLeaks(_ instance: AnyObject,
                           file: StaticString = #filePath,
                           line: UInt = #line) {
    addTeardownBlock { [weak instance] in
      XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
    }
  }
}
