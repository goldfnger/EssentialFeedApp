//
//  UIWindowSpy.swift
//  EssentialAppTests
//
//  Created by Aleksandr Kornjushko on 13.12.2022.
//

import UIKit

public final class UIWindowSpy: UIWindow {
  var makeKeyAndVisibleCallCount = 0

  public override func makeKeyAndVisible() {
    makeKeyAndVisibleCallCount = 1
  }
}
