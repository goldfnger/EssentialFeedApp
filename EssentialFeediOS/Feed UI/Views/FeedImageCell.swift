//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Aleksandr Kornjushko on 02.11.2022.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
  public let locationContainer = UIView()
  public let locationLabel = UILabel()
  public let descriptionLabel = UILabel()
  public let feedImageContainer = UIView()
  public let feedImageView = UIImageView()

  // bind button with onRetry closure
  private(set) public lazy var feedImageRetryButton: UIButton = {
    let button = UIButton()
    button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
    return button
  }()

  // should be invoked every time button is tapped
  var onRetry: (() -> Void)?

  @objc private func retryButtonTapped() {
    onRetry?()
  }
}
