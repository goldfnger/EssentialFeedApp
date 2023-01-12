//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Aleksandr Kornjushko on 14.11.2022.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

// here we create a cell controllers
final class FeedViewAdapter: ResourceView {
  private weak var controller: ListViewController?
  private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
  private let selection: (FeedImage) -> Void

  private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
  private typealias LoadMorePresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>

  init(controller: ListViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher, selection: @escaping (FeedImage) -> Void) {
    self.controller = controller
    self.imageLoader = imageLoader
    self.selection = selection
  }

  // now should use Paginated<FeedImage> where we can access whole list of 'FeedImage' 'items'
  func display(_ viewModel: Paginated<FeedImage>) {
    // here we have an array of 'CellController's for the 'feed' which is the first section(0) 'feed'
    let feed: [CellController] = viewModel.items.map { model in
      // pass a custom closure 'loader: {}' that calls the image loader with the model URL - we are adapting the image loader method that takes one parameter '(URL)' into a method that takes no parameters and it holds the model URL (also called partial application of functions)
      let adapter = ImageDataPresentationAdapter(loader: { [imageLoader] in
        imageLoader(model.url)
      })

      // because model is already immutable we can pass here the view model at construction time (things that dont change can be passed at initialization time) (things that change overtime you pass either through property or method injection)
      // adapter implements the cell controller delegate to run the generic load resource logic
      let view = FeedImageCellController(
        viewModel: FeedImagePresenter.map(model),
        delegate: adapter,
        // when there is a 'selection' the 'FeedViewAdapter' now he has the 'FeedImage' model
        // so now we get the selection closure
        selection: { [selection] in
          // and we pass the 'FeedImage' model to it. (for that we need a 'selection' 'initlizer')
          selection(model)
        })

      // we are using view for all 'resourceView, loadingView, errorView' because 'view' is implementing all 'ResourceView, ResourceLoadingView, ResourceErrorView' protocols (if it would not then we would have to create something like 'loadMore')
      adapter.presenter = LoadResourcePresenter(
        resourceView: WeakRefVirtualProxy(view),
        loadingView: WeakRefVirtualProxy(view),
        errorView: WeakRefVirtualProxy(view),
        mapper: UIImage.tryMake)

      // because 'CellController' now is a struct and because 'FeedImageCellController' implements all 3 protocols(defined in 'CellController') we can pass simply one 'view' and init() will set all 3 sources internally.
      // If we dont care about 'delegate' and 'dataSourcePrefetching' we can use another init() which will internally set mandatory 'dataSource' and others will set as 'nil'
      // adding 'id' with 'Hashable' model will automatically tell UI to redraw that cell if any changes happens to the model. (diffable data source).
      return CellController(id: model, view)
    }

    // if we have 'loadMorePublisher' then we create 'loadMoreAdapter' and we create our 'presenter'
    guard let loadMorePublisher = viewModel.loadMorePublisher else {
      // we need complete with the current feed if we dont have load more (we do not append the load more section)
      controller?.display(feed)
      return
    }

    // in case confusing worth to re-watch live#002
    let loadMoreAdapter = LoadMorePresentationAdapter(loader: loadMorePublisher)

    /*
    let loadMore = LoadMoreCellController {
      // every time we call 'callback' we need to call 'viewModel.loadMore' 'callback'
      viewModel.loadMore?({ _ in })
    }
     */
    // here we need to 'create' a new 'section' into the cell controllers
    // now here we should use the adapter 'loadResource' method instead of calling 'loadMore' every time
    // because the 'loadResource' in the adapter is the one that we will call the 'loadMorePublisher' and handle all the state transitions with the presenter
    let loadMore = LoadMoreCellController(callback: loadMoreAdapter.loadResource)

    loadMoreAdapter.presenter = LoadResourcePresenter(
      // because in 'loadMoreAdapter' as view set 'FeedViewAdapter' which is the same type that is creating so if we are loading more we can reuse the current existing view (FeedViewAdapter) and just pass self.
      resourceView: self,
      // 'loadingView' is the 'LoadMoreCellController'
      loadingView: WeakRefVirtualProxy(loadMore),
      // 'errorView' is the'LoadMoreCellController'
      errorView: WeakRefVirtualProxy(loadMore),
      // actually we dont need a mapper, so just pass the result forward
      mapper: { $0 })

    // creating a second 'section' which is an array of the 'CellControllers' with only one item 'CellController' where 'dataSource' is 'loadMore'
    // LoadMoreCellController conforms to 'UITableViewDataSource' thats why we can use it
    let loadMoreSection = [CellController(id: UUID(), loadMore)]

    // here we separate into sections
    controller?.display(feed, loadMoreSection)
  }
}

extension UIImage {
  struct InvalidImageData: Error {}

  static func tryMake(data: Data) throws -> UIImage {
    guard let image = UIImage(data: data) else {
      throw InvalidImageData()
    }
    return image
  }
}
