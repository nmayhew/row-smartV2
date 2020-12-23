//
//  TrainingSession+CoreDataProperties.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 04/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//
//

import Foundation
import CoreData


extension TrainingSession {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrainingSession> {
        return NSFetchRequest<TrainingSession>(entityName: "TrainingSession")
    }

    @NSManaged public var distance: Int32
    @NSManaged public var duration: Int32
    @NSManaged public var date: NSDate?
    @NSManaged public var coachNotes: String?
    @NSManaged public var locations: NSSet?
    @NSManaged public var pieces: NSSet?

}

// MARK: Generated accessors for locations
extension TrainingSession {

    @objc(addLocationsObject:)
    @NSManaged public func addToLocations(_ value: Location)

    @objc(removeLocationsObject:)
    @NSManaged public func removeFromLocations(_ value: Location)

    @objc(addLocations:)
    @NSManaged public func addToLocations(_ values: NSSet)

    @objc(removeLocations:)
    @NSManaged public func removeFromLocations(_ values: NSSet)

}

// MARK: Generated accessors for pieces
extension TrainingSession {

    @objc(addPiecesObject:)
    @NSManaged public func addToPieces(_ value: Piece)

    @objc(removePiecesObject:)
    @NSManaged public func removeFromPieces(_ value: Piece)

    @objc(addPieces:)
    @NSManaged public func addToPieces(_ values: NSSet)

    @objc(removePieces:)
    @NSManaged public func removeFromPieces(_ values: NSSet)

}
