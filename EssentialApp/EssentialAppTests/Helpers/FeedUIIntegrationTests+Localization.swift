//
//  FeedViewControllerTests+Localization.swift
//  EssentialFeediOSTests
//
//  Created by Aleksandr Kornjushko on 11.11.2022.
//

import Foundation
import XCTest
import EssentialFeed

extension FeedUIIntegrationTests {
  private class DummyView: ResourceView {
    func display(_ viewModel: Any) {}
  }

  var loadError: String {
    // we expose loadError in LoadResourcePresenter by making it "public static"
    LoadResourcePresenter<Any, DummyView>.loadError
  }

  var feedTitle: String {
    FeedPresenter.title
  }
}
