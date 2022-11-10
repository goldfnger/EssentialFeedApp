//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Aleksandr Kornjushko on 07.11.2022.
//

struct FeedImageViewModel<Image> {
  let description: String?
  let location: String?
  let image: Image?
  let isLoading: Bool
  let shouldRetry: Bool

  var hasLocation: Bool {
    return location != nil
  }
}
