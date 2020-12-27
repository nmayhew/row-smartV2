//
//  RaceHomeViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 28/08/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit
import CoreData

class raceHomeCell: UICollectionViewCell {
    
    @IBOutlet weak var raceNo: UILabel!
    @IBOutlet weak var raceDate: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var crewsNo: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}


class RaceHomeViewController: parentHomeViewController, UICollectionViewDataSource, resultsPopUpDelegate {
    
    let sortDescriptorBoat = NSSortDescriptor(key: #keyPath(Boat.lane), ascending: true)
    let sortDescriptorBoatTimes = NSSortDescriptor(key: #keyPath(BoatTimes.startTime), ascending: true)
    
    @IBOutlet weak var raceCollectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    private var raceArray: [Race] = []
    private var reuseID = "raceHomeCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        raceCollectionView.delegate = self
        raceCollectionView.dataSource = self
        setUpButtons(button: addButton)
        raceArray = getRaces()
        raceArray = deleteBadRaces()
        let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(RaceHomeViewController.handleLongPress(gestureRecognizer:)))
        lpgr.minimumPressDuration = 0.7
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = true
        self.raceCollectionView.addGestureRecognizer(lpgr)
        
    }
    
    @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
        //Validation check
        //Checking not placeholder cell
        if (raceArray.count == 0) {
            return
        }
        if (gestureRecognizer.state != UIGestureRecognizer.State.began){
            return
        }
        
        let p = gestureRecognizer.location(in: self.raceCollectionView)
        
        //Find indexPath, set up alert controller
        if let indexPath = (self.raceCollectionView.indexPathForItem(at: p)) {
            let alertController = UIAlertController(title: "Delete", message: "Confirm to delete this seat race", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Confirm", style: .destructive) { (_) -> Void in
                CoreDataStack.context.delete(self.raceArray[indexPath.row])
                CoreDataStack.saveContext()
                self.raceArray.remove(at: indexPath.row)
                if (self.raceArray.count != 0) {
                    self.raceCollectionView.deleteItems(at: [indexPath])
                } else {
                    self.raceCollectionView.reloadData()
                }
                
                
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    
    
    @IBAction func addButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "newRace", sender: self)
    }
    func deleteBadRaces() -> [Race] {
        var newRaceArray: [Race] = []
        for race in raceArray {
            let boats = race.boats?.sortedArray(using: [sortDescriptorBoat]) as! [Boat]
            if (boats.count == 0) {
                CoreDataStack.context.delete(race)
                    CoreDataStack.saveContext()
            } else {
                newRaceArray.append(race)
            }
        }
        
        return newRaceArray
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
    
    func finished(lastView: Bool) {
       raceCollectionView.isScrollEnabled = true
    }
   
    //MARK: Collection func
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (raceArray.count == 0) {
            return 1
        }
        return raceArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (raceArray.count == 0) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as! raceHomeCell
            cell.raceDate.text = "No Races Recorded"
            cell.distance.text = "Press + to record a new race"
            cell.distance.textAlignment = .center
            cell.raceDate.textAlignment = .center
            cell.distance.textColor = .black
            cell.raceDate.textColor = .black
            cell.crewsNo.text = ""
            cell.raceNo.text = ""
            cell.backgroundColor = .white
            return cell
        }
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd, yyyy"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as! raceHomeCell
        
        let formattedDistance = varFormatter.distance(Measurement(value: Double(raceArray[indexPath.row].distance), unit: UnitLength.meters))
        let boats = raceArray[indexPath.row].boats?.sortedArray(using: [sortDescriptorBoat]) as! [Boat]
        let listOfTimes = boats[0].boattimes?.sortedArray(using: [sortDescriptorBoatTimes]) as! [BoatTimes]
        if (listOfTimes.count == 1) {
            cell.distance.text = " Distance: \(formattedDistance)"
            cell.raceNo.text = ""
        } else {
            cell.distance.text = " \(listOfTimes.count) * \(formattedDistance)"
            let totalDistanceText = listOfTimes.count * Int(raceArray[indexPath.row].distance)
            cell.raceNo.text = " Total Distance: \(totalDistanceText) m"
        }
        let dateCurr = raceArray[indexPath.row].date!
        cell.raceDate.text = " Racing - \(dateFormatterPrint.string(from: dateCurr))"
        if (boats.count == 1) {
            cell.crewsNo.text = " \(boats.count) Crew"
        } else {
            cell.crewsNo.text = " \(boats.count) Crews"
        }
        
        //cell.raceNo.text = " \(listOfTimes.count) Sets"
        cell.addGradientBackground(firstColor: UIColor.init(rgb: 0x1B2BD6), secondColor: UIColor.init(rgb: 0x3d85e7))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        //Race //Uses pop up used in final of races
        if (raceArray.count == 0) {
            return false
        }
        let resultspopOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "currResultsPopUp") as! ResultsPopUpViewController
        self.addChild(resultspopOverVC)
        resultspopOverVC.lastView = false //To stop crash
        resultspopOverVC.delegate = self
        resultspopOverVC.exportAllowed = true
        resultspopOverVC.raceBoatsInfo = raceArray[indexPath.row].boats?.sortedArray(using: [sortDescriptorBoat]) as! [Boat]
        resultspopOverVC.raceInfo = raceArray[indexPath.row]
        let visibleRect = CGRect(origin: raceCollectionView.frame.origin, size: raceCollectionView.visibleSize)
        resultspopOverVC.view.frame = visibleRect
        self.view.addSubview(resultspopOverVC.view)
        resultspopOverVC.didMove(toParent: self)
        raceCollectionView.isScrollEnabled = false
        return true
    }

}
