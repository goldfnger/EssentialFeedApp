//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 23.11.2022.
//

import Foundation

public protocol FeedImageDataStore {
  typealias RetrievalResult = Swift.Result<Data?, Error>
  typealias InsertionResult = Swift.Result<Void, Error>

  func insert(_ data: Data, for url: URL) throws
  func retrieve(dataForURL url: URL) throws -> Data?

  @available(*, deprecated)
  func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)

  @available(*, deprecated)
  func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void)
}

public extension FeedImageDataStore {
  func insert(_ data: Data, for url: URL) throws {
    // with 'DispatchGroup' we make func 'sync' instead of 'async' by locking client and wait until this operation is done
    let group = DispatchGroup()
    group.enter()
    var result: InsertionResult!
    insert(data, for: url) {
      // we removed 'result in' after curled brace thats why we directly append '$0' to 'result'
      result = $0
      group.leave()
    }
    group.wait()
    // if it 'fails' will return 'fail' from 'result', if 'succeeds' then return 'data'
    return try result.get()
  }

  func retrieve(dataForURL url: URL) throws -> Data? {
    let group = DispatchGroup()
    group.enter()
    var result: RetrievalResult!
    retrieve(dataForURL: url) {
      // we removed 'result in' after curled brace thats why we directly append '$0' to 'result'
      result = $0
      group.leave()
    }
    group.wait()
    // if it 'fails' will return 'fail' from 'result', if 'succeeds' then return 'data'
    return try result.get()
  }

  func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {}
  func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void) {}
}
