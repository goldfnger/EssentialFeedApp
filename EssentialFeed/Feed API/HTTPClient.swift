//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 28.09.2022.
//

import Foundation

public protocol HTTPClientTask {
  func cancel()
}

public protocol HTTPClient {
  typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

  /// The completion handler can be invoked in any thread.
  /// Clients are responsible to dispatch to appropriate threads, if needed.
  func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}
