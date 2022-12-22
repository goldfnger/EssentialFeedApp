//
//  ListSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Aleksandr Kornjushko on 21.12.2022.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

final class ListSnapshotTests: XCTestCase {

  func test_emptyList() {
    let sut = makeSUT()

    sut.display(emptyList())

    // for example first we use 'record' to take actual snapshot then add it to git
    // then assert future snapshots against the stored one using 'assert' method to make sure that views are rendered as expected
    assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_LIST_light")
    assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_LIST_dark")
  }

  func test_listWithErrorMessage() {
    let sut = makeSUT()

    sut.display(.error(message: "This is a \nmulti-line\nerror message"))

    assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "LIST_WITH_ERROR_MESSAGE_light")
    assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "LIST_WITH_ERROR_MESSAGE_dark")
  }

  //MARK: - Helpers

  private func makeSUT() -> ListViewController {
    let controller = ListViewController()
    controller.loadViewIfNeeded()
    controller.tableView.separatorStyle = .none
    controller.tableView.showsVerticalScrollIndicator = false
    controller.tableView.showsHorizontalScrollIndicator = false
    return controller
  }

  private func emptyList() -> [CellController] {
    return []
  }
}
