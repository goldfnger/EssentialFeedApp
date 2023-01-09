//
//  LoadMoreCellController.swift
//  EssentialFeediOS
//
//  Created by Aleksandr Kornjushko on 04.01.2023.
//

import UIKit
import EssentialFeed

// class to control display of 'spinner' indicator
public class LoadMoreCellController: NSObject, UITableViewDataSource, UITableViewDelegate {
  // we dont need to reuse this cell because it is only one cell in the view
  private let cell = LoadMoreCell()
  private let callback: () -> Void

  public init(callback: @escaping () -> Void) {
    self.callback = callback
  }

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    cell
  }

  // we removed 'cell' next to willDisplay because we are not using this one, but 'LoadMoreCell'
  public func tableView(_ tableView: UITableView, willDisplay: UITableViewCell, forRowAt indexPath: IndexPath) {
    reloadIfNeeded()
  }

  // when user tap load more error we should call 'callback' and reload
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    reloadIfNeeded()
  }

  private func reloadIfNeeded() {
    // we should call 'callback' only if we are not loading. otherwise callback will be triggered again and again even if it is already loading a request - it can use too many resources in the device and in the server
    guard !cell.isLoading else { return }

    // every time the cell will be displayed it will call the 'callback'
    callback()
  }
}

// re using 'ResourceLoadingView' because it fits our needs
extension LoadMoreCellController: ResourceLoadingView, ResourceErrorView {
  public func display(_ viewModel: EssentialFeed.ResourceErrorViewModel) {
    cell.message = viewModel.message
  }

  public func display(_ viewModel: EssentialFeed.ResourceLoadingViewModel) {
    cell.isLoading = viewModel.isLoading
  }
}
