//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 20.12.2022.
//

import Foundation

// model with all comments data
public struct  ImageCommentsViewModel {
  public let comments: [ImageCommentViewModel]
}

// model with comment data to display
public struct ImageCommentViewModel: Equatable {
  public let message: String
  public let date: String
  public let username: String

  public init(message: String, date: String, username: String) {
    self.message = message
    self.date = date
    self.username = username
  }
}

public final class ImageCommentsPresenter {
  public static var title: String {
    return NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
                             tableName: "ImageComments",
                             bundle: Bundle(for: Self.self), 
                             comment: "Title for the image comments view")
  }

  // transform data from ImageComment type to ImageCommentsViewModel with mapped date or any requested data
  public static func map(
    _ comments: [ImageComment]) -> ImageCommentsViewModel {
    let formatter = RelativeDateTimeFormatter()

    return ImageCommentsViewModel(comments: comments.map { comment in
      ImageCommentViewModel(
        message: comment.message,
        date: formatter.localizedString(for: comment.createdAt, relativeTo: Date()),
        username: comment.username)
    })
  }
}
