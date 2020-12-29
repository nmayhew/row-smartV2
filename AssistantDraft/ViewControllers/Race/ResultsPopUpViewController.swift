//
//  ResultsPopUpViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 26/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit

//MARK: Cell Declaration
//Delegate example to pass information
protocol resultsPopUpDelegate {
    func finished(lastView: Bool)
}
//Cell that shows race results
class results: UITableViewCell {
    
    @IBOutlet weak var aveSplit: UILabel!
    @IBOutlet weak var boatName: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var lane: UILabel!
    @IBOutlet weak var goldMedalTime: UILabel!
}

//MARK: Class Declaration
class ResultsPopUpViewController: popUPViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var thePopView: UIView!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var exportButton: UIButton!
    
    var raceInfo: Race?
    var raceBoatsInfo: [Boat] = []
    var lastView: Bool?
    var delegate: resultsPopUpDelegate?
    var exportAllowed = false
    
    private var noOfRaces: Int = 0
    private let reUseId = "resultsCell"
    private let sortDescriptorBoatTimes = NSSortDescriptor(key: #keyPath(BoatTimes.startTime), ascending: true)

    override func viewDidLoad() {
        super.viewDidLoad()
        thePopView.layer.cornerRadius = Constants.CORNERRAD

        showAnimate()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.roundCorners()
        
        
        let listOfTimes = raceBoatsInfo[0].boattimes?.sortedArray(using: [sortDescriptorBoatTimes]) as! [BoatTimes]
        noOfRaces = listOfTimes.count
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd, yyyy"
        distance.text = "\(dateFormatterPrint.string(from: raceInfo!.date!)) -- Distance: \(raceInfo!.distance)m"
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if (!lastView! && !exportAllowed) {
            exportButton.isHidden = true
        }
        thePopView.addGradientBackground(firstColor: UIColor.init(rgb: 0x1B2BD6), secondColor: UIColor.init(rgb: 0x1b5ad6))

        super.viewDidAppear(animated)
    }
    @IBAction func closePressed(_ sender: Any) {
        self.delegate?.finished(lastView: lastView!)
        removeAnimate()
    }

    //MARK: Tableview delegates
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Race Number: \(section+1)"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return noOfRaces
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return raceBoatsInfo.count
    }
    
    
    //Produces cell for a result
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reUseId, for: indexPath) as! results
        let raceNo = indexPath.section
        //Ordered in race order
        let listOfTimes = raceBoatsInfo[indexPath.row].boattimes?.sortedArray(using: [sortDescriptorBoatTimes]) as! [BoatTimes]
        cell.boatName.text = "\(raceBoatsInfo[indexPath.row].boatName!)"
        cell.lane.text = "Lane: \(raceBoatsInfo[indexPath.row].lane)"
        let formattedTime = varFormatter.detailTime(Int(listOfTimes[raceNo].timeDeciSeconds))
        cell.time.text = "Time: \(formattedTime)"
        cell.goldMedalTime.text = "Gold %: \(varFormatter.calculateGMT(distance: Int(raceInfo!.distance), type: raceBoatsInfo[indexPath.row].type!, time: Double(listOfTimes[raceNo].timeDeciSeconds)/10.0))"
        let aveSplit =  varFormatter.paceDetail(distance: Measurement(value: Double(raceInfo!.distance), unit: UnitLength.meters), seconds: (Double(listOfTimes[raceNo].timeDeciSeconds)/10.0), outputUnit: UnitSpeed.secondsPerFiveHundredMeter)
        cell.aveSplit.text = aveSplit
        
        return cell
    }
    
    //MARK: Export
    
    @IBAction func exportPressed(_ sender: Any) {
        let df = DateFormatter()
        df.dateFormat = "dd MMM yyyy hh:mm"
        let fileDate = df.string(from: raceInfo!.date!)
        
        let fileName = "Race: \(fileDate).csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
       
        let date = DateFormatter()
        date.dateFormat = "dd MMM yyyy"
        let raceDate = date.string(from: raceInfo!.date!)
        
        let time = DateFormatter()
        time.dateFormat = "hh:mm"
        let raceTime = time.string(from: raceInfo!.date!)
        var csvText = "Racing,Date,Time,Distance\n,\(raceDate),\(raceTime),\(raceInfo!.distance)m\n\n"
        
        for raceIndex in 1...noOfRaces {
            let csvRaceHeadline = "Race \(raceIndex):, Time:, Average Split:, % Gold Medal Time:\n"
            csvText.append(csvRaceHeadline)
            for boat in raceBoatsInfo {
                let listOfTimes = boat.boattimes?.sortedArray(using: [sortDescriptorBoatTimes]) as! [BoatTimes]
                let formattedTime = varFormatter.detailTime(Int(listOfTimes[raceIndex-1].timeDeciSeconds))
                let aveSplit = varFormatter.paceDetail(distance: Measurement(value: Double(raceInfo!.distance), unit: UnitLength.meters), seconds: (Double(listOfTimes[raceIndex-1].timeDeciSeconds)/10.0), outputUnit: UnitSpeed.secondsPerFiveHundredMeter)
                let GMT = varFormatter.calculateGMT(distance: Int(raceInfo!.distance), type: boat.type!, time: Double(listOfTimes[raceIndex-1].timeDeciSeconds)/10.0)
                let csvBoatDetail = "\(boat.boatName!) (\(boat.type!)) -- Lane \(boat.lane),\(formattedTime),\(aveSplit),\(GMT)\n"
                csvText.append(csvBoatDetail)
            }
            let csvRaceFooter = "\n\n"
            csvText.append(csvRaceFooter)
        }
        //Export CSV string made
        do {
            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
            
            let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
            vc.excludedActivityTypes = [
                UIActivity.ActivityType.assignToContact,
                UIActivity.ActivityType.saveToCameraRoll,
                UIActivity.ActivityType.postToFlickr,
                UIActivity.ActivityType.postToVimeo,
                UIActivity.ActivityType.postToTencentWeibo,
                UIActivity.ActivityType.postToTwitter,
                UIActivity.ActivityType.postToFacebook,
                UIActivity.ActivityType.openInIBooks
            ]
            present(vc, animated: true, completion: nil)
            
        } catch {
            
            print("Failed to create file")
            print("\(error)")
        }
    }
}
