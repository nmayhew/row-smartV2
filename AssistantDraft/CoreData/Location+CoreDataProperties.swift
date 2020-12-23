//
//  Location+CoreDataProperties.swift
//  
//
//  Created by Nicholas Mayhew on 07/05/2020.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var timestamp: Date?
    @NSManaged public var pieceRe: Piece?
    @NSManaged public var session: TrainingSession?

}
