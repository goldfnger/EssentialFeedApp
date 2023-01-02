//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialAppTests
//
//  Created by Aleksandr Kornjushko on 26.11.2022.
//

import XCTest

extension XCTestCase {
  // might not detect memory leak (as example case with 'autoreleasepool' in 'CommentsUIIntegrationTests') because it invokes the add tear down block which happens after the test
  // where 'autoreleasepool' already released the object
  func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
    addTeardownBlock { [weak instance] in
      XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
    }
  }
}
