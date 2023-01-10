//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Aleksandr Kornjushko on 04.11.2022.
//

import UIKit
import EssentialFeediOS

//MARK: - Generic
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

  func simulateErrorViewTap() {
    errorView.simulateTap()
  }

  var errorMessage: String? {
    return errorView.message
  }

  var isShowingLoadingIndicator: Bool {
    return refreshControl?.isRefreshing == true
  }

  func numberOfRows(in section: Int) -> Int {
    tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
  }

  func cell(row: Int, section: Int) -> UITableViewCell? {
    guard numberOfRows(in: section) > row else {
      return nil
    }
    let ds = tableView.dataSource
    let index = IndexPath(row: row, section: section)
    return ds?.tableView(tableView, cellForRowAt: index)
  }
}

//MARK: - Comments
extension ListViewController {
  func numberOfRenderedComments() -> Int{
    return numberOfRows(in: commentsImagesSection)
  }

  // this helper methods will protect tests from changes by just return needed texts from labels
  func commentMessage(at row: Int) -> String? {
    commentView(at: row)?.messageLabel.text
  }

  func commentDate(at row: Int) -> String? {
    commentView(at: row)?.dateLabel.text
  }

  func commentUsername(at row: Int) -> String? {
    commentView(at: row)?.usernameLabel.text
  }

  // this helper method will create a comment view
  private func commentView(at row: Int) -> ImageCommentCell? {
    cell(row: row, section: commentsImagesSection) as? ImageCommentCell
  }

  private var commentsImagesSection: Int { 0 }
}

//MARK: - Feed
extension ListViewController {
  @discardableResult
  func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
    let view = simulateFeedImageViewVisible(at: row)

    let delegate = tableView.delegate
    let index = IndexPath(row: row, section: feedImagesSection)
    delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)

    return view
  }

  // only notify which row was selected
  func simulateTapOnFeedImage(at row: Int) {
    let delegate = tableView.delegate
    let index = IndexPath(row: row, section: feedImagesSection)
    delegate?.tableView?(tableView, didSelectRowAt: index)
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

  // when the load more cell will become visible - we can use delegate method 'willDisplay' and since the load more cell is always the last cell of the table that is when it is going to become visible it should load more
  func simulateLoadMoreFeedAction() {
    // cell might not exist, because if you can not load more the cell should not be added to the table view
    // so we can not simulate if we dont have a load more cell
    // view is basically 'load more action'
    guard let view = cell(row: 0, section: feedLoadMoreSection) else { return }

    let delegate = tableView.delegate
    // to separate views into sections exactly you know so we have a section with all the 'feed images' and then we have a section with the 'load more' then you can have a section with some header items etc
    // in our case we need 'first item 'row 0'' from the 'second section', because 'first section' is the 'feed section'
    let index = IndexPath(row: 0, section: feedLoadMoreSection)
    delegate?.tableView?(tableView, willDisplay: view, forRowAt: index)
  }

  func simulateTapOnLoadMoreFeedError() {
    let delegate = tableView.delegate
    let index = IndexPath(row: 0, section: feedLoadMoreSection)
    delegate?.tableView?(tableView, didSelectRowAt: index)
  }

  // we are showing the load more feed indicator
  var isShowingLoadMoreFeedIndicator: Bool {
    // if the cell exists and its loading
    return loadMoreFeedCell()?.isLoading == true
  }

  var loadMoreFeedErrorMessage: String? {
    return loadMoreFeedCell()?.message
  }

  var canLoadMoreFeed: Bool {
    loadMoreFeedCell() != nil
  }

  private func loadMoreFeedCell() -> LoadMoreCell? {
    cell(row: 0, section: feedLoadMoreSection) as? LoadMoreCell
  }

  func renderedFeedImageData(at index: Int) -> Data? {
    return simulateFeedImageViewVisible(at: index)?.renderedImage
  }

  func numberOfRenderedFeedImageViews() -> Int {
    return numberOfRows(in: feedImagesSection)
  }

  func feedImageView(at row: Int) -> UITableViewCell? {
    cell(row: row, section: feedImagesSection)
  }

  private var feedImagesSection: Int { 0 }
  private var feedLoadMoreSection: Int { 1 }
}
