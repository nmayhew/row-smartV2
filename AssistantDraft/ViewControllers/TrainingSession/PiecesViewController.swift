//
//  PiecesViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 11/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit
import CoreLocation

//MARK: Cell declaration
class pieceTableCell: UITableViewCell {
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var restTime: UILabel!
    @IBOutlet weak var runTime: UILabel!
    @IBOutlet weak var aveSplit: UILabel!
}
protocol piecesLoaded {
    func pageLoaded()
}
protocol sendPieces {
    func sendPieces(pieces: [Piece])
}



class PiecesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //MARK: Pieces Label
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopPieces: UIButton!
    @IBOutlet weak var piecesTable: UITableView!
    @IBOutlet weak var runTime: UILabel!
    @IBOutlet weak var pieceNo: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var restTime: UILabel!
    @IBOutlet weak var aveSplit: UILabel!
    
    var delegate: sendPieces?
    var delegateLoaded: piecesLoaded?
    private var piecesArray: [Piece] = []
    private var backgroundTime: Date?
    
    
    //MARK: pieceInformation
    private var runSeconds = 0
    private var restSeconds = 0
    private var distanceCurr = Measurement(value: 0, unit: UnitLength.meters)
    private var run = false
    private var first = true
    private var pieceNumber = 1
    private var pieceDate: Date?
    private var timer: Timer?
    private var pieceLocations: [CLLocation] = []
    
    @IBOutlet weak var currentPiece: UIView!
    
    //Called on opening.
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        piecesTable.roundCorners()
        piecesTable.layer.borderColor = UIColor.lightGray.cgColor
        piecesTable.layer.borderWidth = 1.0
        piecesTable.delegate = self
        piecesTable.dataSource = self
        setUpButtons()
        
        NotificationCenter.default.addObserver(self, selector: #selector(locationRecieved), name: NSNotification.Name(rawValue: "locationSent"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(confirmSession), name: NSNotification.Name(rawValue: "confirmSession"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(trainingSessionStarted), name: NSNotification.Name(rawValue: "trainingSessionStarted"), object: nil)
        
        self.delegateLoaded?.pageLoaded()
    }
    
    //Set up appearance of buttons
    func setUpButtons() {
        startButton.layer.cornerRadius = Constants.CORNERRAD
        stopPieces.layer.cornerRadius = Constants.CORNERRAD
        stopPieces.isEnabled = false
        startButton.isEnabled = false
        let disabledColor = stopPieces.titleColor(for: .normal)?.withAlphaComponent(0.5)
        stopPieces.setTitleColor(disabledColor, for: .disabled)
        startButton.setTitleColor(disabledColor, for: .disabled)
    }
    
    //Function call by observer to update pieces
    @objc func confirmSession(notification: NSNotification) {
        //End Session
        if (stopPieces.isEnabled) {
             stopPressed(self)
        }
        self.delegate?.sendPieces(pieces: piecesArray)
    }
    
    //When training session started
    @objc func trainingSessionStarted(notification: NSNotification) {
        startButton.isEnabled = true
    }
    
    //When new location is received from NotificationCenter
    @objc func locationRecieved(notification: NSNotification) {
        if (run && !first) {
            if let locations = notification.userInfo?["locations"] as? [CLLocation] {
                let locationLast = locations.last!
                if (pieceLocations.isEmpty) {

                    pieceLocations.append(locationLast)
                } else {
                    let delta = locationLast.distance(from: pieceLocations.last!)
                    distanceCurr = distanceCurr + Measurement(value: delta, unit: UnitLength.meters)
                    pieceLocations.append(locationLast)
                }
                let formattedDistance = varFormatter.distance(distanceCurr)
                let formattedPace = varFormatter.pace(distance: distanceCurr, seconds: runSeconds, outputUnit: UnitSpeed.secondsPerFiveHundredMeter)
                distance.text = "\(formattedDistance)"
                aveSplit.text = "\(formattedPace)"
            }
        }
    }
    
    //When user starts/stops a piece using start/stop piece button
    @IBAction func startPieces(_ sender: Any) {
        if (first) {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.eachSecond()
            }
            stopPieces.isEnabled = true
            first = false
            //Ready for first piece
            run = true
            pieceDate = Date()
            pieceNo.text = "Piece \(pieceNumber)"
            let formattedRestTime = varFormatter.time(restSeconds)
            let formattedRunTime = varFormatter.time(runSeconds)
            runTime.text = "Time: \(formattedRunTime)"
            restTime.text = "Rest: \(formattedRestTime)"
            startButton.setTitle("Start rest", for: .normal)
            run = true
        } else if (run) {
            run = false
            
            startButton.setTitle("Start piece \(pieceNumber+1)", for: .normal)
        } else {
            savePiece()
            //Reset for next piece
            pieceNumber += 1
            pieceLocations = []
            run = true
            pieceDate = Date()
            distanceCurr.value = 0.0
            runSeconds = 0
            restSeconds = 0
            pieceNo.text = "Piece \(pieceNumber)"
            let formattedRestTime = varFormatter.time(restSeconds)
            let formattedRunTime = varFormatter.time(runSeconds)
            runTime.text = "Time: \(formattedRunTime)"
            restTime.text = "Rest: \(formattedRestTime)"
            startButton.setTitle("Start rest", for: .normal)
        }
    }
    
    //When stop is pressed
    @IBAction func stopPressed(_ sender: Any) {
        stopPieces.isEnabled = false
        savePiece()
        //Reset for new start
        timer?.invalidate()
        first = true
        run = false
        distanceCurr.value = 0.0
        runSeconds = 0
        restSeconds = 0
        pieceLocations = []
        
        let formattedRestTime = varFormatter.time(restSeconds)
        let formattedRunTime = varFormatter.time(runSeconds)
        
        let formattedDistance = varFormatter.distance(distanceCurr)
        let formattedPace = varFormatter.pace(distance: distanceCurr, seconds: runSeconds, outputUnit: UnitSpeed.secondsPerFiveHundredMeter)
        
        distance.text = "\(formattedDistance)"
        aveSplit.text = "\(formattedPace)"
        runTime.text = "Time: \(formattedRunTime)"
        restTime.text = "Rest: \(formattedRestTime)"
        pieceNumber += 1
        startButton.setTitle("Start piece \(pieceNumber)",
            for: .normal)
            pieceNo.text = "Piece "
        
    }
    
    //Saving a piece, Not to core data but placing in Piece array which is posted to notification center
    func savePiece(){
        let savePiece = Piece(context: CoreDataStack.context)
        savePiece.distance = Int32(distanceCurr.value)
        savePiece.lengthTime = Int16(runSeconds)
        savePiece.pieceNo = Int16(pieceNumber)
        savePiece.restTime = Int16(restSeconds)
        savePiece.split = varFormatter.pace(distance: distanceCurr, seconds: runSeconds, outputUnit: UnitSpeed.secondsPerFiveHundredMeter)
        savePiece.startTime = pieceDate
        
        for location in pieceLocations {
            let locationObject = Location(context: CoreDataStack.context)
            locationObject.timestamp = location.timestamp
            locationObject.latitude = location.coordinate.latitude
            locationObject.longitude = location.coordinate.longitude
            savePiece.addToLocations(locationObject)
        }
        piecesArray.append(savePiece)
        piecesTable.reloadData()
    }
    
    //Called every second to update display
    func eachSecond() {
        if (run) {
            runSeconds += 1
            let formattedRunTime = varFormatter.time(runSeconds)
            runTime.text = "Length: \(formattedRunTime)"
        } else {
            restSeconds += 1
            let formattedRestTime = varFormatter.time(restSeconds)
            restTime.text = "Rest: \(formattedRestTime)"
        }
    }
    
    
    //MARK: Table view delegates
    
    //Cell count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return piecesArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Piece \(section+1)"
    }
    //Builds Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pieceItem", for: indexPath) as! pieceTableCell
        cell.distanceLabel.text = "\(piecesArray[indexPath.section].distance)m"
        let formattedRunTime = varFormatter.time(Int(piecesArray[indexPath.section].lengthTime))
        let formattedRestTime = varFormatter.time(Int(piecesArray[indexPath.section].restTime))
        cell.runTime.text = "Time: \(formattedRunTime)"
        cell.restTime.text = "Rest: \(formattedRestTime)"
        let formattedPace = varFormatter.pace(distance: Measurement(value: Double(piecesArray[indexPath.section].distance), unit: UnitLength.meters), seconds: Int(piecesArray[indexPath.section].lengthTime), outputUnit: UnitSpeed.secondsPerFiveHundredMeter)
        
        cell.aveSplit.text = "\(formattedPace)"
        return cell
    }
    
}
