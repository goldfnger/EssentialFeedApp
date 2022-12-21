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
  let dataSource: UITableViewDataSource
  let delegate: UITableViewDelegate?
  let dataSourcePrefetching: UITableViewDataSourcePrefetching?

  // if we have a case with a type that implements all of them (like a 'FeedImageCellController')
  public init(_ dataSource: UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching) {
    self.dataSource = dataSource
    self.delegate = dataSource
    self.dataSourcePrefetching = dataSource
  }

  // if we have a case with a type that implements only dataSource
  public init(_ dataSource: UITableViewDataSource) {
    self.dataSource = dataSource
    self.delegate = nil
    self.dataSourcePrefetching = nil
  }
}
