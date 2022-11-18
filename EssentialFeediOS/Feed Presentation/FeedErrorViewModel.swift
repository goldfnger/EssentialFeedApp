//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Aleksandr Kornjushko on 18.11.2022.
//

struct FeedErrorViewModel {
  let message: String?

  static var noError: FeedErrorViewModel {
    return FeedErrorViewModel(message: nil)
  }

  static func error(message: String) -> FeedErrorViewModel {
    return FeedErrorViewModel(message: message)
  }
}
