//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 23.11.2022.
//

import Foundation

public final class LocalFeedImageDataLoader {
  private let store: FeedImageDataStore

  public init(store: FeedImageDataStore) {
    self.store = store
  }
}

extension LocalFeedImageDataLoader: FeedImageDataCache {
  public enum SaveError: Error {
    case failed
  }

  // if we have a sync APIs they will never be allocated during an implementation or during an action. it cant happen.
  public func save(_ data: Data, for url: URL) throws {
    // now instead of calling these async APIs waiting for the completion and calling the completion block
    // we can do it synchronously using do catch
    do {
      // and calling the sync API without the completion block
      try store.insert(data, for: url)
    } catch {
      throw SaveError.failed
    }
  }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
  public enum LoadError: Error {
    case failed
    case notFound
  }

  public func loadImageData(from url: URL) throws -> Data {
    do {
      if let imageData = try store.retrieve(dataForURL: url) {
        return imageData
      }
    } catch {
      throw LoadError.failed
    }

    throw LoadError.notFound
  }
}
