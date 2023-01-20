//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 28.11.2022.
//

import Foundation

public protocol FeedCache {
  func save(_ feed: [FeedImage]) throws
}
