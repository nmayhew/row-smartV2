//
//  SeatRaceTime+CoreDataProperties.swift
//  
//
//  Created by Nicholas Mayhew on 07/05/2020.
//
//

import Foundation
import CoreData


extension SeatRaceTime {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SeatRaceTime> {
        return NSFetchRequest<SeatRaceTime>(entityName: "SeatRaceTime")
    }

    @NSManaged public var deciSeconds: Int32
    @NSManaged public var raceNo: Int16
    @NSManaged public var uniqueIdentifier: UUID?
    @NSManaged public var boat: SeatRaceBoat?
    @NSManaged public var lineUp: NSSet?

}

// MARK: Generated accessors for lineUp
extension SeatRaceTime {

    @objc(addLineUpObject:)
    @NSManaged public func addToLineUp(_ value: Rower_Seat)

    @objc(removeLineUpObject:)
    @NSManaged public func removeFromLineUp(_ value: Rower_Seat)

    @objc(addLineUp:)
    @NSManaged public func addToLineUp(_ values: NSSet)

    @objc(removeLineUp:)
    @NSManaged public func removeFromLineUp(_ values: NSSet)

}
