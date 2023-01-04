//
//  Paginated.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 04.01.2023.
//

import Foundation

// generic pagination and can be reused for feed items, feed images, comments whatever resources loaded from API
public struct Paginated<Item> {
  // closure that we complete with a result of either Paginated<Item or Error>
  // 'Self' because it is the same type 'Paginated<Item>'
  public typealias LoadMoreCompletion = (Result<Self, Error>) -> Void

  // items - hold the 'feed' so we know how many items we have loaded
  public let items: [Item]
  // closure to load more items. optional because if I have a closure that can load more it means I can load more, if I dont I can not load more
  public let canLoad: ((@escaping LoadMoreCompletion) -> Void)?

  public init(items: [Item], canLoad: ((@escaping LoadMoreCompletion) -> Void)? = nil) {
    self.items = items
    self.canLoad = canLoad
  }
}
