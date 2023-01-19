//
//  CombineHelpers.swift
//  EssentialApp
//
//  Created by Aleksandr Kornjushko on 15.12.2022.
//

import Foundation
import Combine
import EssentialFeed

// this going to convert this closure type ('(Result<Self, Error>) -> Void') into a 'Publisher'
// this is the 'bridging' from the 'closure' to 'publisher' and vice versa
// bridging is not needed if our modules are coupled with combine, otherwise we create a bridge and we decouple from Combine (it is a choice)
public extension Paginated {
  // converting 'publisher' into 'closure'
  init(items: [Item], loadMorePublisher: (() -> AnyPublisher<Self, Error>)?) {
    // 'loadMore' needs a 'closure' optional will only exist if we have a load more otherwise it is 'nil', so we can just map this 'optional' that would give us 'publisher' closure
    self.init(items: items, loadMore: loadMorePublisher.map { publisher in
      // and now we need to return a 'closure' loadMore that takes a 'completion' (which is 'closure' in 'Paginated<Item> loadMore')
      // so in this case everytime this closure is invoked with a completion block
      return { completion in
        // we will call 'publisher' 'closure' that will return a 'publisher' and then we can subscribe to the 'publisher'
        // using 'Subscribers.Sink()' instead of '.sink()' because this way 'Combine' will handle the life cycle without 'Cancellables' so we dont need to hold the cancellable for this subscription. subscription will be alive until it completes
        publisher().subscribe(Subscribers.Sink(receiveCompletion: { result in
          // completion may not be failure, could be just a completed successfully so we need to unwrap
          if case let .failure(error) = result {
            completion(.failure(error))
          }
        }, receiveValue: { result in
          completion(.success(result))
        }))
      }
    })
  }

  // 'converting' closure into 'publisher'
  var loadMorePublisher: (() -> AnyPublisher<Self, Error>)? {
    // but only if we have 'loadMore' closure
    guard let loadMore = loadMore else { return nil }

    return {
      Deferred {
        Future(loadMore)
      }.eraseToAnyPublisher()
    }
  }
}

public extension HTTPClient {
  typealias Publisher = AnyPublisher<(Data, HTTPURLResponse), Error>

  func getPublisher(url: URL) -> Publisher {
    var task: HTTPClientTask?

    return Deferred {
      Future { completion in
        // hold reference to task
        task = self.get(from: url, completion: completion)
      }
    }
    // and if we receive a cancel event - we cancel the task
    // we are using '.handleEvents' to inject a side-effect into the chain (here side-effect if there is a cancel event - cancel the running task)
    .handleEvents(receiveCancel: { task?.cancel() })
    .eraseToAnyPublisher()
  }
}

public extension FeedImageDataLoader {
  typealias Publisher = AnyPublisher<Data, Error>

  func loadImageDataPublisher(from url: URL) -> Publisher {
    return Deferred {
      Future { completion in
        // hold reference to task
        completion(Result {
          try self.loadImageData(from: url)
        })
      }
    }
    .eraseToAnyPublisher()
  }
}

extension Publisher where Output == Data {
  func caching(to cache: FeedImageDataCache, using url: URL) -> AnyPublisher<Output, Failure> {
    // injecting side effect into the chain
    handleEvents(receiveOutput: { data in
      cache.saveIgnoringResult(data, for: url)
    }).eraseToAnyPublisher()
  }
}

private extension FeedImageDataCache {
  func saveIgnoringResult(_ data: Data, for url: URL) {
    try? save(data, for: url)
  }
}

public extension LocalFeedLoader {
  // Future will be fired instantly once the 'makeRemoteFeedLoaderWithLocalFallBack' is called
  // if we want to fire request only when someone subscribes to it, not on creation of the Publisher, so one way we can defer the execution of the Future is to wrap it into a 'Deferred' publisher
//    return Deferred {
//      Future { completion in
//        remoteFeedLoader.load(completion: completion)
//      }
    // since the types match between RemoteFeedLoader completion block and Future completion block we can just pass the load function for the completion

  // wrapping the load function into Combine Publishers
  typealias Publisher = AnyPublisher<[FeedImage], Error>

  func loadPublisher() -> Publisher {
    return Deferred {
      Future(self.load)
    }
    .eraseToAnyPublisher()
  }
}

extension Publisher {
  func fallback(to fallbackPublisher: @escaping() -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
    // 'self' is the primary and 'fallbackPublisher' is the fallback
    self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
  }
}

extension Publisher {
  // to cache 'FeedImage' items
  func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure>  where Output == [FeedImage] {
    handleEvents(receiveOutput: cache.saveIgnoringResult).eraseToAnyPublisher()
  }

  // to cache 'Paginated' 'FeedImage' pages
  func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure>  where Output == Paginated<FeedImage> {
    handleEvents(receiveOutput: cache.saveIgnoringResult).eraseToAnyPublisher()
  }

}

private extension FeedCache {
  // we dont care about result
  // to cache 'FeedImage' items
  func saveIgnoringResult(_ feed: [FeedImage]) {
    save(feed) { _ in }
  }

  // to cache 'Paginated' 'FeedImage' ie 'pages'
  func saveIgnoringResult(_ page: Paginated<FeedImage>) {
    saveIgnoringResult(page.items)
  }
}

extension Publisher {
  func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
    receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
  }
}

extension DispatchQueue {

  static var immediateWhenOnMainQueueScheduler: ImmediateWhenOnMainQueueScheduler {
    ImmediateWhenOnMainQueueScheduler()
  }

  struct ImmediateWhenOnMainQueueScheduler: Scheduler {
    typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
    typealias SchedulerOptions = DispatchQueue.SchedulerOptions

    var now: SchedulerTimeType {
      DispatchQueue.main.now
    }

    var minimumTolerance: SchedulerTimeType.Stride {
      DispatchQueue.main.minimumTolerance
    }

    func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
      guard Thread.isMainThread else {
        return DispatchQueue.main.schedule(options: options, action)
      }

      action()
    }

    func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
      DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
    }

    func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
      DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
    }
  }
}
