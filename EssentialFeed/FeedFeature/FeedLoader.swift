//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 27.09.2022.
//

import Foundation

public typealias FeedLoadResult = Result<[FeedImage], Error>

public protocol FeedLoader {
  func load(completion: @escaping (FeedLoadResult) -> Void)
}
