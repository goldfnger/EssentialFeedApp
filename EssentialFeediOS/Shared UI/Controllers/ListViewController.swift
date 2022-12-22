//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Aleksandr Kornjushko on 02.11.2022.
//

import UIKit
import EssentialFeed

public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
  private(set) public var errorView = ErrorView()

  private var loadingControllers = [IndexPath: CellController]()

  // creating a default diffable 'dataSource' with 'tableView'
  // it will handle all the updates for us automatically. thats why removed previous 'tableModel'.
  private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
    .init(tableView: tableView) { (tableView, index, controller) -> UITableViewCell? in
      // returning cell
      return controller.dataSource.tableView(tableView, cellForRowAt: index)
    }
  }()

  // every protocol with 1 function as it was in 'FeedViewControllerDelegate' can be replaced with closure
  // so closure will be used to initiate 'loadResource'
  public var onRefresh: (() -> Void)?

  public override func viewDidLoad() {
    super.viewDidLoad()

    tableView.dataSource = dataSource
    configureErrorView()
    refresh()
  }

  private func configureErrorView() {
    let container = UIView()
    container.backgroundColor = .clear
    container.addSubview(errorView)

    errorView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      errorView.topAnchor.constraint(equalTo: container.topAnchor),
      errorView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      errorView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      errorView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
    ])

    tableView.tableHeaderView = container

    errorView.onHide = { [weak self] in
      // begin and end updates will help to make nice animation for changing size of table view header
      // NB! 'beginUpdates' / 'endUpdates' might produce a potential memory leak because they might live longer than tests for example.
      self?.tableView.beginUpdates()
      self?.tableView.sizeTableHeaderToFit()
      self?.tableView.endUpdates()
    }
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    tableView.sizeTableHeaderToFit()
  }

  // if change was in previous 'category' (font sizing set by user), then we reload tableview.
  // this needs because there might be problems when using 'diffable data source' and 'dynamic fonts'.
  public override func traitCollectionDidChange(_ previous: UITraitCollection?) {
    if previous?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
      tableView.reloadData()
    }
  }

  @IBAction private func refresh() {
    onRefresh?()
  }

  // 1. everytime we get new 'CellController'
  public func display(_ cellControllers: [CellController]) {
    // 2. we create an empty snapshot
    var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
    // 3. we append the new controllers
    snapshot.appendSections([0])
    snapshot.appendItems(cellControllers, toSection: 0)
    // 4. tell data source to apply. 'dataSource' will check what changed using 'Hashable' and only update what is necessary
    if #available(iOS 15.0, *) {
      dataSource.applySnapshotUsingReloadData(snapshot)
    } else {
      dataSource.apply(snapshot)
    }
  }

  public func display(_ viewModel: ResourceLoadingViewModel) {
    refreshControl?.update(isRefreshing: viewModel.isLoading)
  }

  public func display(_ viewModel: ResourceErrorViewModel) {
    errorView.message = viewModel.message
  }

  public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let dl = cellController(at: indexPath)?.delegate
    dl?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
  }

  // 'numberOfRowsInSection' & 'cellForRowAt' are removed because 'dataSource' now is the diffable data source.
  // only requires to set new data source in 'ViewDidLoad'.

  public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let dl = cellController(at: indexPath)?.delegate
    // we are just forward/delegate the message to the controller
    dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
  }

  public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach { indexPath in
      let dsp = cellController(at: indexPath)?.dataSourcePrefetching
      dsp?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
  }

  public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach { indexPath in
      let dsp = cellController(at: indexPath)?.dataSourcePrefetching
      dsp?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
  }

  private func cellController(at indexPath: IndexPath) -> CellController? {
    dataSource.itemIdentifier(for: indexPath)
  }
}
