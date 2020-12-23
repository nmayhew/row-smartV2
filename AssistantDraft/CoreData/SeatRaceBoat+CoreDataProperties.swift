//
//  SeatRaceBoat+CoreDataProperties.swift
//  
//
//  Created by Nicholas Mayhew on 07/05/2020.
//
//

import Foundation
import CoreData


extension SeatRaceBoat {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SeatRaceBoat> {
        return NSFetchRequest<SeatRaceBoat>(entityName: "SeatRaceBoat")
    }

    @NSManaged public var boatName: String?
    @NSManaged public var lane: Int16
    @NSManaged public var type: String?
    @NSManaged public var uniqueIdentifier: UUID?
    @NSManaged public var seatRace: SeatRace?
    @NSManaged public var times: NSSet?

}

// MARK: Generated accessors for times
extension SeatRaceBoat {

    @objc(addTimesObject:)
    @NSManaged public func addToTimes(_ value: SeatRaceTime)

    @objc(removeTimesObject:)
    @NSManaged public func removeFromTimes(_ value: SeatRaceTime)

    @objc(addTimes:)
    @NSManaged public func addToTimes(_ values: NSSet)

    @objc(removeTimes:)
    @NSManaged public func removeFromTimes(_ values: NSSet)

}
