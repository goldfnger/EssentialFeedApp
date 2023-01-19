//
//  FeedViewControllerTests+LoaderSpy.swift
//  EssentialFeediOSTests
//
//  Created by Aleksandr Kornjushko on 04.11.2022.
//

import Foundation
import EssentialFeed
import EssentialFeediOS
import Combine

extension FeedUIIntegrationTests {

  class LoaderSpy {

    //MARK: - FeedLoader
    private var feedRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()

    var loadFeedCallCount: Int {
      return feedRequests.count
    }

    func loadPublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
      let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
      feedRequests.append(publisher)
      return publisher.eraseToAnyPublisher()
    }

    func completeFeedLoadingWithError(at index: Int = 0) {
      feedRequests[index].send(completion: .failure(anyNSError()))
    }

    func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
      feedRequests[index].send(Paginated(items: feed, loadMorePublisher: { [weak self] in
        self?.loadMorePublisher() ?? Empty().eraseToAnyPublisher()
      }))
      // in our 'test spy' we 'never complete' our 'publishers', we only send 'values' to it. so the way publishers work we can send multiple values to a publisher until it completes or until u got a failure.
      // so as soon as we send a value to our publisher with complete loading we can also send a completion to tell it we finished.
      feedRequests[index].send(completion: .finished)
    }

    //MARK: - LoadMoreFeedLoader

    private var loadMoreRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()

    var loadMoreCallCount: Int {
      return loadMoreRequests.count
    }

    func loadMorePublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
      // now instead of counting we need to create a publishers
      // because it is expect a 'closure', but we are returning 'publishers' so we need to create a 'bridge'
      let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
      loadMoreRequests.append(publisher)
      return publisher.eraseToAnyPublisher()
    }

    // when we completing more we are going to
    func completeLoadMore(with feed: [FeedImage] = [], lastPage: Bool = false, at index: Int = 0) {
      // complete the load more reuqest at a give index with the paginged plus a loadMorePublisher
      loadMoreRequests[index].send(Paginated(
        items: feed,
        // if it is last page(true) we return nil, we dont have more items to load, otherwise we create a new publisher
        loadMorePublisher: lastPage ? nil : { [weak self] in
          self?.loadMorePublisher() ?? Empty().eraseToAnyPublisher()
      }))
    }

    func completeLoadMoreWithError(at index: Int = 0) {
      loadMoreRequests[index].send(completion: .failure(anyNSError()))
    }

    //MARK: - FeedImageDataLoader
    private var imageRequests = [(url: URL, publisher: PassthroughSubject<Data, Error>)]()

    var loadedImageURLs: [URL] {
      return imageRequests.map { $0.url }
    }

    private(set) var cancelledImageURLs = [URL]()

    func loadImageDataPublisher(from url: URL) -> AnyPublisher<Data, Error> {
      let publisher = PassthroughSubject<Data, Error>()
      imageRequests.append((url, publisher))
      return publisher.handleEvents(receiveCancel: { [weak self] in
        self?.cancelledImageURLs.append(url)
      }).eraseToAnyPublisher()
    }

    func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
      imageRequests[index].publisher.send(imageData)
      imageRequests[index].publisher.send(completion: .finished)
    }

    func completeImageLoadingWithError(at index: Int = 0) {
      imageRequests[index].publisher.send(completion: .failure(anyNSError()))
    }
  }
}
