//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Aleksandr Kornjushko on 02.11.2022.
//

import UIKit
import EssentialFeed

public protocol CellController {
  func view(in: UITableView) -> UITableViewCell
  func preLoad()
  func cancelLoad()
}

// making extension like this we can provide default implementations which will prevent other 'controllers' from implementations which they dont want to
public extension CellController {
  func preLoad() {}
  func cancelLoad() {}
}

public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
  @IBOutlet private(set) public var errorView: ErrorView?

  private var loadingControllers = [IndexPath: CellController]()

  // collection of 'CellController', where every 'controller' controls one cell each
  private var tableModel = [CellController]() {
    didSet {tableView.reloadData() }
  }

  // every protocol with 1 function as it was in 'FeedViewControllerDelegate' can be replaced with closure
  // so closure will be used to initiate 'loadResource'
  public var onRefresh: (() -> Void)?

  public override func viewDidLoad() {
    super.viewDidLoad()

    refresh()
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    tableView.sizeTableHeaderToFit()
  }

  @IBAction private func refresh() {
    onRefresh?()
  }

  public func display(_ cellControllers: [CellController]) {
    loadingControllers = [:]
    tableModel = cellControllers
  }

  public func display(_ viewModel: ResourceLoadingViewModel) {
    refreshControl?.update(isRefreshing: viewModel.isLoading)
  }

  public func display(_ viewModel: ResourceErrorViewModel) {
    errorView?.message = viewModel.message
  }
  
  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableModel.count
  }

  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return cellController(forRowAt: indexPath).view(in: tableView)
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

  private func cellController(forRowAt indexPath: IndexPath) -> CellController {
    let controller = tableModel[indexPath.row]
    loadingControllers[indexPath] = controller
    return controller
  }

  private func cancelCellController(forRowAt indexPath: IndexPath) {
    loadingControllers[indexPath]?.cancelLoad()
    loadingControllers[indexPath] = nil
  }
}
