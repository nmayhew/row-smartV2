//
//  Rower_Seat+CoreDataProperties.swift
//  
//
//  Created by Nicholas Mayhew on 07/05/2020.
//
//

import Foundation
import CoreData


extension Rower_Seat {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Rower_Seat> {
        return NSFetchRequest<Rower_Seat>(entityName: "Rower_Seat")
    }

    @NSManaged public var seat: Int16
    @NSManaged public var boatRun: SeatRaceTime?
    @NSManaged public var rower: Rower?

}
