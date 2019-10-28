//
//  LocallyIdentifiableManagedObject.swift
//  CoreDataExtensions
//
//  Created by Johannes Dörr on 26.10.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import Foundation
import CoreData

/**
 Represents an entity that can be stored locally. localID is the key it has on the client.
 Classes should use the generic functions `fetchRequest<ResultType>(forEntityWithLocalID:)` and
 `fetch<ResultType>(entityWithLocalID:)` to implement custom `fetchRequest(forLocalID:)` and `fetch(localID:)`
 functions that have the correct return type, for example `MessageChannel`, so that they can be used
 without type casting.
 */
public protocol LocallyIdentifiableManagedObject {
    associatedtype LocalID: CVarArg
    var localID: LocalID? { get }
}

extension LocallyIdentifiableManagedObject where Self: NSManagedObject {
    /**
     Creates a FetchRequest using the given localID
     - Parameter localID: The localID of the requested object
     */
    public static func fetchRequest<ResultType>(forLocalEntityID id: LocalID) -> NSFetchRequest<ResultType> where ResultType: NSManagedObject {
        // XXX: entity().name is optional and sometimes nil, so we fall back to the class name in that case
        let entityName = ResultType.entity().name ?? String(describing: self)
        let request: NSFetchRequest<ResultType> = NSFetchRequest(entityName: entityName)
        request.predicate = NSPredicate(format: "localID == %@", id)
        request.fetchLimit = 1
        return request
    }

    /**
     Creates a FetchRequest using the given localID
     - Parameter localID: The localID of the requested object
     */
    public static func fetchRequest(forLocalID localID: LocalID) -> NSFetchRequest<Self> {
        return fetchRequest(forLocalEntityID: localID)
    }

    /**
     Fetches an object with the given localID
     - Parameter localID: The localID of the requested object
     */
    public static func fetch<ResultType>(localEntityID localID: LocalID) -> ResultType? where ResultType: NSManagedObject {
        let request: NSFetchRequest<ResultType> = fetchRequest(forLocalEntityID: localID)
        return (try? request.execute())?.first
    }

    /**
     Fetches an object with the given localID
     - Parameter localID: The localID of the requested object
     */
    public static func fetch(localID: LocalID) -> Self? {
        return fetch(localEntityID: localID)
    }
}
