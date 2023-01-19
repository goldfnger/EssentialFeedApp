//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 23.11.2022.
//

import Foundation

public protocol FeedImageDataStore {
  func insert(_ data: Data, for url: URL) throws
  func retrieve(dataForURL url: URL) throws -> Data?
}
