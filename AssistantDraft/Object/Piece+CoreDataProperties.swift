//
//  Piece+CoreDataProperties.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 04/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//
//

import Foundation
import CoreData


extension Piece {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Piece> {
        return NSFetchRequest<Piece>(entityName: "Piece")
    }

    @NSManaged public var lengthTime: Int16
    @NSManaged public var startTime: NSDate?
    @NSManaged public var restTime: Int16
    @NSManaged public var distance: Int32
    @NSManaged public var split: Double
    @NSManaged public var pieceNo: Int16
    @NSManaged public var session: TrainingSession?

}
