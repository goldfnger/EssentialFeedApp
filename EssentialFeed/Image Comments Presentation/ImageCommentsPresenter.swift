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
public struct ImageCommentViewModel: Hashable {
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
  // we are injecting the environment dependencies/the impure dependencies so we can control them during tests or even in production when we want to control the time
  public static func map(
    _ comments: [ImageComment],
    currentDate: Date = Date(),
    calendar: Calendar = .current,
    locale: Locale = .current
  ) -> ImageCommentsViewModel {
    let formatter = RelativeDateTimeFormatter()
    formatter.calendar = calendar
    formatter.locale = locale

    return ImageCommentsViewModel(comments: comments.map { comment in
      ImageCommentViewModel(
        message: comment.message,
        date: formatter.localizedString(for: comment.createdAt, relativeTo: currentDate),
        username: comment.username)
    })
  }
}
