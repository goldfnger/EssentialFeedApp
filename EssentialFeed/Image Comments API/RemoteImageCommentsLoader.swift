//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 16.12.2022.
//

import Foundation

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
  convenience init(url: URL, client: HTTPClient) {
    self.init(url: url, client: client, mapper: ImageCommentsMapper.map)
  }
}
