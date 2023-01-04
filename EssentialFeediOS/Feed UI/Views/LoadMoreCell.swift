//
//  LoadMoreCell.swift
//  EssentialFeediOS
//
//  Created by Aleksandr Kornjushko on 04.01.2023.
//

import UIKit

// we are creating separate cell with 'spinner' indicator which later will be injected in the end of tableView 
public class LoadMoreCell: UITableViewCell {

  private lazy var spinner: UIActivityIndicatorView = {
    let spinner = UIActivityIndicatorView(style: .medium)
    contentView.addSubview(spinner)

    spinner.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      contentView.heightAnchor.constraint(lessThanOrEqualToConstant: 40)
    ])

    return spinner
  }()

  public var isLoading: Bool {
    // getting status of spinner if it is animating or not
    get { spinner.isAnimating }
    set {
      // if isLoading
      if newValue {
        spinner.startAnimating()
      } else {
        spinner.stopAnimating()
      }
    }
  }
}
