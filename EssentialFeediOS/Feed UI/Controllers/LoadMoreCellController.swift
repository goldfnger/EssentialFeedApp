//
//  LoadMoreCellController.swift
//  EssentialFeediOS
//
//  Created by Aleksandr Kornjushko on 04.01.2023.
//

import UIKit
import EssentialFeed

// class to control display of 'spinner' indicator
public class LoadMoreCellController: NSObject, UITableViewDataSource {
  // we dont need to reuse this cell because it is only one cell in the view
  private let cell = LoadMoreCell()

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    cell
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
