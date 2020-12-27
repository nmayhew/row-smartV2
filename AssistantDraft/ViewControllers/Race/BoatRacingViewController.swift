//
//  RacingBoatViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 23/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit

class RacingBoatViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, resultsPopUpDelegate, startDelegate, finishDelegate {
    
    
    
    
    
    
    //BoatCollection class
    private let sortDescriptorBoatTimes = NSSortDescriptor(key: #keyPath(BoatTimes.startTime), ascending: true)
    private let itemsPerRow: CGFloat = 2
    private let reuseIdentifier = "boatTimingCell"
    private let sectionInsets = UIEdgeInsets(top: 50.0,
                                             left: 20.0,
                                             bottom: 50.0,
                                             right: 20.0)
    
    var currRace: Race?
    var currRaceBoats: [Boat] = []
    var finishedCheck = false
    
    @IBOutlet weak var collectionOfBoats: UICollectionView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var startAll: UIBarButtonItem!
    @IBOutlet weak var finish: UIBarButtonItem!
    @IBOutlet weak var currentResults: UIBarButtonItem!
    
    private var allBoatInfo: [BoatInfo] = []
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionOfBoats.delegate = self
        collectionOfBoats.dataSource = self
        collectionOfBoats.allowsSelection = true

        startAll.isEnabled = true
        allBoatInfo = createAllBoats()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.eachDeciSecond()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.closeActivityController), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openactivity), name: UIApplication.didBecomeActiveNotification, object: nil)

    }
    
    //When app goes into background
    @objc func closeActivityController()  {
        for boat in allBoatInfo {
            if(boat.started == true && boat.finished == false) {
                boat.backgroundDate = Date()
            }
        }
    }
    
    //When app enters foreground
    @objc func openactivity()  {
        for boat in allBoatInfo {
            if(boat.started == true && boat.finished == false) {
                var elapsed = Date().timeIntervalSince(boat.backgroundDate!) // Seconds
                elapsed = round(elapsed * 10)//Whole deciseconds
                boat.deciSeconds = boat.deciSeconds + Int(elapsed)//
            }
        }
    }
    
    //Creates a new BoatInfo class for every boat
    func createAllBoats() -> [BoatInfo] {
        var allBoats: [BoatInfo] = []
        for boat in currRaceBoats {
            let newBoatInfo = BoatInfo()
            newBoatInfo.backgroundColour = .lightGray
            newBoatInfo.delegate = self
            newBoatInfo.finishDelegate = self
            newBoatInfo.timer?.invalidate()
            newBoatInfo.boatNameString = "\(boat.boatName!)"
            newBoatInfo.laneString = "Lane: \(boat.lane)"
            let formattedTime = varFormatter.detailTime(0)
            newBoatInfo.deciSeconds = 0
            newBoatInfo.timeString = formattedTime
            allBoats.append(newBoatInfo)
        }
        return allBoats
    }
    
    //Resets all BoatInfo objects for a new race
    func resetAllBoats() {
        for boat in allBoatInfo {
            boat.backgroundColour = .lightGray
            boat.timer?.invalidate()
            let formattedTime = varFormatter.detailTime(0)
            boat.deciSeconds = 0
            boat.timeString = formattedTime
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            //Done if back is pressed so two races aren't created
            navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            CoreDataStack.context.delete(currRace!)
        }
    }
    //Starts rest of boats
    @IBAction func startAll(_ sender: Any) {
        startAllBoats()
    }
    
    //Saves times, resets and pop ups results
    @IBAction func finish(_ sender: Any) {
        //Check at least one race started
        var noneFinished = true
        for index in 0...allBoatInfo.count - 1 {
            if (allBoatInfo[index].finished == true) {
                noneFinished = false
            }
            let times = currRaceBoats[index].boattimes?.sortedArray(using: [sortDescriptorBoatTimes]) as! [BoatTimes]
            for _ in times {
                noneFinished = false
            }
        }
        
        if (noneFinished) {
            let alertController = UIAlertController(title: "No Times Recorded", message: "You have no recorded times. Cancel or no race will be saved", preferredStyle: .alert)
            
            // Create the actions
            let returnAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) {
                UIAlertAction in
            }
            
            let deleteAction = UIAlertAction(title: "Delete Race", style: UIAlertAction.Style.destructive) {
                UIAlertAction in
                for boat in self.currRaceBoats {
                    CoreDataStack.context.delete(boat)
                }
                CoreDataStack.context.delete(self.currRace!)
                self.segueHome()
                
            }
            alertController.addAction(returnAction)
            alertController.addAction(deleteAction)
            // Present the controller
            self.present(alertController, animated: true, completion: nil)
        } else {
            finishedCheck = true
            var anyStarted = false
            for index in 0...allBoatInfo.count - 1 {
                
                if (allBoatInfo[index].started == true) {
                    anyStarted = true
                }
            }
            if (anyStarted) {
                for index in 0...allBoatInfo.count - 1 {
                    if (allBoatInfo[index].finished == false) {
                        if (allBoatInfo[index].started == false) {
                            allBoatInfo[index].cellPressed()
                        }
                        allBoatInfo[index].cellPressed()
                    }
                }
            } else {
                popUpResults(lastView: finishedCheck)
            }
            
        }
        //When closes finished is called using delegate in popUpResults class
        
    }
    //Just pops up current results
    @IBAction func currentResults(_ sender: Any) {
        popUpResults(lastView: false)
    }
    
    //MARK: Delegate calls
    //Saves results and ends view controller.
    func finished(lastView: Bool) {
        if(lastView) {
             saveResultsFinal()
        }
    }
    
    func finishPressed() {
        var allFinished = true
        for index in 0...allBoatInfo.count - 1 {
            if (allBoatInfo[index].finished != true) {
                allFinished = false
            }
        }
        
        if (allFinished) {
            let alert = UIAlertController(title: "Finished Race", message: "Please select if you want to finish racing or want to save and repeat the race.", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Repeat", style: .default, handler: { (_) in
                self.addCurrTimes()
            }))
            alert.addAction(UIAlertAction(title: "Finished Racing", style: .default, handler: { (_) in
                self.addCurrTimes()
                self.finishedCheck = true
                self.popUpResults(lastView: true)
            }))
            self.present(alert, animated: true, completion: {
            })
        }
    }
    
    func startPressed() {
        self.navigationController?.viewControllers = [self]
        var allStarted = true
        for index in 0...allBoatInfo.count - 1 {
            if (allBoatInfo[index].started == false) {
                allStarted = false
            }
        }
        if (allStarted) {
            startAll.isEnabled = false
        }
        
    }
    
    //Saves final results
    func saveResultsFinal() {
        //Just save race and go home screen
        for boat in currRaceBoats {
            currRace?.addToBoats(boat)
        }
        CoreDataStack.saveContext()
        //CoreDataStack.context.delete(currRace!)
        
        self.segueHome()
    }
    
    //Starts all boats at same time if haven't already been started.
    func startAllBoats() {
        for index in 0...allBoatInfo.count - 1 {
            
            if (allBoatInfo[index].started == false) {
                allBoatInfo[index].cellPressed()
            }
        }
        startAll.isEnabled = false
    }
    
    //MARK: Useful functions
    //Pops up results view controller
    func popUpResults(lastView: Bool) {
        let resultspopOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "currResultsPopUp") as! ResultsPopUpViewController
        self.addChild(resultspopOverVC)
        resultspopOverVC.delegate = self
        resultspopOverVC.raceBoatsInfo = currRaceBoats
        resultspopOverVC.raceInfo = currRace
        resultspopOverVC.view.frame = self.view.frame
        resultspopOverVC.lastView = lastView
        
        self.view.addSubview(resultspopOverVC.view)
        resultspopOverVC.didMove(toParent: self)
    }
    
    //Saves times (ends timers if needed) and resets the timing
    func addCurrTimes() {
        //Validation
        var noProperTimes = true
        for index in 0...allBoatInfo.count - 1 {
            
            if (allBoatInfo[index].deciSeconds != 0) {
                noProperTimes = false
            }
        }
        if (noProperTimes) {
            resetAllBoats()
            collectionOfBoats.reloadData()
            startAll.isEnabled = true
            return
        }
        //Save
        for index in 0...allBoatInfo.count - 1 {
            
            let newTime = BoatTimes(context: CoreDataStack.context)
            newTime.startTime = allBoatInfo[index].startTime
            newTime.timeDeciSeconds = Int32(allBoatInfo[index].deciSeconds)
            currRaceBoats[index].addToBoattimes(newTime)
            
            //Reset Screen
            allBoatInfo[index].started = false
            allBoatInfo[index].finished = false
        }
        resetAllBoats()
        collectionOfBoats.reloadData()
        startAll.isEnabled = true
    }
    
    //MARK: Collection View delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currRaceBoats.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.row == currRaceBoats.count) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rateMonitor", for: indexPath) as! RateMonitorCollectionViewCell
            cell.backgroundColor = UIColor.init(rgb: 0xFF7417)
            cell.rateMonitor.textColor = UIColor.white
            cell.layer.cornerRadius = 5.0
            cell.layer.shadowColor = UIColor.lightGray.cgColor
            cell.layer.shadowOpacity = 0.8
            cell.layer.shadowOffset = CGSize(width: 0, height: 4.0)
            cell.layer.shadowRadius = 3
            cell.rateMonitor.text = "Rate Tracker"
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        //MARK: Layer UI
        cell.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOpacity = 0.8
        cell.layer.shadowOffset = CGSize(width: 0, height: 4.0)
        cell.layer.shadowRadius = 3
        cell.backgroundColor = allBoatInfo[indexPath.row].backgroundColour
        cell.boatName.text = allBoatInfo[indexPath.row].boatNameString
        cell.lane.text = allBoatInfo[indexPath.row].laneString
        cell.time.text = allBoatInfo[indexPath.row].timeString
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        allBoatInfo[indexPath.row].cellPressed()
    }
    
    //MARK: Segue prepartion
    func segueHome() {
        let navHomeDest = self.storyboard?.instantiateViewController(withIdentifier: "NavHomeID")as! NavController
        let homeView = navHomeDest.viewControllers.first! as! HomeViewController2nd
        homeView.index = 1
        UIApplication.shared.keyWindow?.rootViewController = navHomeDest

    }
    
    
    
    
    //MARK: Timer function
    func eachDeciSecond() {
        for indexPath in collectionOfBoats.indexPathsForVisibleItems {
            if (indexPath.row == currRaceBoats.count) {
                //Rate monitor ignore
            } else {
                let cell = collectionOfBoats.cellForItem(at: indexPath) as! CollectionViewCell
                cell.time.text = allBoatInfo[indexPath.row].timeString
                cell.backgroundColor = allBoatInfo[indexPath.row].backgroundColour
            }
            
        }
    }
}

// MARK: - Collection View Flow Layout Delegate
extension RacingBoatViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
