//
//  Boat+CoreDataProperties.swift
//  
//
//  Created by Nicholas Mayhew on 07/05/2020.
//
//

import Foundation
import CoreData


extension Boat {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Boat> {
        return NSFetchRequest<Boat>(entityName: "Boat")
    }

    @NSManaged public var boatName: String?
    @NSManaged public var lane: Int16
    @NSManaged public var type: String?
    @NSManaged public var boattimes: NSSet?
    @NSManaged public var race: Race?

}

// MARK: Generated accessors for boattimes
extension Boat {

    @objc(addBoattimesObject:)
    @NSManaged public func addToBoattimes(_ value: BoatTimes)

    @objc(removeBoattimesObject:)
    @NSManaged public func removeFromBoattimes(_ value: BoatTimes)

    @objc(addBoattimes:)
    @NSManaged public func addToBoattimes(_ values: NSSet)

    @objc(removeBoattimes:)
    @NSManaged public func removeFromBoattimes(_ values: NSSet)

}
