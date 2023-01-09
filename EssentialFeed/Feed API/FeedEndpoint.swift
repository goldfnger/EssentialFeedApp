//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 02.01.2023.
//

import Foundation

public enum FeedEndpoint {
  case get(after: FeedImage? = nil)
  
  public func url(baseURL: URL) -> URL {
    switch self {
    case let .get(image):
      var components = URLComponents()
      // https
      components.scheme = baseURL.scheme
      // eg base-url.com
      components.host = baseURL.host
      // full main path
      components.path = baseURL.path + "/v1/feed"
      // append default key value pair
      components.queryItems = [
        // for pagination
        URLQueryItem(name: "limit", value: "10"),
        // with 'map' we adding additional parameter to 'query' using 'FeedImage' 'id' (backend based on this id will decide which next 10 items to load)
        image.map { URLQueryItem(name: "after_id", value: $0.id.uuidString)}
        // we are using 'compactMap' to remove the optionals, because query items dont accept optionals
      ].compactMap { $0 }
      // making it force-unwrap, because if someone passes the wrong value(baseURL that is invalid) there will be a programmer mistake, we should crash early and unwrap it
      // if we would get baseURL from API (dynamically) then we do not need to force unwrap it
      return components.url!
    }
  }
}
