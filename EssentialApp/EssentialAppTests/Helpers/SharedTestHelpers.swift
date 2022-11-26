//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Aleksandr Kornjushko on 26.11.2022.
//

import Foundation

func anyNSError() -> NSError {
  return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
  return URL(string: "http://a-url.com")!
}

func anyData() -> Data {
  return Data("any data".utf8)
}
