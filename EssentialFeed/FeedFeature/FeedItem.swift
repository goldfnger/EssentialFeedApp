//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 27.09.2022.
//

import Foundation

public struct FeedItem: Equatable {
  let id: UUID
  let description: String?
  let location: String?
  let image: URL
}
