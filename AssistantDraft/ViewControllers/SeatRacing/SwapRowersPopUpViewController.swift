//
//  SwapRowersOverviewViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 12/08/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit

class SwapRowersOverviewViewController: popUPViewController, sendSwap, resultsPopUpDelegate {
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var subViews: UIView!
    @IBOutlet weak var swapLabel: UILabel!
    @IBOutlet weak var currentResultsPopUp: UIButton!
    
    //Contains dots for page control
    var pageControl = UIPageControl()
    var firstMove = true
    var currRower: Rower?
    var raceNo: Int?
    var seatRaceBoats: [SeatRaceBoat] = []
    var swapsXforY: [Rower:Rower] = [:]
    var currSeatRace: SeatRace?
    var noOfRowers: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpView.layer.cornerRadius = 5.0
        showAnimate()
        subViews.layer.cornerRadius = 5.0
        noOfRowers = calculateRowers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        popUpView.addGradientBackground(firstColor: UIColor.init(rgb: 0x1B2BD6), secondColor: UIColor.init(rgb: 0x1b5ad6))
    }
    
    func calculateRowers () -> Int {
        var noOfRowers = 0
        for boat in seatRaceBoats {
            switch boat.type {
            //TODO:CHECK Works with each one
            case "M8+":noOfRowers = noOfRowers + 8
            case "W8+":noOfRowers = noOfRowers + 8
            case "LW8+":noOfRowers = noOfRowers + 8
            case "LM8+":noOfRowers = noOfRowers + 8
            case "M4x":noOfRowers = noOfRowers + 4
            case "LM4x":noOfRowers = noOfRowers + 4
            case "W4x":noOfRowers = noOfRowers + 4
            case "LW4x":noOfRowers = noOfRowers + 4
            case "LM4-":noOfRowers = noOfRowers + 4
            case "M4-":noOfRowers = noOfRowers + 4
            case "LW4-":noOfRowers = noOfRowers + 4
            case "W4-":noOfRowers = noOfRowers + 4
            case "M4+":noOfRowers = noOfRowers + 5
            case "W4+":noOfRowers = noOfRowers + 5
            case "LM4+":noOfRowers = noOfRowers + 5
            case "LW4+":noOfRowers = noOfRowers + 5
            case "M2x":noOfRowers = noOfRowers + 2
            case "W2x":noOfRowers = noOfRowers + 2
            case "LM2x":noOfRowers = noOfRowers + 2
            case "LW2x": noOfRowers = noOfRowers + 2
            case "M2-":noOfRowers = noOfRowers + 2
            case "W2-":noOfRowers = noOfRowers + 2
            case "LW2-":noOfRowers = noOfRowers + 2
            case "LM2-":noOfRowers = noOfRowers + 2
            case "M1x":noOfRowers = noOfRowers + 1
            case "W1x":noOfRowers = noOfRowers + 1
            case "LM1x":noOfRowers = noOfRowers + 1
            case "LW1x":noOfRowers = noOfRowers + 1
            default:
                print("Oh shit")
            }
        }
        return noOfRowers
    }
    
    func sendSwap(rower: Rower, boat: SeatRaceBoat) {
        if (firstMove) {
            swapLabel.text = "Swap \(rower.name!) for ..."
            currRower = rower
            firstMove = false
        } else {
            if ((currRower!.isEqual(rower))) {
                //If same person swapped
                firstMove = true
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cancelSwaps"), object: nil)
                swapLabel.text = "Swap..."
            } else {
                swapLabel.text = "Swap \(currRower!.name!) for \(rower.name!)"
                swapsXforY[rower] = currRower
                swapsXforY[currRower!] = rower
                firstMove = true
                // Create the alert controller
                let alertController = UIAlertController(title: "Swaps", message: "You're swapping \(currRower!.name!) for \(rower.name!). Confirm, Add another Swap or Cancel.", preferredStyle: .alert)
                
                // Create the actions
                let okAction = UIAlertAction(title: "Confirm", style: UIAlertAction.Style.default) {
                    UIAlertAction in
                    self.createNewTime()
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive) {
                    UIAlertAction in
                    //then reset view
                    self.swapsXforY.removeValue(forKey: rower)
                    self.swapsXforY.removeValue(forKey: self.currRower!)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cancelSwaps"), object: nil)
                    self.swapLabel.text = "Swap..."
                }
                let anotherSwapAction = UIAlertAction(title: "Another Swap", style: UIAlertAction.Style.cancel) {
                    UIAlertAction in
                    let swapsDataDict: [String: [Rower:Rower]] = ["swapsData": self.swapsXforY]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AnotherSwap"), object: nil, userInfo: swapsDataDict)
                }
                
                // Add the actions
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                if (noOfRowers! - swapsXforY.count > 1) {
                    alertController.addAction(anotherSwapAction)
                }
                
                // Present the controller
                self.present(alertController, animated: true, completion: nil)
            }
            
        }
    }
    
    func createNewTime() {
        for seatRaceBoat in seatRaceBoats {
            //Get Rowers
            //Wants highest race number first
            let sortDescriptorSeatBoatTimes = NSSortDescriptor(key: #keyPath(SeatRaceTime.raceNo), ascending: false)
            let sortDescriptorRowersSeat = NSSortDescriptor(key: #keyPath(Rower_Seat.seat), ascending: true)
            let timesArray = seatRaceBoat.times?.sortedArray(using: [sortDescriptorSeatBoatTimes]) as! [SeatRaceTime]
            let mostRecentRowersSeat =  timesArray.first?.lineUp?.sortedArray(using: [sortDescriptorRowersSeat]) as! [Rower_Seat]
            
            //Create New Time
            //Enter rowers as usual but changing if in dictionary
            let newTime = SeatRaceTime(context: CoreDataStack.context)
            newTime.raceNo = Int16(raceNo!) //First race
            var seat = 1 //Starts with bow
            newTime.uniqueIdentifier = UUID()
            for rowerSeat in mostRecentRowersSeat {
                let rower = rowerSeat.rower!
                if (swapsXforY[rower] != nil) {
                    //In dictionary
                    let rower_SeatNew = Rower_Seat(context: CoreDataStack.context)
                    let swappedRower = swapsXforY[rower]
                    rower_SeatNew.rower = swappedRower!
                    rower_SeatNew.seat = Int16(seat)                    
                    newTime.addToLineUp(rower_SeatNew)
                } else {
                    //Same as last time so just a copy
                    let rower_SeatCopy = Rower_Seat(context: CoreDataStack.context)
                    rower_SeatCopy.seat = rowerSeat.seat
                    rower_SeatCopy.rower = rower
                    newTime.addToLineUp(rower_SeatCopy)
                }
                seat = seat + 1
            }
            seatRaceBoat.addToTimes(newTime)
        }
        removeAnimate()
    }
    
    @IBAction func currResultsPressed(_ sender: Any) {
        let resultspopOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "seatRaceResultsPopUp") as! SeatRacingPopUpViewController
        self.addChild(resultspopOverVC)
        resultspopOverVC.delegate = self
        resultspopOverVC.seatRaceBoats = seatRaceBoats
        resultspopOverVC.seatRaceInfo = currSeatRace
        resultspopOverVC.lastView = true
        //TODO: If first swap,
        if (raceNo == 2) {
            //First swap as addCurrRacetimes called before swap which increments raceNo
            resultspopOverVC.preSwaps = true
        }
        resultspopOverVC.view.frame = self.view.frame
        self.view.addSubview(resultspopOverVC.view)
        resultspopOverVC.didMove(toParent: self)
    }
    
    //To fit protocol
    func finished(lastView: Bool) {
    }
    
    //MARK: Segue prep
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SwapRowersEmbed" {
            let dest = segue.destination as! swapRowers
            dest.seatRaceBoats = seatRaceBoats
            dest.parentController = self
        }
    }
    
}
