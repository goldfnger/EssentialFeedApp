//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Aleksandr Kornjushko on 21.12.2022.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

final class ImageCommentsSnapshotTests: XCTestCase {

  func test_listWithComments() {
    let sut = makeSUT()

    sut.display(comments())

    assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_light")
    assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_dark")
    assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "IMAGE_COMMENTS_light_extraExtraExtraLarge")
  }

  //MARK: - Helpers

  private func makeSUT() -> ListViewController {
    let bundle = Bundle(for: ListViewController.self)
    let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
    let controller = storyboard.instantiateInitialViewController() as! ListViewController
    controller.loadViewIfNeeded()
    controller.tableView.showsVerticalScrollIndicator = false
    controller.tableView.showsHorizontalScrollIndicator = false
    return controller
  }

  private func comments() -> [CellController] {
    // will call 'commentControllers' map and we create here the 'CellController' with the view - in this case it only implements dataSource
    // in 'CellController' more comments
    // in tests we dont care about 'id' because we dont want to keep track of changes
    commentControllers().map { CellController(id: UUID(), $0) }
  }

  private func commentControllers() -> [ImageCommentCellController] {
    return [
      ImageCommentCellController(
        model: ImageCommentViewModel(
          message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
          date: "1000 years ago",
          username: "a long long long long username"
        )
      ),
      ImageCommentCellController(
        model: ImageCommentViewModel(
          message: "East Side Gallery\nMemorial in Berlin, Germany",
          date: "10 days ago",
          username: "a username"
        )
      ),
      ImageCommentCellController(
        model: ImageCommentViewModel(
          message: "nice",
          date: "1 hour ago",
          username: "a."
        )
      )
    ]
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
