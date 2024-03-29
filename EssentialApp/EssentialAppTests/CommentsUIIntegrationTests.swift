//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Aleksandr Kornjushko on 23.12.2022.
//

import XCTest
import Combine
import UIKit
import EssentialApp
import EssentialFeed
import EssentialFeediOS

final class CommentsUIIntegrationTests: XCTestCase {

  func test_commentsView_hasTitle() {
    let (sut, _) = makeSUT()

    sut.loadViewIfNeeded()

    XCTAssertEqual(sut.title, commentsTitle)
  }

  func test_loadCommentsActions_requestCommentsFromLoader() {
    let (sut, loader) = makeSUT()
    XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before view is loaded")

    sut.loadViewIfNeeded()
    XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view is loaded")

    sut.simulateUserInitiatedReload()
    XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected no request until previous completes")

    // complete first loading in 'sut.loadViewIfNeeded'
    loader.completeCommentsLoading(at: 0)
    sut.simulateUserInitiatedReload()
    XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected another loading request once user initiates a reload")

    loader.completeCommentsLoading(at: 1)
    sut.simulateUserInitiatedReload()
    XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected yet another loading request once user initiates another reload")
  }

  func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")

    loader.completeCommentsLoading(at: 0)
    XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")

    sut.simulateUserInitiatedReload()
    XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")

    loader.completeCommentsLoadingWithError(at: 1)
    XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
  }

  func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
    let comment0 = makeComment(message: "a message", username: "a username")
    let comment1 = makeComment(message: "another message", username: "another username")

    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    assertThat(sut, isRendering: [ImageComment]())

    loader.completeCommentsLoading(with: [comment0], at: 0)
    assertThat(sut, isRendering: [comment0])

    sut.simulateUserInitiatedReload()
    loader.completeCommentsLoading(with: [comment0, comment1], at: 1)
    assertThat(sut, isRendering: [comment0, comment1])
  }

  func test_loadCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
    let comment = makeComment()
    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    loader.completeCommentsLoading(with: [comment], at: 0)
    assertThat(sut, isRendering: [comment])

    sut.simulateUserInitiatedReload()
    loader.completeCommentsLoading(with: [], at: 1)
    assertThat(sut, isRendering: [ImageComment]())
  }

  func test_loadCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
    let comment = makeComment()
    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    loader.completeCommentsLoading(with: [comment], at: 0)
    assertThat(sut, isRendering: [comment])

    sut.simulateUserInitiatedReload()
    loader.completeCommentsLoadingWithError(at: 1)
    assertThat(sut, isRendering: [comment])
  }

  func test_loadCommentsCompletion_dispatchesFromBackgroundToMainThread() {
    let (sut, loader) = makeSUT()
    sut.loadViewIfNeeded()

    let exp = expectation(description: "Wait for background queue")
    DispatchQueue.global().async {
      loader.completeCommentsLoading(at: 0)
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }

  func test_loadCommentsCompletion_rendersErrorMessageOnErrorUntilNextReload() {
     let (sut, loader) = makeSUT()

     sut.loadViewIfNeeded()

     XCTAssertEqual(sut.errorMessage, nil)

    loader.completeCommentsLoadingWithError(at: 0)
    XCTAssertEqual(sut.errorMessage, loadError)

    sut.simulateUserInitiatedReload()
    XCTAssertEqual(sut.errorMessage, nil)
   }

  func test_tapOnErrorView_hidesErrorMessage() {
     let (sut, loader) = makeSUT()

     sut.loadViewIfNeeded()

     XCTAssertEqual(sut.errorMessage, nil)

    loader.completeCommentsLoadingWithError(at: 0)
    XCTAssertEqual(sut.errorMessage, loadError)

    sut.simulateErrorViewTap()
    XCTAssertEqual(sut.errorMessage, nil)
   }

  func test_deinit_cancelsRunningRequests() {
    var cancelCallCount = 0

    var sut: ListViewController?

    // we are using 'autoreleasepool' because when test is finished in fact memory is released ('trackForMemoryLeaks' checks that).
    // probably XCTest is running every test within its own 'autoreleasepool' and keep reference to it outside this test.
    // to control autoreleased lifetime we can create our own 'autoreleasepool' within the test that will only be released when we exit this test.
    autoreleasepool {
      // instantiate viewcontroller
      sut = CommentsUIComposer.commentsComposedWith(commentsLoader: {
        // because 'commentsLoader' is function that returns 'publishers' we need to create our own 'PassthroughSubject'
        PassthroughSubject<[ImageComment], Error>()
          .handleEvents(receiveCancel: {
            // and increment 'cancelCallCount' on cancel event (which should be triggered automatically once 'ListViewController' is de-initialized)
            cancelCallCount += 1
          }).eraseToAnyPublisher()
      })

      // will trigger loading method
      sut?.loadViewIfNeeded()
    }

    XCTAssertEqual(cancelCallCount, 0)

    // setting as 'nil' makes 'viewController' trigger 'deInit()' method which should automatically de-initialize and increment 'cancelCallCount'
    sut = nil

    XCTAssertEqual(cancelCallCount, 1)
  }

  //MARK: - Helpers

  private func makeSUT(file: StaticString = #filePath,
                       line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
    let loader = LoaderSpy()
    let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadPublisher)

    trackForMemoryLeaks(sut)
    trackForMemoryLeaks(loader)

    return (sut, loader)
  }

  private func makeComment(message: String = "any message", username: String = "any username") -> ImageComment {
    return ImageComment(id: UUID(), message: message, createdAt: Date(), username: username)
  }

  private func assertThat(_ sut: ListViewController, isRendering comments: [ImageComment], file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertEqual(sut.numberOfRenderedComments(), comments.count, "Comments count", file: file, line: line)

    // mapping 'comments' to 'viewModel' to be able use formatted 'date' for example.
    // depends on the case we can use 'presenters' and their 'map's' for converting 'data' to needed formats
    let viewModel = ImageCommentsPresenter.map(comments)

    viewModel.comments.enumerated().forEach { index, comment in
      XCTAssertEqual(sut.commentMessage(at: index), comment.message, "message at \(index)", file: file, line: line)
      XCTAssertEqual(sut.commentDate(at: index), comment.date, "date at \(index)", file: file, line: line)
      XCTAssertEqual(sut.commentUsername(at: index), comment.username, "username at \(index)", file: file, line: line)
    }
  }

  private class LoaderSpy {
    private var requests = [PassthroughSubject<[ImageComment], Error>]()

    var loadCommentsCallCount: Int {
      return requests.count
    }

    func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
      let publisher = PassthroughSubject<[ImageComment], Error>()
      requests.append(publisher)
      return publisher.eraseToAnyPublisher()
    }

    func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
      requests[index].send(comments)
      requests[index].send(completion: .finished)
    }

    func completeCommentsLoadingWithError(at index: Int = 0) {
      let error = NSError(domain: "an error", code: 0)
      requests[index].send(completion: .failure(error))
    }
  }
}
