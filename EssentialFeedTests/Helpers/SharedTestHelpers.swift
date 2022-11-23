//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Aleksandr Kornjushko on 20.10.2022.
//

import Foundation
import EssentialFeed

func anyNSError() -> NSError {
  return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
  return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
  return Data("any data".utf8)
}
