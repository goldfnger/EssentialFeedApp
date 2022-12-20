//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 21.11.2022.
//

import Foundation

public final class FeedImagePresenter {
  public static func map(_ image: FeedImage) -> FeedImageViewModel{
    FeedImageViewModel(description: image.description,
                       location: image.location)
  }
}
