//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 29.11.2022.
//

import Foundation

public protocol FeedImageDataCache {
  // now it is synchronous. it either return 'Void' or 'throw an Error', thats why instead of 'completion block' we use 'throws' and remove previous 'Result typealias'
  func save(_ data: Data, for url: URL) throws
}
