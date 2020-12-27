//
//  SavedSessionsDetailsViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 16/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit
import CoreLocation
//Shows an individual saved training and its details. Contains page view that has map and coach notes

class SavedSessionsDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var TrainingSession: UILabel!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var piecesTable: UITableView!
    
    
    
    var session: TrainingSession?
    private var pieces: [Piece] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        piecesTable.delegate = self
        piecesTable.dataSource = self
        piecesTable.roundCorners()
        
        // Format the View
        let formattedTime = varFormatter.time(Int(session!.duration))
        duration.text = "Time: \(formattedTime)"
        //Load Date and set label
        let dateCurr = session!.date
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
        date.text = dateFormatterPrint.string(from: dateCurr!)
        //Load Distance and set label
        let formattedDist = varFormatter.distance(Measurement(value: Double(session!.distance), unit: UnitLength.meters))
        distance.text = "Distance: \(formattedDist)"
        //Load Locations and send to sub views
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Location.timestamp), ascending: true)
        let locations = session!.locations?.sortedArray(using:[sortDescriptor]) as! [Location]
        let locationDataDict:[String: [Location]] = ["locations": locations]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "savedLocationSent"), object: nil, userInfo: locationDataDict)
        //Load CoachNotes and send to sub views
        NotificationCenter.default.addObserver(self, selector: #selector(viewLoaded), name: NSNotification.Name(rawValue: "notesViewLoaded"), object: nil)
        //Load Pieces and load into table
        let sortDescriptorPiece = NSSortDescriptor(key: #keyPath(Piece.startTime), ascending: true)
        pieces = session!.pieces?.sortedArray(using:[sortDescriptorPiece]) as! [Piece]
        piecesTable.reloadData()
        
        firstLocationPieces()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    @objc func viewLoaded() {
        let coachNotes:[String: String] = ["coachNotes": session!.coachNotes!]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "savedCoachNotesSent"), object: nil, userInfo: coachNotes)
    }
    
    //Sending first and last locations of each piece to sub views for map view
    func firstLocationPieces() {
        let sortDescriptorLoc = NSSortDescriptor(key: #keyPath(Location.timestamp), ascending: false) //Not SURE IF FALSE OR TRUE
        var firstLastLocations: [Location] = []
        for piece in pieces {
            let locations = piece.locations?.sortedArray(using: [sortDescriptorLoc]) as! [Location]
            if(locations.isEmpty) {
                let error = Location(context:CoreDataStack.context)
                error.longitude = 0.0
                error.latitude = 0.0
                firstLastLocations.append(error)
                firstLastLocations.append(error)
            } else {
                firstLastLocations.append(locations.first!)
                firstLastLocations.append(locations.last!)
            }
        }
        let firLocDataDict:[String: [Location]] = ["firLastlocations": firstLastLocations]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "firstLastLocations"), object: nil, userInfo: firLocDataDict)
    }
    
    //MARK: Table view delegates for pieces in saved training session
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if (pieces.count == 0) {
            return 1
        } else {
            return pieces.count
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (pieces.count == 0) {
            return "No Pieces Recorded"
        }
        return "Piece \(section+1)"
    }
    
    //Builds Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (pieces.count == 0) {
            //Default cell if nothing there
            let cell = tableView.dequeueReusableCell(withIdentifier: "pieceItem", for: indexPath) as! pieceTableCell
            cell.distanceLabel.text = ""
            cell.aveSplit.text = ""
            cell.runTime.text = ""
            cell.restTime.text = ""
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "pieceItem", for: indexPath) as! pieceTableCell
        cell.distanceLabel.text = "Distance: \(pieces[indexPath.section].distance)m"
        let formattedRunTime = varFormatter.time(Int(pieces[indexPath.section].lengthTime))
        let formattedRestTime = varFormatter.time(Int(pieces[indexPath.section].restTime))
        cell.runTime.text = "Time: \(formattedRunTime)"
        cell.restTime.text = "Rest: \(formattedRestTime)"
        let formattedPace = varFormatter.pace(distance: Measurement(value: Double(pieces[indexPath.section].distance), unit: UnitLength.meters), seconds: Int(pieces[indexPath.section].lengthTime), outputUnit: UnitSpeed.secondsPerFiveHundredMeter)
        
        cell.aveSplit.text = "Split: \(formattedPace)"
        return cell
    }
}
