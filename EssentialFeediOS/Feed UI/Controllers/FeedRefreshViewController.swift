//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Aleksandr Kornjushko on 04.11.2022.
//

import UIKit

final class FeedRefreshViewController: NSObject {
  private(set) lazy var view = binded(UIRefreshControl())

  private let viewModel: FeedViewModel

  init(viewModel: FeedViewModel) {
    self.viewModel = viewModel
  }

  @objc func refresh() {
    viewModel.loadFeed()
  }

  private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
    // binds ViewModel with View
    viewModel.onChange = { [weak self] viewModel in
      if viewModel.isLoading {
        self?.view.beginRefreshing()
      } else {
        self?.view.endRefreshing()
      }
    }
    // binds View with the ViewModel
    view.addTarget(self, action: #selector(refresh), for: .valueChanged)

    return view
  }
}
