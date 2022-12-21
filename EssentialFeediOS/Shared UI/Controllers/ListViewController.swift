//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Aleksandr Kornjushko on 02.11.2022.
//

import UIKit
import EssentialFeed

// this typealias defines a type that needs to conform to all those three protocols
public typealias CellController = UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching

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
    // the controller is dispatching the methods, so in 'cellForRowAt' we have now the controller dispatching cell for row at 'indexPath' for each cell.
    // because each cell controller need to implement 'CellController' typealias protocols
    let controller = cellController(forRowAt: indexPath)
    return controller.tableView(tableView, cellForRowAt: indexPath)
  }

  public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    // we are just forward the message to the controller
    let controller = removeLoadingController(forRowAt: indexPath)
    controller?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
  }

  public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach { indexPath in
      let controller = cellController(forRowAt: indexPath)
      controller.tableView(tableView, prefetchRowsAt: [indexPath])
    }
  }

  public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach { indexPath in
      let controller = removeLoadingController(forRowAt: indexPath)
      controller?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
  }

  private func cellController(forRowAt indexPath: IndexPath) -> CellController {
    let controller = tableModel[indexPath.row]
    loadingControllers[indexPath] = controller
    return controller
  }

  private func removeLoadingController(forRowAt indexPath: IndexPath) -> CellController? {
    // get controller
    let controller = loadingControllers[indexPath]
    // set 'nil' in the dictionary where we are keeping track
    loadingControllers[indexPath] = nil
    return controller
  }
}
