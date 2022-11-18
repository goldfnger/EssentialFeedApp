//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Aleksandr Kornjushko on 18.11.2022.
//

import UIKit

extension UIRefreshControl {
  func update(isRefreshing: Bool) {
    isRefreshing ? beginRefreshing() : endRefreshing()
  }
}
