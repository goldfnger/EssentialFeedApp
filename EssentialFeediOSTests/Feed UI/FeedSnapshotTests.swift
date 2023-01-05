//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Aleksandr Kornjushko on 02.12.2022.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

final class FeedSnapshotTests: XCTestCase {

  func test_feedWithContent() {
    let sut = makeSUT()

    sut.display(feedWithContent())

    assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_CONTENT_light")
    assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_CONTENT_dark")
    assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_CONTENT_light_extraExtraExtraLarge")
  }

  func test_feedWithFailedImageLoading() {
    let sut = makeSUT()

    sut.display(feedWithFailedImageLoading())

    assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_FAILED_IMAGE_LOADING_light")
    assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_FAILED_IMAGE_LOADING_dark")
  }

  func test_feedWithLoadMoreIndicator() {
    let sut = makeSUT()

    sut.display(feedWithLoadMoreIndicator())

    assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_LOAD_MORE_INDICATOR_light")
    assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_LOAD_MORE_INDICATOR_dark")
  }

  func test_feedWithLoadMoreError() {
    let sut = makeSUT()

    sut.display(feedWithLoadMoreError())

    assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_LOAD_MORE_ERROR_light")
    assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_LOAD_MORE_ERROR_dark")
    assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_LOAD_MORE_ERROR_light_extraExtraExtraLarge")
  }

  //MARK: - Helpers

  private func makeSUT() -> ListViewController {
    let bundle = Bundle(for: ListViewController.self)
    let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
    let controller = storyboard.instantiateInitialViewController() as! ListViewController
    controller.loadViewIfNeeded()
    controller.tableView.showsVerticalScrollIndicator = false
    controller.tableView.showsHorizontalScrollIndicator = false
    return controller
  }

  private func feedWithContent() -> [ImageStub] {
    return [
      ImageStub(
        description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
        location: "East Side Gallery\nMemorial in Berlin, Germany",
        image: UIImage.make(withColor: .red)
      ),
      ImageStub(
        description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
        location: "Garth Pier",
        image: UIImage.make(withColor: .green)
      )
    ]
  }

  private func feedWithFailedImageLoading() -> [ImageStub] {
    return [
      ImageStub(description: nil, location: "Cannon Street, London", image: nil),
      ImageStub(description: nil, location: "Brighton Seafront", image: nil)
    ]
  }

  private func feedWithLoadMoreIndicator() -> [CellController] {
    // 2. setting 'spinner' after image
    let loadMore = LoadMoreCellController(callback: {})
    loadMore.display(ResourceLoadingViewModel(isLoading: true))
    // compose 'cellControllers' with 'loadMore' into the cell into the list view controller, because they are all cell controllers
    return feedWith(loadMore: loadMore)
  }

  private func feedWithLoadMoreError() -> [CellController] {
    // 2. setting 'spinner' after image
    let loadMore = LoadMoreCellController(callback: {})
    loadMore.display(ResourceErrorViewModel(message: "This is a multiline\nerror message"))
    // compose 'cellController' with 'loadMore' into the cell into the list view controller, because they are all cell controllers
    return feedWith(loadMore: loadMore)
  }

  private func feedWith(loadMore: LoadMoreCellController) -> [CellController] {
    // 1. creating and getting just one last image stub
    let stub = feedWithContent().last!
    let cellController = FeedImageCellController(viewModel: stub.viewModel, delegate: stub, selection: {})
    stub.controller = cellController

    // compose 'cellControllers' with 'loadMore' into the cell into the list view controller, because they are all cell controllers
    return [
      CellController(id: UUID(), cellController),
      CellController(id: UUID(), loadMore)
    ]
  }
}

private extension ListViewController {
  func display(_ stubs: [ImageStub]) {
    let cells: [CellController] = stubs.map { stub in
      let cellController = FeedImageCellController(viewModel: stub.viewModel, delegate: stub, selection: { } )
      stub.controller = cellController
      // because 'FeedImageCellController' implements all 3 protocols - 'CellController' init() will make it internally
      // in tests we dont care about 'id' because we dont want to keep track of changes
      return CellController(id: UUID(), cellController)
    }

    display(cells)
  }
}

private class ImageStub: FeedImageCellControllerDelegate {
  let viewModel: FeedImageViewModel
  let image: UIImage?
  weak var controller: FeedImageCellController?

  init(description: String?, location: String?, image: UIImage?) {
    self.viewModel = FeedImageViewModel(
      description: description,
      location: location)
    self.image = image
  }

  func didRequestImage() {
    controller?.display(ResourceLoadingViewModel(isLoading: false))

    if let image = image {
      controller?.display(image)
      controller?.display(ResourceErrorViewModel(message: .none))
    } else {
      controller?.display(ResourceErrorViewModel(message: "any"))
    }
  }

  func didCancelImageRequest() {
  }
}
