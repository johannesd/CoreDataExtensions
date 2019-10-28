//
//  UpdatedEntity.swift
//  CoreDataExtensions
//
//  Created by Johannes Dörr on 05.03.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import Foundation
import CoreData

public protocol UpdatableManageObject {
    var updatedID: Int64 { get }

    /**
     Fetches the largest updatedID found for the entity.
     - Parameter predicate: An additional predicate for the performed FetchRequest
     - Parameter ascending: Specifies if the entities should be sorted in ascending order
     */
    static func fetchLastUpdatedID(predicate: NSPredicate?, ascending: Bool) -> Int64?
}

extension UpdatableManageObject where Self: NSManagedObject {
    public static func fetchLastUpdatedID(predicate: NSPredicate?, ascending: Bool = true) -> Int64? {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: self.entity().name!)
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "updatedID", ascending: !ascending)]
        request.fetchLimit = 1
        request.propertiesToFetch = ["updatedID"]
        return ((try? request.execute())?.first as? UpdatableManageObject)?.updatedID
    }
}
