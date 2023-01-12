//
//  ManagedFeedImage.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 26.10.2022.
//

import CoreData

@objc(ManagedFeedImage)
final class ManagedFeedImage: NSManagedObject {
  @NSManaged var id: UUID
  @NSManaged var imageDescription: String?
  @NSManaged var location: String?
  @NSManaged var url: URL
  @NSManaged var data: Data?
  @NSManaged var cache: ManagedCache
}

extension ManagedFeedImage {
  static func data(with url: URL, in context: NSManagedObjectContext) throws -> Data?{
    return try first(with: url, in: context)?.data
  }
  
  static func first(with url: URL, in context: NSManagedObjectContext) throws -> ManagedFeedImage? {
    let request = NSFetchRequest<ManagedFeedImage>(entityName: entity().name!)
    request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ManagedFeedImage.url), url])
    request.returnsObjectsAsFaults = false
    request.fetchLimit = 1
    return try context.fetch(request).first
  }

  static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
    return NSOrderedSet(array: localFeed.map { local in
      let managed = ManagedFeedImage(context: context)
      managed.id = local.id
      managed.imageDescription = local.description
      managed.location = local.location
      managed.url = local.url
      return managed
    })
  }

  var local: LocalFeedImage {
    return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
  }
}
