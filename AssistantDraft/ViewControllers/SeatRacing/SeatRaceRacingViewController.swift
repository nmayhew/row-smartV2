//
//  RacingSeatRaceViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 03/08/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit



class RacingSeatRaceViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, resultsPopUpDelegate,startDelegate, finishDelegate {
    
    
    //BoatCollection class
    private let itemsPerRow: CGFloat = 2
    private let reuseIdentifier = "boatTimingCell"
    var currRace: SeatRace?
    var currRaceBoats: [SeatRaceBoat] = []
    let sectionInsets = UIEdgeInsets(top: 50.0,
                                     left: 20.0,
                                     bottom: 50.0,
                                     right: 20.0)
    var finishedCheck = false
    var raceNo = 1
    
    @IBOutlet weak var collectionOfBoats: UICollectionView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var startAll: UIBarButtonItem!
    @IBOutlet weak var finish: UIBarButtonItem!
    @IBOutlet weak var currentResults: UIBarButtonItem!
    
    var allBoatInfo: [BoatInfo] = []
    var timer: Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionOfBoats.delegate = self
        collectionOfBoats.dataSource = self
        currentResults.isEnabled = false
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
            //Done if back is pressed so delete all rowers and all times that are created when go back
            for boat in currRaceBoats {
                deleteBoatDetails(boat: boat)
            }
            
        }
    }
    
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
    
    //Starts rest of boats
    @IBAction func startAll(_ sender: Any) {
        startAllBoats()
    }
    
    //Add Current times with lineups, then moves on to swap screens to get new lineups
    func popUpSwaps() {
        let swapPopOver = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "swapOverview") as! SwapRowersOverviewViewController
        self.addChild(swapPopOver)
        swapPopOver.seatRaceBoats = currRaceBoats
        swapPopOver.currSeatRace = currRace
        swapPopOver.raceNo = raceNo
        swapPopOver.view.frame = self.view.frame
        self.view.addSubview(swapPopOver.view)
        swapPopOver.didMove(toParent: self)
    }
    
    //Only adding time here, lineups and raceNo already entered
    func addCurrTimes() {
        for index in 0...allBoatInfo.count - 1 {
            
            //Get correct boat
            let currBoat = currRaceBoats[index]
            let sortDescriptorSeatBoatTimes = NSSortDescriptor(key: #keyPath(SeatRaceTime.raceNo), ascending: false)
            let times = currBoat.times?.sortedArray(using: [sortDescriptorSeatBoatTimes]) as! [SeatRaceTime]
            times.first?.deciSeconds = Int32(allBoatInfo[index].deciSeconds)
            //Reset Screen
            allBoatInfo[index].started = false
            allBoatInfo[index].finished = false
        }
        resetAllBoats()
        collectionOfBoats.reloadData()
        startAll.isEnabled = true
        //Increment race 
        raceNo = raceNo + 1
        if (raceNo > 1) {
            currentResults.isEnabled = true
        }
        //checkTempWorks()
    }
    
    /* USED FOR TESTING
     func checkTempWorks() {
     for currIndex in 0...currRaceBoats.count - 1 {
     let currBoat = currRaceBoats[currIndex]
     
     let sortDescriptorSeatBoatTimes = NSSortDescriptor(key: #keyPath(SeatRaceTime.raceNo), ascending: false)
     let times = currBoat.times?.sortedArray(using: [sortDescriptorSeatBoatTimes]) as! [SeatRaceTime]
     print("All times: \(times)")
     for time in times {
     print("time: \(time.deciSeconds)")
     print("race No: \(time.raceNo)")
     let sortDescriptorRowersSeat = NSSortDescriptor(key: #keyPath(Rower_Seat.seat), ascending: true)
     let rowersSeatInBoat = time.lineUp?.sortedArray(using: [sortDescriptorRowersSeat]) as! [Rower_Seat]
     for rower in rowersSeatInBoat {
     print("rower: \(rower.rower)")
     print("Seat: \(rower.seat)")
     }
     
     }
     }
     }*/
    
    //Saves times Pop ups results
    @IBAction func finish(_ sender: Any) {
        if (raceNo == 1) {
            let alert = UIAlertController(title: "No Swaps", message: "You have performed no swaps. If you continue, nothing will be saved.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Continue", style: .destructive, handler:  { action in
                CoreDataStack.context.delete(self.currRace!)
                for boat in self.currRaceBoats {
                    self.deleteBoatDetails(boat: boat)
                    CoreDataStack.context.delete(boat)
                }
                self.segueHome()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
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
                
            }else {
                popUpResults()
            }
        }
        //When closes finished is called using delegate
    }
    
    func deleteBoatDetails(boat:SeatRaceBoat) {
        //Deletes all times rowers and rower_seat
        let sortDescriptorSeatBoatTimes = NSSortDescriptor(key: #keyPath(SeatRaceTime.raceNo), ascending: false)
        let sortDescriptorRowers_Seat = NSSortDescriptor(key: #keyPath(Rower_Seat.seat), ascending: true)
        let seatRaceTimes = boat.times!.sortedArray(using: [sortDescriptorSeatBoatTimes]) as! [SeatRaceTime]
        for seatRaceTime in seatRaceTimes {
            let rowersInBoat = seatRaceTime.lineUp?.sortedArray(using: [sortDescriptorRowers_Seat]) as! [Rower_Seat]
            for rower_seat in rowersInBoat {
                
                let rower = rower_seat.rower
                CoreDataStack.context.delete(rower!)
                CoreDataStack.context.delete(rower_seat)
            }
            CoreDataStack.context.delete(seatRaceTime)
        }
    }
    //Just pops up current results
    @IBAction func currentResults(_ sender: Any) {
        //Don't want to pop up currently going on race that has been registered yet
        popUpResults()
        
    }
    
    
    //MARK:Delegate calls
    func finishPressed() {
        var allFinished = true
        for index in 0...allBoatInfo.count - 1 {
            if (allBoatInfo[index].finished != true) {
                allFinished = false
            }
        }
        if (allFinished && raceNo > 1) {
            let alert = UIAlertController(title: "Finished Seat Race", message: "Please select if you want to finish or if you want to perform another seat race.", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Swap", style: .default, handler: { (_) in
                //Take lineups in most recent seatRactBoat (largest race number is sort Descriptor)
                self.addCurrTimes()
                //Go to swaps
                self.popUpSwaps()
            }))
            alert.addAction(UIAlertAction(title: "Finished", style: .default, handler: { (_) in
                
                self.addCurrTimes()
                self.finishedCheck = true
                self.popUpResults()
                
            }))
            
            
            self.present(alert, animated: true, completion: {
                print("completion block")
            })
        } else if (allFinished && raceNo == 1) {
            let alert = UIAlertController(title: "Finished Seat Race", message: "Please indicate your first swap.", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Swap", style: .default, handler: { (_) in
                //Take lineups in most recent seatRactBoat (largest race number is sort Descriptor)
                self.addCurrTimes()
                //Go to swaps
                self.popUpSwaps()
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
    //Saves results and ends view controller
    func finished(lastView: Bool) {
        if (lastView) {
            saveResultsFinal()
        }
    }
    
    //Saves final results
    func saveResultsFinal() {
        //Just save race and go home screen
        for boat in currRaceBoats {
            currRace?.addToBoats(boat)
        }
        CoreDataStack.saveContext()
        //Delete from context
        //CoreDataStack.context.delete(currRace!)
        segueHome()
    }
    
    //Pops up results view controller
    func popUpResults() {
        let resultspopOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "seatRaceResultsPopUp") as! SeatRacingPopUpViewController
        self.addChild(resultspopOverVC)
        resultspopOverVC.delegate = self
        resultspopOverVC.seatRaceBoats = currRaceBoats
        resultspopOverVC.seatRaceInfo = currRace
        resultspopOverVC.lastView = finishedCheck
        //TODO: If first swap,
        if (raceNo == 2) {
            //Get result but no swaps
            resultspopOverVC.preSwaps = true
        }
        resultspopOverVC.view.frame = self.view.frame
        self.view.addSubview(resultspopOverVC.view)
        resultspopOverVC.didMove(toParent: self)
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
    
    //MARK: Collection View delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currRaceBoats.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.row == currRaceBoats.count) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rateMonitor", for: indexPath) as! RateMonitorCollectionViewCell
            cell.backgroundColor = UIColor.init(rgb: 0xFF7417)
            cell.rateMonitor.textColor = UIColor.white
            cell.layer.cornerRadius = Constants.CORNERRAD
            cell.layer.shadowColor = UIColor.lightGray.cgColor
            cell.layer.shadowOpacity = 0.8
            cell.layer.shadowOffset = CGSize(width: 0, height: 4.0)
            cell.layer.shadowRadius = 3
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        
        cell.layer.cornerRadius = Constants.CORNERRAD
        
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        allBoatInfo[indexPath.row].cellPressed()
    }
    //MARK: Segue
    func segueHome() {
        let navHomeDest = self.storyboard?.instantiateViewController(withIdentifier: "NavHomeID")as! NavController
        let homeView = navHomeDest.viewControllers.first! as! HomeViewController2nd
        homeView.index = 0
        UIApplication.shared.keyWindow?.rootViewController = navHomeDest

    }
}

// MARK: - Collection View Flow Layout Delegate
extension RacingSeatRaceViewController : UICollectionViewDelegateFlowLayout {
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



