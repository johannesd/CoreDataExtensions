//
//  LocallyIdentifiableRelatedManagedObject.swift
//  CoreDataExtensions
//
//  Created by Johannes Dörr on 26.10.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import Foundation
import CoreData

/**
 Represents a model class that has one or more relationships to `LocallyIdentifiableManagedObject`.
 Classes should use the generic functions `fetchRequest<ResultType>(forEntityWithLocalID:, identifier:, relatedParameters:)` and
 `fetch<ResultType>(entityWithLocalID:, identifier:, relatedParameters:)` to implement custom `fetchRequest(for<...>LocalID:)`
 and `fetch(<...>LocalID:)` functions that have the correct return type, for example `ReadSyncInfo`, so that they can be used without type casting.
 If the class relates to multiple entities, use different identifiers to distinguish. If the custom fetch functions should have additional parameters (for example "language"),
 use relatedParameters to pass them to the generic fetch functions.
 */
public protocol LocallyIdentifiableRelatedManagedObject {
    associatedtype RelatedLocalID: CVarArg
    associatedtype RelatedLocalEntityIdentifier
    associatedtype RelatedLocalParameters

    /**
     Returns the predicate to filter the items that belong to the related local entity
     - Parameter entityLocalID: The localID of the related entity
     - Parameter entityIdentifier: A custom identifier of the entity, in case the class is related to multiple entities
     - Parameter relatedParameters: Additional parameters passed to `fetchRequest(...)`
     */
    static func predicate(relatedLocalEntityID: RelatedLocalID, relatedLocalEntityIdentifier: RelatedLocalEntityIdentifier, relatedParameters: RelatedLocalParameters) -> NSPredicate

    /**
     Returns nil in case of a to-many relationship, and 1 in case of a foreign key
     - Parameter identifier: A custom identifier of the entity, in case the class is related to multiple entities
     - Parameter relatedParameters: Additional parameters passed to `fetchRequest(...)`
     - Note: This function returns the number of items of this class, that can belong to the entity. For example, there
     is an unlimited number of ChannelMessage (conforming to LocallyIdentifiableRelatedManagedObject) for a Channel (conforming to LocallyIdentifiableManagedObject). But there
     is only one ChannelReadInfo (conforming to LocallyIdentifiableRelatedManagedObject).
     */
    static func localEntityCount(for identifier: RelatedLocalEntityIdentifier, relatedParameters: RelatedLocalParameters) -> Int?
}

extension LocallyIdentifiableRelatedManagedObject where Self: NSManagedObject {
    public static func localEntityCount(for identifier: RelatedLocalEntityIdentifier) -> Int? {
        return 1
    }

    /**
     Creates a FetchRequest using the given entity ID
     - Parameter id: The id of the entity
     - Parameter identifier: A custom identifier of the entity, in case the class is related to multiple entities
     - Parameter relatedParameters: Additional parameters to be passed to `predicate(...)`
     */
    public static func fetchRequest<ResultType>(forRelatedLocalEntityID localID: RelatedLocalID, identifier: RelatedLocalEntityIdentifier, relatedParameters: RelatedLocalParameters) -> NSFetchRequest<ResultType> where ResultType: NSManagedObject {
        // XXX: entity().name is optional and sometimes nil, so we fall back to the class name in that case
        let entityName = ResultType.entity().name ?? String(describing: self)
        let request: NSFetchRequest<ResultType> = NSFetchRequest(entityName: entityName)
        request.predicate = Self.predicate(relatedLocalEntityID: localID, relatedLocalEntityIdentifier: identifier, relatedParameters: relatedParameters)
        if let limit = Self.localEntityCount(for: identifier) {
            request.fetchLimit = limit
        }
        return request
    }

    /**
     Fetches objects that belong to the given entity
     - Parameter id: The id of the entity
     - Parameter identifier: A custom identifier of the entity, in case the class is related to multiple entities
     - Parameter relatedParameters: Additional parameters to be passed to `predicate(...)`
     */
    public static func fetch<ResultType>(relatedLocalEntityID localID: RelatedLocalID, identifier: RelatedLocalEntityIdentifier, relatedParameters: RelatedLocalParameters) -> [ResultType] where ResultType: NSManagedObject {
        let request: NSFetchRequest<ResultType> = fetchRequest(forRelatedLocalEntityID: localID, identifier: identifier, relatedParameters: relatedParameters)
        return (try? request.execute()) ?? []
    }

    /**
     Fetches an object that belongs to the given entity
     - Parameter id: The id of the entity
     - Parameter identifier: A custom identifier of the entity, in case the class is related to multiple entities
     - Parameter relatedParameters: Additional parameters to be passed to `predicate(...)`
     */
    public static func fetch<ResultType>(relatedLocalEntityID localID: RelatedLocalID, identifier: RelatedLocalEntityIdentifier, relatedParameters: RelatedLocalParameters) -> ResultType? where ResultType: NSManagedObject {
        return fetch(relatedLocalEntityID: localID, identifier: identifier, relatedParameters: relatedParameters).first
    }
}
