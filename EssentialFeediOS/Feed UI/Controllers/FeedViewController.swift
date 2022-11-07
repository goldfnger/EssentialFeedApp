//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Aleksandr Kornjushko on 02.11.2022.
//

import UIKit

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
  private var refreshController: FeedRefreshViewController?
  var tableModel = [FeedImageCellController]() {
    didSet { tableView.reloadData() }
  }

  convenience init(refreshController: FeedRefreshViewController) {
    self.init()
    self.refreshController = refreshController
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    tableView.prefetchDataSource = self
    refreshControl = refreshController?.view
    refreshController?.refresh()
  }

  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableModel.count
  }

  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return cellController(forRowAt: indexPath).view()
  }

  public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cancelCellController(forRowAt: indexPath)
  }

  public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach { indexPath in
      cellController(forRowAt: indexPath).preLoad()
    }
  }

  public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach(cancelCellController)
  }

  private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
    return tableModel[indexPath.row]
  }

  private func cancelCellController(forRowAt indexPath: IndexPath) {
    cellController(forRowAt: indexPath).cancelLoad()
  }
}
