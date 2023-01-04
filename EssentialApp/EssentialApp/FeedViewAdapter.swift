//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Aleksandr Kornjushko on 14.11.2022.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: ResourceView {
  private weak var controller: ListViewController?
  private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
  private let selection: (FeedImage) -> Void

  private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>

  init(controller: ListViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher, selection: @escaping (FeedImage) -> Void) {
    self.controller = controller
    self.imageLoader = imageLoader
    self.selection = selection
  }

  // now should use Paginated<FeedImage> where we can access whole list of 'FeedImage' 'items'
  func display(_ viewModel: Paginated<FeedImage>) {
    controller?.display(viewModel.items.map { model in
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

      adapter.presenter = LoadResourcePresenter(
        resourceView: WeakRefVirtualProxy(view),
        loadingView: WeakRefVirtualProxy(view),
        errorView: WeakRefVirtualProxy(view),
        mapper: { data in
          guard let image = UIImage(data: data) else {
            throw InvalidImageData()
          }
          return image
        })

      // because 'CellController' now is a struct and because 'FeedImageCellController' implements all 3 protocols(defined in 'CellController') we can pass simply one 'view' and init() will set all 3 sources internally.
      // If we dont care about 'delegate' and 'dataSourcePrefetching' we can use another init() which will internally set mandatory 'dataSource' and others will set as 'nil'
      // adding 'id' with 'Hashable' model will automatically tell UI to redraw that cell if any changes happens to the model. (diffable data source).
      return CellController(id: model, view)
    })
  }
}

private struct InvalidImageData: Error {}
