//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Aleksandr Kornjushko on 21.12.2022.
//

import UIKit
import EssentialFeed

// to implement CellController UIKit protocols we need to be an NSObject
public class ImageCommentCellController: NSObject, UITableViewDataSource {
  private let model: ImageCommentViewModel

  public init(model: ImageCommentViewModel) {
    self.model = model
  }

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // it only manages one cell (each cell controller manages one cell for one model)
    1
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: ImageCommentCell = tableView.dequeueReusableCell()
    cell.messageLabel.text = model.message
    cell.usernameLabel.text = model.username
    cell.dateLabel.text = model.date

    return cell
  }
}
