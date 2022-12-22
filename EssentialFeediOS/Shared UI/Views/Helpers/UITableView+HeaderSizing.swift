//
//  UITableView+HeaderSizing.swift
//  EssentialFeediOS
//
//  Created by Aleksandr Kornjushko on 12.12.2022.
//

import UIKit

extension UITableView {
  // will resize table header to properly fit element inside it
  func sizeTableHeaderToFit() {
    guard let header = tableHeaderView else { return }

    let size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

    let needFrameUpdate = header.frame.height != size.height
    if needFrameUpdate {
      header.frame.size.height = size.height
      tableHeaderView = header
    }
  }
}
