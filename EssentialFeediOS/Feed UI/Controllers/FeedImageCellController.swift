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

public final class FeedImageCellController: NSObject {

  // 2. and define the type here
  public typealias ResourceViewModel = UIImage

  private let viewModel: FeedImageViewModel
  private let delegate: FeedImageCellControllerDelegate
  private let selection: () -> Void
  private var cell: FeedImageCell?

  public init(viewModel: FeedImageViewModel, delegate: FeedImageCellControllerDelegate, selection: @escaping() -> Void) {
    self.viewModel = viewModel
    self.delegate = delegate
    self.selection = selection
  }
}

// implements here all needed protocols and methods
extension FeedImageCellController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    cell = tableView.dequeueReusableCell()
    cell?.locationContainer.isHidden = !viewModel.hasLocation
    cell?.locationLabel.text = viewModel.location
    cell?.descriptionLabel.text = viewModel.description
    cell?.feedImageContainer.isShimmering = true
    cell?.feedImageRetryButton.isHidden = true
    // here we assign 'delegate.didRequestImage' action for the retry button
    cell?.onRetry = { [weak self] in 
      self?.delegate.didRequestImage()
    }
    delegate.didRequestImage()
    return cell!
  }

  // can receive the message and we need to delegate back as well the message to someone that can handle that image (here we have only 'FeedImageViewModel' but we need someone that knows about 'FeedImage')
  // we could add additional method to 'FeedImageCellControllerDelegate', but instead we can use 'initializer injection' and pass a closure 'selection'
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // we call closure when there is a selection in this view
    selection()
  }

  public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
     self.cell = cell as? FeedImageCell
     delegate.didRequestImage()
   }

  public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    self.cell = nil
    cancelLoad()
  }

  // we moved logic of deciding what to do with delegates and 'dataSourcePrefetching' to the cell controller so it controls whole lifecycle of its cell now. This way much cleaner and much easier to manage.
  public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    delegate.didRequestImage()
  }

  public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
    cancelLoad()
  }

  private func cancelLoad() {
    releaseCellForReuse()
    delegate.didCancelImageRequest()
  }

  private func releaseCellForReuse() {
    cell = nil
  }
}

// 1. implement ResourceView
extension FeedImageCellController: ResourceView, ResourceLoadingView, ResourceErrorView {
  // we had one method was rendering the FeedImageViewModel. Now we are split one into multiple methods into multiple view models so we can reuse the shared logic
  public func display(_ viewModel: UIImage) {
    cell?.feedImageView.setImageAnimated(viewModel)
  }

  public func display(_ viewModel: ResourceLoadingViewModel) {
    cell?.feedImageContainer.isShimmering = viewModel.isLoading
  }

  public func display(_ viewModel: ResourceErrorViewModel) {
    cell?.feedImageRetryButton.isHidden = viewModel.message == nil
  }
}
