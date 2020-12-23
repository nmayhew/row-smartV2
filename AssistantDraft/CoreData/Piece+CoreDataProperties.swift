//
//  Piece+CoreDataProperties.swift
//  
//
//  Created by Nicholas Mayhew on 07/05/2020.
//
//

import Foundation
import CoreData


extension Piece {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Piece> {
        return NSFetchRequest<Piece>(entityName: "Piece")
    }

    @NSManaged public var distance: Int32
    @NSManaged public var lengthTime: Int16
    @NSManaged public var pieceNo: Int16
    @NSManaged public var restTime: Int16
    @NSManaged public var split: String?
    @NSManaged public var startTime: Date?
    @NSManaged public var locations: NSSet?
    @NSManaged public var session: TrainingSession?

}

// MARK: Generated accessors for locations
extension Piece {

    @objc(addLocationsObject:)
    @NSManaged public func addToLocations(_ value: Location)

    @objc(removeLocationsObject:)
    @NSManaged public func removeFromLocations(_ value: Location)

    @objc(addLocations:)
    @NSManaged public func addToLocations(_ values: NSSet)

    @objc(removeLocations:)
    @NSManaged public func removeFromLocations(_ values: NSSet)

}
