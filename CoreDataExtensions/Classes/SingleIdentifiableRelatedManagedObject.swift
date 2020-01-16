//
//  SingleIdentifiableRelatedManagedObject.swift
//  CoreDataExtensions
//
//  Created by Johannes Dörr on 26.06.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import Foundation
import CoreData

public enum SingleRelatedEntityIdentifier {
    case any
}

/**
 Represents a model class that has exactly one relationship to `Entity`.
 */
public protocol SingleIdentifiableRelatedManagedObject: IdentifiableRelatedManagedObject {
    associatedtype RelatedEntityIdentifier = SingleRelatedEntityIdentifier
    static func predicate(relatedEntityID: RelatedID, relatedParameters: RelatedParameters) -> NSPredicate
    static func entityCount(relatedParameters: RelatedParameters) -> Int?
}

extension SingleIdentifiableRelatedManagedObject where Self: NSManagedObject, RelatedEntityIdentifier == SingleRelatedEntityIdentifier {
    public static func predicate(relatedEntityID: RelatedID, relatedEntityIdentifier: RelatedEntityIdentifier, relatedParameters: RelatedParameters) -> NSPredicate {
        return predicate(relatedEntityID: relatedEntityID, relatedParameters: relatedParameters)
    }

    public static func entityCount(for relatedEntityIdentifier: RelatedEntityIdentifier, relatedParameters: RelatedParameters) -> Int? {
        return entityCount(relatedParameters: relatedParameters)
    }

    public static func entityCount(relatedParameters: RelatedParameters) -> Int? {
        return 1
    }

    public static func fetchRequest<ResultType>(forRelatedEntityID id: RelatedID, relatedParameters: RelatedParameters) -> NSFetchRequest<ResultType> where ResultType: NSManagedObject {
        return fetchRequest(forRelatedEntityID: id, identifier: .any, relatedParameters: relatedParameters) as NSFetchRequest<ResultType>
    }

    public static func fetch<ResultType>(relatedEntityID id: RelatedID, relatedParameters: RelatedParameters) -> [ResultType] where ResultType: NSManagedObject {
        return fetch(relatedEntityID: id, identifier: .any, relatedParameters: relatedParameters) as [ResultType]
    }

    public static func fetch<ResultType>(relatedEntityID id: RelatedID, relatedParameters: RelatedParameters) -> ResultType? where ResultType: NSManagedObject {
        return fetch(relatedEntityID: id, identifier: .any, relatedParameters: relatedParameters) as ResultType?
    }
}
