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
 Classes should use the generic functions `fetchRequest<ResultType>(forEntityWithID:, identifier:, relatedParameters:)` and
 `fetch<ResultType>(entityWithID:, identifier:, relatedParameters:)` to implement custom `fetchRequest(for<...>ID:)`
 and `fetch(<...>ID:)` functions that have the correct return type, for example `ReadSyncInfo`, so that they can be used without type casting.
 If the class relates to multiple entities, use different identifiers to distinguish. If the custom fetch functions should have additional parameters (for example
 "language"), use relatedParameters to pass them to the generic fetch functions.
 */
public protocol IdentifiableRelatedManagedObject {
    associatedtype RelatedID: CVarArg
    associatedtype RelatedEntityIdentifier
    associatedtype RelatedParameters

    /**
     Returns the predicate to filter the items that belong to the related entity
     - Parameter entityID: The id of the related entity
     - Parameter entityIdentifier: A custom identifier of the entity, in case the class is related to multiple entities
     - Parameter relatedParameters: Additional parameters passed to `fetchRequest(...)`
     */
    static func predicate(relatedEntityID: RelatedID, relatedEntityIdentifier: RelatedEntityIdentifier, relatedParameters: RelatedParameters) -> NSPredicate

    /**
     Returns nil in case of a to-many relationship, and 1 in case of a foreign key
     - Parameter identifier: A custom identifier of the entity, in case the class is related to multiple entities
     - Parameter relatedParameters: Additional parameters passed to `fetchRequest(...)`
     - Note: This function returns the number of items of this class, that can belong to the entity. For example, there
     is an unlimited number of ChannelMessage (conforming to IdentifiableRelatedManagedObject) for a Channel (conforming to IdentifiableManagedObject). But there
     is only one ChannelReadInfo (conforming to IdentifiableRelatedManagedObject).
     */
    static func entityCount(for relatedEntityIdentifier: RelatedEntityIdentifier, relatedParameters: RelatedParameters) -> Int?
}

extension IdentifiableRelatedManagedObject where Self: NSManagedObject {
    public static func entityCount(for relatedEntityIdentifier: RelatedEntityIdentifier, relatedParameters: RelatedParameters) -> Int? {
        return 1
    }

    /**
     Creates a FetchRequest using the given entity ID
     - Parameter id: The id of the related entity
     - Parameter identifier: A custom identifier of the entity, in case the class is related to multiple entities
     - Parameter relatedParameters: Additional parameters to be passed to `predicate(...)`
     */
    public static func fetchRequest<ResultType>(forRelatedEntityID id: RelatedID, identifier: RelatedEntityIdentifier, relatedParameters: RelatedParameters) -> NSFetchRequest<ResultType> where ResultType: NSManagedObject {
        // XXX: entity().name is optional and sometimes nil, so we fall back to the class name in that case
        let entityName = ResultType.entity().name ?? String(describing: self)
        let request: NSFetchRequest<ResultType> = NSFetchRequest(entityName: entityName)
        request.predicate = Self.predicate(relatedEntityID: id, relatedEntityIdentifier: identifier, relatedParameters: relatedParameters)
        if let limit = Self.entityCount(for: identifier, relatedParameters: relatedParameters) {
            request.fetchLimit = limit
        }
        return request
    }

    /**
     Fetches objects that belong to the given entity
     - Parameter id: The id of the related entity
     - Parameter identifier: A custom identifier of the entity, in case the class is related to multiple entities
     - Parameter relatedParameters: Additional parameters to be passed to `predicate(...)`
     */
    public static func fetch<ResultType>(relatedEntityID id: RelatedID, identifier: RelatedEntityIdentifier, relatedParameters: RelatedParameters) -> [ResultType] where ResultType: NSManagedObject {
        let request: NSFetchRequest<ResultType> = fetchRequest(forRelatedEntityID: id, identifier: identifier, relatedParameters: relatedParameters)
        return (try? request.execute()) ?? []
    }

    /**
     Fetches an object that belongs to the given entity
     - Parameter id: The id of the related entity
     - Parameter identifier: A custom identifier of the entity, in case the class is related to multiple entities
     - Parameter relatedParameters: Additional parameters to be passed to `predicate(...)`
     */
    public static func fetch<ResultType>(relatedEntityID id: RelatedID, identifier: RelatedEntityIdentifier, relatedParameters: RelatedParameters) -> ResultType? where ResultType: NSManagedObject {
        return fetch(relatedEntityID: id, identifier: identifier, relatedParameters: relatedParameters).first
    }
}
