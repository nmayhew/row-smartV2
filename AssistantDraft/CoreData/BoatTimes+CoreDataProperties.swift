//
//  BoatTimes+CoreDataProperties.swift
//  
//
//  Created by Nicholas Mayhew on 07/05/2020.
//
//

import Foundation
import CoreData


extension BoatTimes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BoatTimes> {
        return NSFetchRequest<BoatTimes>(entityName: "BoatTimes")
    }

    @NSManaged public var startTime: Date?
    @NSManaged public var timeDeciSeconds: Int32
    @NSManaged public var boat: Boat?

}
