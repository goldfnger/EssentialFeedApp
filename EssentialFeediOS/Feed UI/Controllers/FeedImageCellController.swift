//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Aleksandr Kornjushko on 04.11.2022.
//

import UIKit
import EssentialFeed

public protocol FeedImageCellControllerDelegate {
  func didRequestImage()
  func didCancelImageRequest()
}

// implement ResourceView
public final class FeedImageCellController: FeedImageView, ResourceView, ResourceLoadingView, ResourceErrorView {
  // and define the type here
  public typealias ResourceViewModel = UIImage

  private let viewModel: FeedImageViewModel<UIImage>
  private let delegate: FeedImageCellControllerDelegate
  private var cell: FeedImageCell?

  public init(viewModel: FeedImageViewModel<UIImage>, delegate: FeedImageCellControllerDelegate) {
    self.viewModel = viewModel
    self.delegate = delegate
  }

  func view(in tableView: UITableView) -> UITableViewCell {
    cell = tableView.dequeueReusableCell()
    cell?.locationContainer.isHidden = !viewModel.hasLocation
    cell?.locationLabel.text = viewModel.location
    cell?.descriptionLabel.text = viewModel.description
//    cell?.accessibilityIdentifier = "feed-image-cell"
//    cell?.feedImageView.accessibilityIdentifier = "feed-image-view"
    cell?.onRetry = delegate.didRequestImage
    delegate.didRequestImage()
    return cell!
  }

  func preLoad() {
    delegate.didRequestImage()
  }

  func cancelLoad() {
    releaseCellForReuse()
    delegate.didCancelImageRequest()
  }

  // we had one method was rendering the FeedImageViewModel. Now we are split one into multiple methods into multiple view models so we can reuse the shared logic
  public func display(_ model: FeedImageViewModel<UIImage>) {}

  public func display(_ viewModel: UIImage) {
    cell?.feedImageView.setImageAnimated(viewModel)
  }

  public func display(_ viewModel: ResourceLoadingViewModel) {
    cell?.feedImageContainer.isShimmering = viewModel.isLoading
  }

  public func display(_ viewModel: ResourceErrorViewModel) {
    cell?.feedImageRetryButton.isHidden = viewModel.message == nil
  }

  private func releaseCellForReuse() {
    cell = nil
  }
}
