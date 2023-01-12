//
//  ManagedCache.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 26.10.2022.
//

import CoreData

@objc(ManagedCache)
final class ManagedCache: NSManagedObject {
  @NSManaged var timestamp: Date
  @NSManaged var feed: NSOrderedSet
}

extension ManagedCache {
  static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
    let request = NSFetchRequest<ManagedCache>(entityName: entity().name!)
    request.returnsObjectsAsFaults = false
    return try context.fetch(request).first
  }

  static func deleteCache(in context: NSManagedObjectContext) throws {
    try find(in: context).map(context.delete).map(context.save)
  }

  static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
    try deleteCache(in: context)
    return ManagedCache(context: context)
  }

  var localFeed: [LocalFeedImage] {
    return feed.compactMap { ($0 as? ManagedFeedImage)?.local }
  }
}
