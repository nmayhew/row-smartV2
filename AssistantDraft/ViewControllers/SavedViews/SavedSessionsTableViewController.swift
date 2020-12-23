//
//  SavedSessionsTableViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 15/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.

// OLD saved sessions, races and seat racing file
/*
import UIKit
import CoreData

class sessionsTableCell: UITableViewCell {
    
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var date: UILabel!
    
}
//All in date order so check first then

class SavedSessionsTableViewController: UITableViewController, resultsPopUpDelegate {

    @IBOutlet var sessionsTable: UITableView!
    var trSesArray: [TrainingSession] = []
    var raceArray: [Race] = []
    var seatRaceArray: [SeatRace] = []
    private var selected: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sessionsTable.roundCorners()
        trSesArray = getSessions()
        raceArray = getRaces()
        seatRaceArray = getSeatRaces()
    }
    func getSeatRaces() -> [SeatRace] {
        let fetchRequest: NSFetchRequest = SeatRace.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(SeatRace.date), ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            return try CoreDataStack.context.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    func getRaces() -> [Race] {
        let fetchRequest: NSFetchRequest = Race.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Race.date), ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            return try CoreDataStack.context.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    func getSessions() -> [TrainingSession] {
        let fetchRequest: NSFetchRequest = TrainingSession.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(TrainingSession.date), ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            return try CoreDataStack.context.fetch(fetchRequest)
        } catch {
            return []
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return seatRaceArray.count
        } else if (section == 1) {
            return raceArray.count
        } else {
            return trSesArray.count
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Seat Racing Results"
        } else if (section == 1) {
            return "Race Results"
        } else {
            return "Training Sessions"
        }
    }
    //MARK: resultsPopUpDelegate
    func finished(lastView: Bool) {
        //Not Needed
        tableView.isScrollEnabled = true
        tableView.deselectRow(at: selected!, animated: true)
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd, yyyy"
        let cell = tableView.dequeueReusableCell(withIdentifier: "sessionsOverview", for: indexPath) as! sessionsTableCell
        if (indexPath.section == 2) {
            let dateCurr = trSesArray[indexPath.row].date!
            let formattedDistance = varFormatter.distance(Measurement(value: Double(trSesArray[indexPath.row].distance), unit: UnitLength.meters))
            cell.date.text = dateFormatterPrint.string(from: dateCurr)
            cell.distance.text = "Distance: \(formattedDistance)"
            return cell
        } else if (indexPath.section == 1){
            //Race building
            let dateCurr = raceArray[indexPath.row].date!
            let formattedDistance = varFormatter.distance(Measurement(value: Double(raceArray[indexPath.row].distance), unit: UnitLength.meters))
            cell.date.text = dateFormatterPrint.string(from: dateCurr)
            cell.distance.text = "Distance: \(formattedDistance)"
            return cell
        } else {
            let dateCurr = seatRaceArray[indexPath.row].date!
            let formattedDistance = varFormatter.distance(Measurement(value: Double(seatRaceArray[indexPath.row].distance), unit: UnitLength.meters))
            cell.date.text = dateFormatterPrint.string(from: dateCurr)
            cell.distance.text = "Distance: \(formattedDistance)"
            return cell
        }
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //TODO
            //Delete and Save again
            if (indexPath.section == 2) { CoreDataStack.context.delete(trSesArray[indexPath.row])
                CoreDataStack.saveContext()
                trSesArray.remove(at: indexPath.row)
                // Delete the row from the data source
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else if (indexPath.section == 1) {
            CoreDataStack.context.delete(raceArray[indexPath.row])
                CoreDataStack.saveContext()
                raceArray.remove(at: indexPath.row)
                // Delete the row from the data source
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else {
                CoreDataStack.context.delete(seatRaceArray[indexPath.row])
                CoreDataStack.saveContext()
                seatRaceArray.remove(at: indexPath.row)
                // Delete the row from the data source
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
        }
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //TODO: Support race could do with different prototype cells for different types of races that segue to different saved sessions details for different types of sessions
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showSessionDetails" {
            let currIndexPath = tableView.indexPathForSelectedRow
            if (currIndexPath!.section == 2) {
                return true
            } else if (currIndexPath!.section == 1){
                //Race //Uses pop up used in final of races
                let resultspopOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "currResultsPopUp") as! ResultsPopUpViewController
                self.addChild(resultspopOverVC)
                resultspopOverVC.lastView = false //To stop crash
                resultspopOverVC.delegate = self
                let sortDescriptorBoat = NSSortDescriptor(key: #keyPath(Boat.lane), ascending: true)
                resultspopOverVC.raceBoatsInfo = raceArray[currIndexPath!.row].boats?.sortedArray(using: [sortDescriptorBoat]) as! [Boat]
                resultspopOverVC.raceInfo = raceArray[currIndexPath!.row]
                let visibleRect = sessionsTable.bounds
                resultspopOverVC.view.frame = visibleRect
                
                
            
                self.view.addSubview(resultspopOverVC.view)
                resultspopOverVC.didMove(toParent: self)
                tableView.deselectRow(at: currIndexPath!, animated: true)//So unselected
                selected = currIndexPath!
                tableView.isScrollEnabled = false
                return false
            } else {
                let resultspopOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "seatRaceResultsPopUp") as! SeatRacingPopUpViewController
                let sortDescriptorSeatBoat = NSSortDescriptor(key: #keyPath(SeatRaceBoat.lane), ascending: true)
                self.addChild(resultspopOverVC)
                resultspopOverVC.delegate = self
                resultspopOverVC.seatRaceBoats = seatRaceArray[currIndexPath!.row].boats?.sortedArray(using: [sortDescriptorSeatBoat]) as! [SeatRaceBoat]
                resultspopOverVC.seatRaceInfo = seatRaceArray[currIndexPath!.row]
                resultspopOverVC.lastView = false //doesn't do anything
                resultspopOverVC.savedView = true //So can readjust for lineup rowers pop up
                let visibleRect = sessionsTable.bounds
            
                resultspopOverVC.lastView = true //To stop crash
                resultspopOverVC.view.frame = visibleRect
                
                self.view.addSubview(resultspopOverVC.view)
                resultspopOverVC.didMove(toParent: self)
                selected = currIndexPath!
                tableView.isScrollEnabled = false
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if  segue.identifier == "showSessionDetails",
            let destination = segue.destination as? SavedSessionsDetailsViewController,
            let trSesIndex = tableView.indexPathForSelectedRow?.row
        {
            destination.session = trSesArray[trSesIndex]
        }
    }
 

}
*/
