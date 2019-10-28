//
//  SingleLocallyIdentifiableRelatedManagedObject.swift
//  CoreDataExtensions
//
//  Created by Johannes Dörr on 26.10.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import Foundation
import CoreData

public enum SingleRelatedLocalEntityIdentifier {
    case any
}

/**
 Represents a model class that has exactly one relationship to `LocallyIdentifiableManagedObject`.
 */
public protocol SingleLocallyIdentifiableRelatedManagedObject: LocallyIdentifiableRelatedManagedObject {
    associatedtype RelatedLocalEntityIdentifier = SingleRelatedLocalEntityIdentifier
    static func predicate(relatedLocalEntityID: RelatedLocalID) -> NSPredicate
    static func localEntityCount() -> Int?
}

extension SingleLocallyIdentifiableRelatedManagedObject where Self: NSManagedObject, RelatedLocalEntityIdentifier == SingleRelatedLocalEntityIdentifier {
    public static func predicate(relatedLocalEntityID: RelatedLocalID, relatedLocalEntityIdentifier: RelatedLocalEntityIdentifier) -> NSPredicate {
        return predicate(relatedLocalEntityID: relatedLocalEntityID)
    }

    public static func localEntityCount(for identifier: RelatedLocalEntityIdentifier) -> Int? {
        return localEntityCount()
    }

    public static func localEntityCount() -> Int? {
        return 1
    }

    public static func fetchRequest<ResultType>(forRelatedLocalEntityID localID: RelatedLocalID) -> NSFetchRequest<ResultType> where ResultType: NSManagedObject {
        return fetchRequest(forRelatedLocalEntityID: localID, identifier: .any) as NSFetchRequest<ResultType>
    }

    public static func fetch<ResultType>(relatedLocalEntityID localID: RelatedLocalID) -> [ResultType] where ResultType: NSManagedObject {
        return fetch(relatedLocalEntityID: localID, identifier: .any) as [ResultType]
    }

    public static func fetch<ResultType>(relatedLocalEntityID localID: RelatedLocalID) -> ResultType? where ResultType: NSManagedObject {
        return fetch(relatedLocalEntityID: localID, identifier: .any) as ResultType?
    }
}
