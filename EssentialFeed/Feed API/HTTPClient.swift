//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 28.09.2022.
//

import Foundation

public enum HTTPClientResult {
  case success(Data, HTTPURLResponse)
  case failure(Error)
}

public protocol HTTPClient {
  /// The completion handler can be invoked in any thread.
  /// Clients are responsible to dispatch to appropriate threads, if needed.
  func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
