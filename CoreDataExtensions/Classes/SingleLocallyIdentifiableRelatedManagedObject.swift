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
    static func predicate(relatedLocalEntityID: RelatedLocalID, relatedParameters: RelatedLocalParameters) -> NSPredicate
    static func localEntityCount(relatedParameters: RelatedLocalParameters) -> Int?
}

extension SingleLocallyIdentifiableRelatedManagedObject where Self: NSManagedObject, RelatedLocalEntityIdentifier == SingleRelatedLocalEntityIdentifier {
    public static func predicate(relatedLocalEntityID: RelatedLocalID, relatedLocalEntityIdentifier: RelatedLocalEntityIdentifier, relatedParameters: RelatedLocalParameters) -> NSPredicate {
        return predicate(relatedLocalEntityID: relatedLocalEntityID, relatedParameters: relatedParameters)
    }

    public static func localEntityCount(for identifier: RelatedLocalEntityIdentifier, relatedParameters: RelatedLocalParameters) -> Int? {
        return localEntityCount(relatedParameters: relatedParameters)
    }

    public static func localEntityCount(relatedParameters: RelatedLocalParameters) -> Int? {
        return 1
    }

    public static func fetchRequest<ResultType>(forRelatedLocalEntityID localID: RelatedLocalID, relatedParameters: RelatedLocalParameters) -> NSFetchRequest<ResultType> where ResultType: NSManagedObject {
        return fetchRequest(forRelatedLocalEntityID: localID, identifier: .any, relatedParameters: relatedParameters) as NSFetchRequest<ResultType>
    }

    public static func fetch<ResultType>(relatedLocalEntityID localID: RelatedLocalID, relatedParameters: RelatedLocalParameters) -> [ResultType] where ResultType: NSManagedObject {
        return fetch(relatedLocalEntityID: localID, identifier: .any, relatedParameters: relatedParameters) as [ResultType]
    }

    public static func fetch<ResultType>(relatedLocalEntityID localID: RelatedLocalID, relatedParameters: RelatedLocalParameters) -> ResultType? where ResultType: NSManagedObject {
        return fetch(relatedLocalEntityID: localID, identifier: .any, relatedParameters: relatedParameters) as ResultType?
    }
}
