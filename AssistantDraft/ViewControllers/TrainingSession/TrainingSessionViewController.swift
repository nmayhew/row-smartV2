//
//  TrainingSessionViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 04/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit
import CoreLocation

//Overview of training session view controller 
class TrainingSessionViewController: UIViewController, sendNotes, sendPieces, piecesLoaded, notesLoaded {

    
    private var embeddedPageViewController: PageViewController!
    private var start = false
    private var piecesLoaded = false
    private var notesLoaded = false

    //MARK: Labels
    @IBOutlet weak var totalTime: UILabel!
    @IBOutlet weak var totalDistance: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var splitLabel: UILabel!
    @IBOutlet weak var subViews: UIView! //container view
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var SPM: UIButton!
    @IBOutlet weak var SPMLabel: UILabel!
    
    
    //MARK: CoachNotes
    private var coachNotes: String = ""
    
    //MARK: Splits
    private var piecesArray: [Piece] = []
    
    //MARK:GPS vars
    private let locationManager = LocationManager.shared
    private var seconds = 0
    private var timer: Timer?
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    private var locationList: [CLLocation] = []
    private var colorTimer = Timer()
    
    //MARK: Split Information
    var splitPresses: [TimeInterval] = []
    @IBAction func SPMpressed(_ sender: Any) {
            let currentTime = Date().timeIntervalSince1970
            let currColor = SPM.backgroundColor
            SPM.backgroundColor = currColor?.withAlphaComponent(0.8)
            colorTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.restoreColor), userInfo: nil, repeats: false)
            if (splitPresses.count > 1) {
                let twoDiff = currentTime - splitPresses[splitPresses.count-1] + splitPresses[splitPresses.count-1] - splitPresses[splitPresses.count-2]
                let splitRe = twoDiff / 120
                let split = 1.0 / splitRe
                let rounded = round(split*10.0)/10.0
                if (rounded > 60 || rounded < 5) {
                    SPMLabel.text = "Only press \n at catch"
                } else {
                    SPMLabel.text = "\(rounded) SPM"
                }
            } else {
                SPMLabel.text = "More strokes"
            }
            splitPresses.append(currentTime)
            let splitDataDict:[String: [TimeInterval]] = ["spmTimes": splitPresses]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "spmSent"), object: nil, userInfo: splitDataDict)
    }
    
    
    @objc func restoreColor() {
        let currColor = SPM.backgroundColor
        SPM.backgroundColor = currColor?.withAlphaComponent(1)
    }
        

    
    
    
    //MARK: Saved
    var saved = false
    private var savedNotes = false
    private var savedPieces = false
    
    //Sets up observer for new notes and pieces
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        totalTime.isHidden = true
        totalDistance.isHidden = true
        stopButton.isHidden = true
        
        //To Conform to rate monitor cells
        SPM.setTitleColor(UIColor.white, for: .normal)
        SPM.setTitleColor(UIColor.white, for: .selected)
        SPM.backgroundColor = UIColor.init(rgb: 0xFF7417)
        SPM.layer.cornerRadius = 5.0
        startButton.layer.cornerRadius = 5.0
        stopButton.layer.cornerRadius = 5.0
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            locationManager.allowsBackgroundLocationUpdates = false
            locationManager.stopUpdatingLocation()
            locationManager.stopUpdatingHeading()
            
            timer?.invalidate()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //Allows back swipe
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    
    
    //MARK: Delegate calls
    func pageLoaded() {
        piecesLoaded = true
        notifyOfStart()
    }
    func loadNotes() {
        notesLoaded = true
    }
    
    func sendNotes(notes: String) {
        if (notes == "Coaches' Notes" || notes == "") {
            coachNotes = "No notes entered"
        } else {
            coachNotes = notes
        }
        savedNotes = true
        readyToSaveAndSegue()
    }
    
    func sendPieces(pieces: [Piece]) {
        piecesArray = pieces
        savedPieces = true
        readyToSaveAndSegue()
    }
    
    func readyToSaveAndSegue() {
        if (savedPieces && savedNotes && !saved) {
            saveSession()
            segueHome()
        }
    }
    

    //Starts the session
    @IBAction func startButton(_ sender: UIButton) {
        start = true
        seconds = 0
        distance = Measurement(value: 0, unit: UnitLength.meters)
        locationList.removeAll()
        updateDisplay()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.eachSecond()
        }
        startLocationUpdates()
        totalDistance.isHidden = false
        totalTime.isHidden = false
        startButton.isHidden = true
        notifyOfStart()
        
    }
    
    func notifyOfStart() {
        if (start) {
            NotificationCenter.default.post(name: NSNotification.Name.init("trainingSessionStarted"), object: nil)
        }
    }
    
    //Ends the session
    @IBAction func stopButton(_ sender: Any) {
        timer?.invalidate()
        
        if (!piecesLoaded && !notesLoaded) {
            //No Pieces or Notes
            coachNotes = "No notes entered"
            savedNotes = true
            savedPieces = true
            saveSession()
            segueHome()
        } else if (!notesLoaded){
            //No Notes
            coachNotes = "No notes entered"
            savedNotes = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "confirmSession"), object: nil)
            
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "confirmSession"), object: nil)
        }
        
        //Ends GPS data
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        
        
    }
    
    //Uses coreData to save Session with all details
    func saveSession() {
        let saveSession = TrainingSession(context: CoreDataStack.context)
        saveSession.coachNotes = coachNotes
        saveSession.date = Date()
        saveSession.distance = Int32(distance.value)
        saveSession.duration = Int32(seconds)
        for location in locationList {
            let locationObject = Location(context: CoreDataStack.context)
            locationObject.timestamp = location.timestamp
            locationObject.latitude = location.coordinate.latitude
            locationObject.longitude = location.coordinate.longitude
            saveSession.addToLocations(locationObject)
        }
        for piece in piecesArray {
            saveSession.addToPieces(piece) //MAY NOT WORK CHECK!!
        }
        CoreDataStack.saveContext()
        //CoreDataStack.context.delete(saveSession)
        saved = true
    }
    
    //Called by timer every second
    func eachSecond() {
        seconds += 1
        if (locationList.count > 1) {
            let locationDataDict:[String: [CLLocation]] = ["locations": locationList]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "locationSent"), object: nil, userInfo: locationDataDict)//Send Locations off
        }
        
        updateDisplay()
    }
    
    //Updates display called by each second
    private func updateDisplay() {
        let formattedDistance = varFormatter.distance(distance)
        let formattedTime = varFormatter.time(seconds)
        
        totalDistance.text = "Total Distance:  \(formattedDistance)"
        totalTime.text = "Total Time:  \(formattedTime)"
        
        //Use locationlist to get ave split over last 10 seconds 
        if (locationList.count < 2) {
            return
        }
        let recentCLLocation = locationList.last!
        let recentTime = recentCLLocation.timestamp.timeIntervalSince1970
        var countBa = locationList.count - 2
        var timeDiff: TimeInterval = 0.0
        var distanceCurr = Measurement(value: 0, unit: UnitLength.meters)
        var temp: CLLocation = recentCLLocation
        
        while (timeDiff < 10 && countBa > 0) {
            timeDiff = recentTime - locationList[countBa].timestamp.timeIntervalSince1970
            distanceCurr = distanceCurr + Measurement(value: temp.distance(from: locationList[countBa]), unit: UnitLength.meters)
            temp = locationList[countBa]
            countBa -= 1
        }
        
        let formattedPace = varFormatter.pace(distance: distanceCurr,
                                              seconds: Int(timeDiff),
                                              outputUnit: UnitSpeed.secondsPerFiveHundredMeter)
        splitLabel.text = "Last 10s Split \n \(formattedPace)"
    }
    
    //As name states
    private func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 7
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    //MARK: Segue prep
    //Stop session can't re run until everything is saved
    func segueHome() {
        if (saved == false) {
            return
        }
        let navHomeDest = self.storyboard?.instantiateViewController(withIdentifier: "NavHomeID")as! NavController
        let homeView = navHomeDest.viewControllers.first! as! HomeViewController2nd
        homeView.index = 2
        UIApplication.shared.keyWindow?.rootViewController = navHomeDest
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TrainingSessionSubViews" {
            let dest = segue.destination as! PageViewController
            self.embeddedPageViewController = dest
            dest.parentViewContr = self
        }
        
    }
}

//MARK: Location updates and heading updates inc. some error checking to see not erroneous
extension TrainingSessionViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let headingDataDict:[String: CLHeading] = ["currHeading": newHeading]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "headingSent"), object: nil, userInfo: headingDataDict)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for newLocation in locations {
            
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            
            if let lastLocation = locationList.last {
                let delta = newLocation.distance(from: lastLocation)
                distance = distance + Measurement(value: delta, unit: UnitLength.meters)
            }
            
            locationList.append(newLocation)
            stopButton.isHidden = false //So can't stop without some locations
            
        }
    }
}
