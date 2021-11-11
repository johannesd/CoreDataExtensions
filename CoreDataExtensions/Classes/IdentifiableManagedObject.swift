//
//  IdentifiableManagedObject.swift
//  CoreDataExtensions
//
//  Created by Johannes Dörr on 05.03.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import Foundation
import CoreData

/**
 Represents an entity that is available on the COYO server. id is the key it has on the server.
 Classes should use the generic functions `fetchRequest<ResultType>(forEntityWithID:)` and
 `fetch<ResultType>(entityWithID:)` to implement custom `fetchRequest(forID:)` and `fetch(id:)`
 functions that have the correct return type, for example `MessageChannel`, so that they can be used
 without type casting.
 */
public protocol IdentifiableManagedObject {
    associatedtype SelfID: CVarArg
    var id: SelfID? { get }
}

extension IdentifiableManagedObject where Self: NSManagedObject {
    /**
     Creates a FetchRequest using the given ID
     - Parameter id: The id of the requested object
     */
    public static func fetchRequest<ResultType>(forEntityID id: SelfID) -> NSFetchRequest<ResultType> where ResultType: NSManagedObject {
        // XXX: entity().name is optional and sometimes nil, so we fall back to the class name in that case
        let entityName = ResultType.entity().name ?? String(describing: self)
        let request: NSFetchRequest<ResultType> = NSFetchRequest(entityName: entityName)
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        return request
    }

    /**
     Creates a FetchRequest using the given ID
     - Parameter id: The id of the requested object
     */
    public static func fetchRequest(forID id: SelfID) -> NSFetchRequest<Self> {
        return fetchRequest(forEntityID: id)
    }

    /**
     Fetches an object with the given ID
     - Parameter id: The id of the requested object
     */
    public static func fetch<ResultType>(entityID id: SelfID) -> ResultType? where ResultType: NSManagedObject {
        let request: NSFetchRequest<ResultType> = fetchRequest(forEntityID: id)
        return (try? request.execute())?.first
    }

    /**
     Fetches an object with the given ID
     - Parameter id: The id of the requested object
     */
    public static func fetch(id: SelfID) -> Self? {
        return fetch(entityID: id)
    }
}
