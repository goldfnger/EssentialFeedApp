//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Aleksandr Kornjushko on 26.10.2022.
//

import CoreData

public final class CoreDataFeedStore {
  private let container: NSPersistentContainer
  private let context: NSManagedObjectContext

  public init(storeURL: URL, bundle: Bundle = .main) throws {
    container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL,  in: bundle)
    context = container.newBackgroundContext()
  }

  func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
    context.perform { [context] in action(context) }
  }
}
