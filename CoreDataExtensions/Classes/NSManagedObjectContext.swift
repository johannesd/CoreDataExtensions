//
//  NSManagedObjectContext.swift
//  CoreDataExtensions
//
//  Created by Johannes Dörr on 01.10.19.
//  Copyright © 2019 Locandis. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {

    @discardableResult
    open func _performAndWait<T>(_ block: () -> T) -> T {
        var value: T?
        self.performAndWait {
            value = block()
        }
        return value!
    }

    @discardableResult
    open func _performAndWait<T>(_ block: () throws -> T) throws -> T {
        var retValue: T?
        var retError: Error?
        self.performAndWait {
            do {
                retValue = try block()
            } catch {
                retError = error
            }
        }
        if let error = retError {
            throw error
        }
        return retValue!
    }

}
