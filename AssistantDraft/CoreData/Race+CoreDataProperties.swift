//
//  Race+CoreDataProperties.swift
//  
//
//  Created by Nicholas Mayhew on 07/05/2020.
//
//

import Foundation
import CoreData


extension Race {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Race> {
        return NSFetchRequest<Race>(entityName: "Race")
    }

    @NSManaged public var date: Date?
    @NSManaged public var distance: Int32
    @NSManaged public var boats: NSSet?

}

// MARK: Generated accessors for boats
extension Race {

    @objc(addBoatsObject:)
    @NSManaged public func addToBoats(_ value: Boat)

    @objc(removeBoatsObject:)
    @NSManaged public func removeFromBoats(_ value: Boat)

    @objc(addBoats:)
    @NSManaged public func addToBoats(_ values: NSSet)

    @objc(removeBoats:)
    @NSManaged public func removeFromBoats(_ values: NSSet)

}
