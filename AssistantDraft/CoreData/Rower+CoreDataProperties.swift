//
//  Rower+CoreDataProperties.swift
//  
//
//  Created by Nicholas Mayhew on 07/05/2020.
//
//

import Foundation
import CoreData


extension Rower {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Rower> {
        return NSFetchRequest<Rower>(entityName: "Rower")
    }

    @NSManaged public var name: String?
    @NSManaged public var uniqueIdentifier: UUID?
    @NSManaged public var rower_Seat: NSSet?

}

// MARK: Generated accessors for rower_Seat
extension Rower {

    @objc(addRower_SeatObject:)
    @NSManaged public func addToRower_Seat(_ value: Rower_Seat)

    @objc(removeRower_SeatObject:)
    @NSManaged public func removeFromRower_Seat(_ value: Rower_Seat)

    @objc(addRower_Seat:)
    @NSManaged public func addToRower_Seat(_ values: NSSet)

    @objc(removeRower_Seat:)
    @NSManaged public func removeFromRower_Seat(_ values: NSSet)

}
