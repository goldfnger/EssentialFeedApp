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
  private weak var controller: FeedViewController?
  private let imageLoader: (URL) -> FeedImageDataLoader.Publisher

  init(controller: FeedViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
    self.controller = controller
    self.imageLoader = imageLoader
  }

  func display(_ viewModel: FeedViewModel) {
    controller?.display(viewModel.feed.map { model in
      // pass a custom closure 'loader: {}' that calls the image loader with the model URL - we are adapting the image loader method that takes one parameter '(URL)' into a method that takes no parameters and it holds the model URL (also called partial application of functions)
      let adapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>(loader: { [imageLoader] in
        imageLoader(model.url)
      })

      // because model is already immutable we can pass here the view model at construction time (things that dont change can be passed at initialization time) (things that change overtime you pass either through property or method injection)
      // adapter implements the cell controller delegate to run the generic load resource logic
      let view = FeedImageCellController(
        viewModel: FeedImagePresenter<FeedImageCellController, UIImage>.map(model),
        delegate: adapter)

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

      return view
    })
  }
}

private struct InvalidImageData: Error {}
