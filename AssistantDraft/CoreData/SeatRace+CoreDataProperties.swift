//
//  SeatRace+CoreDataProperties.swift
//  
//
//  Created by Nicholas Mayhew on 07/05/2020.
//
//

import Foundation
import CoreData


extension SeatRace {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SeatRace> {
        return NSFetchRequest<SeatRace>(entityName: "SeatRace")
    }

    @NSManaged public var date: Date?
    @NSManaged public var distance: Int32
    @NSManaged public var boats: NSSet?

}

// MARK: Generated accessors for boats
extension SeatRace {

    @objc(addBoatsObject:)
    @NSManaged public func addToBoats(_ value: SeatRaceBoat)

    @objc(removeBoatsObject:)
    @NSManaged public func removeFromBoats(_ value: SeatRaceBoat)

    @objc(addBoats:)
    @NSManaged public func addToBoats(_ values: NSSet)

    @objc(removeBoats:)
    @NSManaged public func removeFromBoats(_ values: NSSet)

}
