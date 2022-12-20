//
//  WeakRefVirtualProxy.swift
//  EssentialFeediOS
//
//  Created by Aleksandr Kornjushko on 14.11.2022.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class WeakRefVirtualProxy<T: AnyObject> {
  private weak var object: T?

  init(_ object: T) {
    self.object = object
  }
}

extension WeakRefVirtualProxy: ResourceErrorView where T: ResourceErrorView {
   func display(_ viewModel: ResourceErrorViewModel) {
     object?.display(viewModel)
   }
 }

extension WeakRefVirtualProxy: ResourceLoadingView where T: ResourceLoadingView {
  func display(_ viewModel: ResourceLoadingViewModel) {
    object?.display(viewModel)
  }
}

// replace 'FeedImageView' with a generic 'ResourceView' and set 'ResourceViewModel' to UIImage. When we are presenting the image data the view model is a UIImage that will be converted from data
extension WeakRefVirtualProxy: ResourceView where T: ResourceView, T.ResourceViewModel == UIImage {
  func display(_ model: UIImage) {
    object?.display(model)
  }
}
