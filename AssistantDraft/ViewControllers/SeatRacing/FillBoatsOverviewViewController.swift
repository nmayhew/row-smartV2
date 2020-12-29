//
//  FillBoatsOverviewViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 30/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit

class FillBoatsOverviewViewController: UIViewController, sendRowers, ReadyToSend {
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var finished: UIButton!
    
    var seatRace: SeatRace?
    var seatRaceBoats: [SeatRaceBoat]?
    //For validation of filled Boats
    var boatsFilled = false
    var boatsFilledDict: [SeatRaceBoat: Bool] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //All start false and as filled by send rowers delegate call they are made true. When all true segue allowed to perform
        for boat in seatRaceBoats! {
            boatsFilledDict[boat] = false
        }
        finished.layer.cornerRadius = Constants.CORNERRAD
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            //Done if back is pressed so two races aren't created
            for boat in seatRaceBoats! {
                deleteBoatDetails(boat: boat)//Ensure don't have multiple fake races within boat races
            }
            CoreDataStack.context.delete(seatRace!)
        }
    }
    
    func deleteBoatDetails(boat:SeatRaceBoat) {
        let sortDescriptorSeatBoatTimes = NSSortDescriptor(key: #keyPath(SeatRaceTime.raceNo), ascending: false)
        let sortDescriptorRowers_Seat = NSSortDescriptor(key: #keyPath(Rower_Seat.seat), ascending: true)
        let seatRaceTimes = boat.times!.sortedArray(using: [sortDescriptorSeatBoatTimes]) as! [SeatRaceTime]
        //So rowers, who all have to be in every race, are only deleted once and all deleted
        var first = true
        for seatRaceTime in seatRaceTimes {
            let rowersInBoat = seatRaceTime.lineUp?.sortedArray(using: [sortDescriptorRowers_Seat]) as! [Rower_Seat]
            for rower_seat in rowersInBoat {
                if (first) {
                    let rower = rower_seat.rower
                    CoreDataStack.context.delete(rower!)
                }
                CoreDataStack.context.delete(rower_seat)
            }
            CoreDataStack.context.delete(seatRaceTime)
            first = false
        }
    }
    
    
    @IBAction func finishedPressed(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "confirmRowers"), object: nil)
    }
    //Checks if subViews Ready to show rowers
    func ready(ready: Bool, boat: SeatRaceBoat) {
        boatsFilledDict[boat] = ready
        if (boatsFilledDict.allSatisfy({$0.value == true})) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendRowers"), object: nil)
            boatsFilled = true
        }
    }
    //Results from subViews - Rowers in order bow to stroke then cox if needed
    func sendRowers(rowersInOrder: [String], boat: SeatRaceBoat) {
        for seatRaceBoat in seatRaceBoats! {
            if (seatRaceBoat == boat) {
                
                let newTime = SeatRaceTime(context: CoreDataStack.context)
                newTime.raceNo = 1 //First race
                var seat = 1 //Starts with bow
                newTime.uniqueIdentifier = UUID()
                for rower in rowersInOrder {
                    //CreateRower_seat
                    let rower_seatNew = Rower_Seat(context: CoreDataStack.context)
                    rower_seatNew.seat = Int16(seat)
                    
                    //create and add rower
                    let rowerNew = Rower(context: CoreDataStack.context)
                    rowerNew.name = rower
                    rowerNew.uniqueIdentifier = UUID()
                    rower_seatNew.rower = rowerNew
                    
                    seat = seat + 1
                    newTime.addToLineUp(rower_seatNew)
                }
                seatRaceBoat.addToTimes(newTime)
            }
        }
    }
    //MARK: Segue 
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "SeatRacingStart" {
            if boatsFilled == false {
                //Alert Controller if boats not full
                // create the alert
                let alert = UIAlertController(title: "Lineups unfinished", message: "Please enter all rowers and coxes for all boats. Swipe to see all boats", preferredStyle: UIAlertController.Style.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
    
    //Passing info in segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "passTheSeatRaceBoats" {
            let dest = segue.destination as! fillBoats
            dest.seatRace = seatRace
            dest.seatRaceBoats = seatRaceBoats
            dest.parentController = self
        }
        if segue.identifier == "SeatRacingStart" {
            let dest = segue.destination as! RacingSeatRaceViewController
            dest.currRace = seatRace
            dest.currRaceBoats = seatRaceBoats!
        }
    }
    
    
}
