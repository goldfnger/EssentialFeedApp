//
//  CombineHelpers.swift
//  EssentialApp
//
//  Created by Aleksandr Kornjushko on 15.12.2022.
//

import Foundation
import Combine
import EssentialFeed


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
    var task: FeedImageDataLoaderTask?

    return Deferred {
      Future { completion in
        // hold reference to task
        task = self.loadImageData(from: url, completion: completion)
      }
    }
    // and if we receive a cancel event - we cancel the task
    // we are using '.handleEvents' to inject a side-effect into the chain (here side-effect if there is a cancel event - cancel the running task)
    .handleEvents(receiveCancel: { task?.cancel() })
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
    save(data, for: url) { _ in }
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

extension Publisher where Output == [FeedImage] {
  func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
    handleEvents(receiveOutput: cache.saveIgnoringResult).eraseToAnyPublisher()
  }
}

private extension FeedCache {
  // we dont care about result
  func saveIgnoringResult(_ feed: [FeedImage]) {
    save(feed) { _ in }
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
