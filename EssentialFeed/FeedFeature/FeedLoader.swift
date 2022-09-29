//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 27.09.2022.
//

import Foundation

public enum FeedLoadResult<Error: Swift.Error> {
  case success([FeedItem])
  case failure(Error)
}

extension FeedLoadResult: Equatable where Error: Equatable {}

protocol FeedLoader {
  associatedtype Error: Swift.Error
  func load(completion: @escaping (FeedLoadResult<Error>) -> Void)
}
