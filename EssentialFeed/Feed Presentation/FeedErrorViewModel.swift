//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 21.11.2022.
//

import Foundation

public struct FeedErrorViewModel {
  public let message: String?

  static var noError: FeedErrorViewModel {
    return FeedErrorViewModel(message: nil)
  }

  static func error(message: String) -> FeedErrorViewModel {
    return FeedErrorViewModel(message: message)
  }
}
