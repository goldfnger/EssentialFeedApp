//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 23.11.2022.
//

import Foundation

public protocol FeedImageDataStore {
  typealias Result = Swift.Result<Data?, Error>

  func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
