//
//  FeedImageCell.swift
//  Prototype
//
//  Created by Aleksandr Kornjushko on 01.11.2022.
//

import UIKit

final class FeedImageCell: UITableViewCell {
  @IBOutlet private(set) var locationContainer: UIView!
  @IBOutlet private(set) var locationLabel: UILabel!
  @IBOutlet private(set) var feedImageView: UIImageView!
  @IBOutlet private(set) var descriptionLabel: UILabel!
}
