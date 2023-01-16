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
  // when loading data as well as we load the cells
  static func data(with url: URL, in context: NSManagedObjectContext) throws -> Data? {
    // we try to look for the in-memory 'temporary lookup' for data for the URL and use it instead of making database request which is much slower,
    // because 'dictionary lookup' is constant time which is much faster then a DB query.
    // will return 'data' 'immediately', but if not then  'first()' request will be fired.
    if let data = context.userInfo[url] as? Data { return data }

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
    // first we create the new collection of images
    let images = NSOrderedSet(array: localFeed.map { local in
      let managed = ManagedFeedImage(context: context)
      managed.id = local.id
      managed.imageDescription = local.description
      managed.location = local.location
      managed.url = local.url
      // when we are creating new images we can try to find data for that URL in the 'temporary' cache
      managed.data = context.userInfo[local.url] as? Data
      return managed
    })
    // then clear 'temporary lookup' data
    context.userInfo.removeAllObjects()
    return images
  }

  var local: LocalFeedImage {
    return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
  }

  // invoked right before deletion
  override func prepareForDeletion() {
    super.prepareForDeletion()

    // just a 'temporary lookup' 'dictionary' which is not persisted to disk
    // we have data 'temporary' in the 'userInfo' dictionary
    managedObjectContext?.userInfo[url] = data
  }
}
