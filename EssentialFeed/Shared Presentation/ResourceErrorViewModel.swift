//
//  ResourceErrorViewModel.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 21.11.2022.
//

import Foundation

public struct ResourceErrorViewModel {
  public let message: String?

  static var noError: ResourceErrorViewModel {
    return ResourceErrorViewModel(message: nil)
  }

  static func error(message: String) -> ResourceErrorViewModel {
    return ResourceErrorViewModel(message: message)
  }
}
