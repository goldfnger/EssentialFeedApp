//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Aleksandr Kornjushko on 04.11.2022.
//

import UIKit

protocol FeedRefreshViewControllerDelegate {
  func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, FeedLoadingView {
  @IBOutlet private var view: UIRefreshControl?

  var delegate: FeedRefreshViewControllerDelegate?

  @IBAction func refresh() {
    delegate?.didRequestFeedRefresh()
  }

  func display(_ viewModel: FeedLoadingViewModel) {
    if viewModel.isLoading {
      view?.beginRefreshing()
    } else {
      view?.endRefreshing()
    }
  }
}
