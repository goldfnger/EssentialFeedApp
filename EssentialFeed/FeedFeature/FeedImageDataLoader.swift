//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Aleksandr Kornjushko on 04.11.2022.
//

import Foundation

public protocol FeedImageDataLoader {
  func loadImageData(from url: URL) throws -> Data
}
