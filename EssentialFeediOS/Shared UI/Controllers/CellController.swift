//
//  CellController.swift
//  EssentialFeediOS
//
//  Created by Aleksandr Kornjushko on 21.12.2022.
//

import UIKit

// currently dataSource is the only mandatory to implement, but 'delegate' and 'dataSourcePrefetching' are not.
// we change 'typealias' to 'struct' to provide default implementations (that will help us provide only needed implementations)
public struct CellController {
  // identifier to use 'Hashable' for data comparison
  let id: AnyHashable
  let dataSource: UITableViewDataSource
  let delegate: UITableViewDelegate?
  let dataSourcePrefetching: UITableViewDataSourcePrefetching?

  // if we have a case with a type that implements all of them (like a 'FeedImageCellController')
  public init(id: AnyHashable, _ dataSource: UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching) {
    self.id = id
    self.dataSource = dataSource
    self.delegate = dataSource
    self.dataSourcePrefetching = dataSource
  }

  // if we have a case with a type that implements only dataSource (like a 'ImageCommentCellController')
  public init(id: AnyHashable, _ dataSource: UITableViewDataSource) {
    self.id = id
    self.dataSource = dataSource
    self.delegate = nil
    self.dataSourcePrefetching = nil
  }
}

// we are making 'CellController' as 'Hashable' & 'Equatable' to be able to compare which data has changed or not to eliminate necessary to reload whole table view, only what has changed
// 'Hashable' will define its identity and equality
extension CellController: Equatable {
  public static func == (lhs: CellController, rhs: CellController) -> Bool {
    lhs.id == rhs.id
  }
}

extension CellController: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
