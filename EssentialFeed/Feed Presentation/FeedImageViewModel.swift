//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 21.11.2022.
//

import Foundation

public struct FeedImageViewModel {
  public let description: String?
  public let location: String?

  public var hasLocation: Bool {
    return location != nil
  }
}
