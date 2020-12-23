//
//  SeatRaceHomeViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 28/08/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit
import CoreData

class seatRaceCell: UICollectionViewCell {
    
    @IBOutlet weak var numberOfCrews: UILabel!
    @IBOutlet weak var swaps: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var seatRaceDate: UILabel!
    
}

class SeatRaceHomeViewController: parentHomeViewController, UICollectionViewDataSource, resultsPopUpDelegate {
    
    
    let sortDescriptorSeatBoat = NSSortDescriptor(key: #keyPath(SeatRaceBoat.lane), ascending: true)
    let sortDescriptorSeatBoatTimes = NSSortDescriptor(key: #keyPath(SeatRaceTime.raceNo), ascending: true)

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var savedSeatRaes: UICollectionView!
    
    
    
    private var reuseID = "seatRaceSaveCell"
    private var seatRaceArray: [SeatRace] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        savedSeatRaes.dataSource = self
        savedSeatRaes.delegate = self
        seatRaceArray = getSeatRaces()
        setUpButtons(button: addButton)
        let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(SeatRaceHomeViewController.handleLongPress(gestureRecognizer:)))
        lpgr.minimumPressDuration = 0.7
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = true
        self.savedSeatRaes.addGestureRecognizer(lpgr)
        
        
    }
    
    @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
        //Validation check
        //Checking not placeholder cell
        if (seatRaceArray.count == 0) {
            return
        }
        if (gestureRecognizer.state != UIGestureRecognizer.State.began){
            return
        }
        
        let p = gestureRecognizer.location(in: self.savedSeatRaes)
        //Find indexPath, set up alert controller
        if let indexPath = (self.savedSeatRaes.indexPathForItem(at: p)) {
            let alertController = UIAlertController(title: "Delete", message: "Confirm to delete this seat race", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Confirm", style: .destructive) { (_) -> Void in
                CoreDataStack.context.delete(self.seatRaceArray[indexPath.row])
                CoreDataStack.saveContext()
                
                self.seatRaceArray.remove(at: indexPath.row)
                if (self.seatRaceArray.count != 0) {
                    self.savedSeatRaes.deleteItems(at: [indexPath])
                } else {
                    self.savedSeatRaes.reloadData()
                }
                
                
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }

    @IBAction func addPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "newSeatRace", sender: self)
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

    
    func finished(lastView: Bool) {
        savedSeatRaes.isScrollEnabled = true
    }
    
    //MARK: Collection func
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (seatRaceArray.count == 0) {
            return 1
        }
        return seatRaceArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (seatRaceArray.count == 0) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as! seatRaceCell
            cell.seatRaceDate.text = "No Seat Racing Recorded"
            cell.distance.text = "Press + to record a new seat race"
            cell.distance.textAlignment = .center
            cell.seatRaceDate.textAlignment = .center
            cell.distance.textColor = .black
            cell.seatRaceDate.textColor = .black
            cell.numberOfCrews.text = ""
            cell.swaps.text = ""
            cell.backgroundColor = .white
            return cell
        }
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd, yyyy"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as! seatRaceCell
        cell.backgroundColor = UIColor.init(rgb: 0x1B2BD6)
        cell.layer.cornerRadius = 5.0
        
        let formattedDistance = varFormatter.distance(Measurement(value: Double(seatRaceArray[indexPath.row].distance), unit: UnitLength.meters))
        cell.distance.text = "Distance: \(formattedDistance)"
        let dateCurr = seatRaceArray[indexPath.row].date!
        cell.seatRaceDate.text = "Seat Race -- \(dateFormatterPrint.string(from: dateCurr))"
        let lowestRaceCount = lowestRaceCountFunc(seatRace: seatRaceArray[indexPath.row])
        let numberOfCres = numberOfBoats(seatRace: seatRaceArray[indexPath.row])
        cell.numberOfCrews.text = "Number of Crews: \(numberOfCres)"
        cell.swaps.text = "Number of Swaps: \(lowestRaceCount - 1) "
        cell.addGradientBackground(firstColor: UIColor.init(rgb: 0x1B2BD6), secondColor: UIColor.init(rgb: 0x3d85e7))
        return cell
    }
    
    func numberOfBoats(seatRace: SeatRace) -> Int{
        let seatRaceBoats = seatRace.boats?.sortedArray(using: [sortDescriptorSeatBoat]) as! [SeatRaceBoat]
        return seatRaceBoats.count
    }
    func lowestRaceCountFunc(seatRace: SeatRace) -> Int {
        let seatRaceBoats = seatRace.boats?.sortedArray(using: [sortDescriptorSeatBoat]) as! [SeatRaceBoat]
        var lowestRaceCount = 9999
        for boat in seatRaceBoats {
            let listOfBoatTimes = boat.times?.sortedArray(using: [sortDescriptorSeatBoatTimes]) as! [SeatRaceTime]
            if (listOfBoatTimes.count < lowestRaceCount) {
                lowestRaceCount = listOfBoatTimes.count
            }
           
        }
        return lowestRaceCount
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if (seatRaceArray.count == 0) {
            return false
        }
        let resultspopOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "seatRaceResultsPopUp") as! SeatRacingPopUpViewController
        let sortDescriptorSeatBoat = NSSortDescriptor(key: #keyPath(SeatRaceBoat.lane), ascending: true)
        self.addChild(resultspopOverVC)
        resultspopOverVC.delegate = self
        resultspopOverVC.seatRaceBoats = seatRaceArray[indexPath.row].boats?.sortedArray(using: [sortDescriptorSeatBoat]) as! [SeatRaceBoat]
        resultspopOverVC.seatRaceInfo = seatRaceArray[indexPath.row]
        resultspopOverVC.lastView = false //doesn't do anything
        resultspopOverVC.exportAllowed = true
        resultspopOverVC.savedView = true //So can readjust for lineup rowers pop up
        let visibleRect = CGRect(origin: savedSeatRaes.frame.origin, size: savedSeatRaes.visibleSize)
        
        
        resultspopOverVC.lastView = true //To stop crash
        resultspopOverVC.view.frame = visibleRect
        savedSeatRaes.isScrollEnabled = false
        self.view.addSubview(resultspopOverVC.view)
        resultspopOverVC.didMove(toParent: self)
        return true
    }
}
