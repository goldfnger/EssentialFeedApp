//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 27.09.2022.
//

import Foundation

public protocol FeedLoader {
  typealias Result = Swift.Result<[FeedImage], Error>

  func load(completion: @escaping (Result) -> Void)
}
