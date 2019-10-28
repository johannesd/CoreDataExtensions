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
    static func predicate(relatedEntityID: RelatedID) -> NSPredicate
    static func entityCount() -> Int?
}

extension SingleIdentifiableRelatedManagedObject where Self: NSManagedObject, RelatedEntityIdentifier == SingleRelatedEntityIdentifier {
    public static func predicate(relatedEntityID: RelatedID, relatedEntityIdentifier: RelatedEntityIdentifier) -> NSPredicate {
        return predicate(relatedEntityID: relatedEntityID)
    }

    public static func entityCount(for relatedEntityIdentifier: RelatedEntityIdentifier) -> Int? {
        return entityCount()
    }

    public static func entityCount() -> Int? {
        return 1
    }

    public static func fetchRequest<ResultType>(forRelatedEntityID id: RelatedID) -> NSFetchRequest<ResultType> where ResultType: NSManagedObject {
        return fetchRequest(forRelatedEntityID: id, identifier: .any) as NSFetchRequest<ResultType>
    }

    public static func fetch<ResultType>(relatedEntityID id: RelatedID) -> [ResultType] where ResultType: NSManagedObject {
        return fetch(relatedEntityID: id, identifier: .any) as [ResultType]
    }

    public static func fetch<ResultType>(relatedEntityID id: RelatedID) -> ResultType? where ResultType: NSManagedObject {
        return fetch(relatedEntityID: id, identifier: .any) as ResultType?
    }
}
