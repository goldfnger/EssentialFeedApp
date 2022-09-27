//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 27.09.2022.
//

import Foundation

enum FeedLoadResult {
  case success([FeedItem])
  case error(Error)
}

protocol FeedLoader {
  func load(completion: @escaping (FeedLoadResult) -> Void)
}
