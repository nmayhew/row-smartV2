//
//  Location+CoreDataProperties.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 04/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
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
    @NSManaged public var timestamp: NSDate?
    @NSManaged public var session: TrainingSession?

}
