//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Aleksandr Kornjushko on 04.11.2022.
//

import UIKit

extension UIButton {
  func simulateTap() {
    simulate(event: .touchUpInside)
  }
}
