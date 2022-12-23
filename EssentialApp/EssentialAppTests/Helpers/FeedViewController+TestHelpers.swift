//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Aleksandr Kornjushko on 04.11.2022.
//

import UIKit
import EssentialFeediOS

extension ListViewController {
  public override func loadViewIfNeeded() {
    super.loadViewIfNeeded()

    // by this we prevent loading cells ahead of time with 'diffable data source' in all tests which are using 'loadViewIfNeeded'
    // the way it works, we set 'tableView' to a very very small frame - this way there is not enough space to render the cells which is not going to load them ahead of time, only when we call the methods
    tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
  }

  func simulateUserInitiatedReload() {
    refreshControl?.simulatePullToRefresh()
  }

  @discardableResult
  func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
    return feedImageView(at: index) as? FeedImageCell
  }

  @discardableResult
  func simulateFeedImageBecomingVisibleAgain(at row: Int) -> FeedImageCell? {
    let view = simulateFeedImageViewNotVisible(at: row)

    let delegate = tableView.delegate
    let index = IndexPath(row: row, section: feedImagesSection)
    delegate?.tableView?(tableView, willDisplay: view!, forRowAt: index)

    return view
  }

  @discardableResult
  func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
    let view = simulateFeedImageViewVisible(at: row)

    let delegate = tableView.delegate
    let index = IndexPath(row: row, section: feedImagesSection)
    delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)

    return view
  }

  func simulateFeedImageViewNearVisible(at row: Int) {
    let ds = tableView.prefetchDataSource
    let index = IndexPath(row: row, section: feedImagesSection)
    ds?.tableView(tableView, prefetchRowsAt: [index])
  }

  func simulateFeedImageViewNotNearVisible(at row: Int) {
    simulateFeedImageViewVisible(at: row)

    let ds = tableView.prefetchDataSource
    let index = IndexPath(row: row, section: feedImagesSection)
    ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
  }

  func renderedFeedImageData(at index: Int) -> Data? {
    return simulateFeedImageViewVisible(at: index)?.renderedImage
  }

  func simulateErrorViewTap() {
    errorView.simulateTap()
  }

  var errorMessage: String? {
    return errorView.message
  }

  var isShowingLoadingIndicator: Bool {
    return refreshControl?.isRefreshing == true
  }

  func numberOfRenderedFeedImageViews() -> Int {
    return tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: feedImagesSection)
  }

  func feedImageView(at row: Int) -> UITableViewCell? {
    guard numberOfRenderedFeedImageViews() > row else {
      return nil
    }
    
    let ds = tableView.dataSource
    let index = IndexPath(row: row, section: feedImagesSection)
    return ds?.tableView(tableView, cellForRowAt: index)
  }

  private var feedImagesSection: Int {
    return 0
  }
}
