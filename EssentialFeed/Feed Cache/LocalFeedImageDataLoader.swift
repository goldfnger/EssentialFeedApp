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
  public typealias LoadResult = FeedImageDataLoader.Result

  public enum LoadError: Error {
    case failed
    case notFound
  }

  private final class LoadImageDataTask: FeedImageDataLoaderTask {
    private var completion: ((FeedImageDataLoader.Result) -> Void)?

    init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
      self.completion = completion
    }


    func complete(with result: FeedImageDataLoader.Result) {
      completion?(result)
    }

    func cancel() {
      preventFurtherCompletions()
    }

    private func preventFurtherCompletions() {
      completion = nil
    }
  }


  public func loadImageData(from url: URL, completion: @escaping (LoadResult) -> Void) -> FeedImageDataLoaderTask {
    let task = LoadImageDataTask(completion)

    task.complete(
      with: Swift.Result {
        try store.retrieve(dataForURL: url)
      }
        .mapError { _ in LoadError.failed }
        .flatMap { data in
          data.map { .success($0) } ?? .failure(LoadError.notFound)
        })

    return task
  }
}
