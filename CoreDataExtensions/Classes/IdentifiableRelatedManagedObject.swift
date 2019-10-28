//
//  EntityRelated.swift
//  CoreDataExtensions
//
//  Created by Johannes Dörr on 26.06.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import Foundation
import CoreData

/**
 Represents a model class that has one or more relationships to `IdentifiableManagedObject`.
 Classes should use the generic functions `fetchRequest<ResultType>(forEntityWithID:, identifier:)` and
 `fetch<ResultType>(entityWithID:, identifier:)` to implement custom `fetchRequest(for<...>ID:)` and `fetch(<...>ID:)`
 functions that have the correct return type, for example `ReadSyncInfo`, so that they can be used
 without type casting. If the class relates to multiple entities, use different identifiers to distinguish.
 */
public protocol IdentifiableRelatedManagedObject {
    associatedtype RelatedID: CVarArg
    associatedtype RelatedEntityIdentifier

    /**
     Returns the predicate to filter the items that belong to the related entity
     Parameter entityID: The id of the related entity
     Parameter entityIdentifier: A custom identifier of the entity, in case the class is related to multiple entities
     */
    static func predicate(relatedEntityID: RelatedID, relatedEntityIdentifier: RelatedEntityIdentifier) -> NSPredicate

    /**
     Returns nil in case of a to-many relationship, and 1 in case of a foreign key
     Parameter identifier: A custom identifier of the entity, in case the class is related to multiple entities
     Note: This function returns the number of items of this class, that can belong to the entity. For example, there
     is an unlimited number of ChannelMessage (conforming to IdentifiableRelatedManagedObject) for a Channel (conforming to IdentifiableManagedObject). But there
     is only one ChannelReadInfo (conforming to IdentifiableRelatedManagedObject).
     */
    static func entityCount(for relatedEntityIdentifier: RelatedEntityIdentifier) -> Int?
}

extension IdentifiableRelatedManagedObject where Self: NSManagedObject {
    public static func entityCount(for relatedEntityIdentifier: RelatedEntityIdentifier) -> Int? {
        return 1
    }

    /**
     Creates a FetchRequest using the given entity ID
     - Parameter id: The id of the related entity
     */
    public static func fetchRequest<ResultType>(forRelatedEntityID id: RelatedID, identifier: RelatedEntityIdentifier) -> NSFetchRequest<ResultType> where ResultType: NSManagedObject {
        // XXX: entity().name is optional and sometimes nil, so we fall back to the class name in that case
        let entityName = ResultType.entity().name ?? String(describing: self)
        let request: NSFetchRequest<ResultType> = NSFetchRequest(entityName: entityName)
        request.predicate = Self.predicate(relatedEntityID: id, relatedEntityIdentifier: identifier)
        if let limit = Self.entityCount(for: identifier) {
            request.fetchLimit = limit
        }
        return request
    }

    /**
     Fetches objects that belong to the given entity
     - Parameter id: The id of the related entity
     */
    public static func fetch<ResultType>(relatedEntityID id: RelatedID, identifier: RelatedEntityIdentifier) -> [ResultType] where ResultType: NSManagedObject {
        let request: NSFetchRequest<ResultType> = fetchRequest(forRelatedEntityID: id, identifier: identifier)
        return (try? request.execute()) ?? []
    }

    /**
     Fetches an object that belongs to the given entity
     - Parameter id: The id of the related entity
     */
    public static func fetch<ResultType>(relatedEntityID id: RelatedID, identifier: RelatedEntityIdentifier) -> ResultType? where ResultType: NSManagedObject {
        return fetch(relatedEntityID: id, identifier: identifier).first
    }
}
