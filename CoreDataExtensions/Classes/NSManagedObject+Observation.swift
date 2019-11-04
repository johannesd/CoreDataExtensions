//
//  Observation.swift
//  CoreDataExtensions
//
//  Created by Johannes Dörr on 01.10.19.
//  Copyright © 2019 Locandis. All rights reserved.
//

import CoreData

extension NSManagedObject {
    /**
     Creates an observer for this managed object.
     - Parameter block: A function that is executed on the the managed object's queue when it has changed.
     */
    open func addObserver(using block: @escaping () -> Void) -> NSObjectProtocol {
        let observer = NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: self.managedObjectContext, queue: .main) { [weak self] notification in
            guard let _self = self else { return }
            _self.managedObjectContext?.perform {
                let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as! Set<NSManagedObject>
                let refreshedObjects = notification.userInfo?[NSRefreshedObjectsKey] as! Set<NSManagedObject>
                if updatedObjects.union(refreshedObjects).contains(_self) {
                    block()
                }
            }
        }
        block()
        return observer
    }

    /**
     Removes an observer.
     - Parameter observer: The observer object returned by `addObserver(using:)`.
     */
    open func removeObserver(observer: NSObjectProtocol) {
        NotificationCenter.default.removeObserver(observer, name: .NSManagedObjectContextObjectsDidChange, object: self.managedObjectContext)
    }
}
