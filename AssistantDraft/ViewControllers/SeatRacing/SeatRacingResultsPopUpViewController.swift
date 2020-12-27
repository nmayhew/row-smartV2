//
//  SeatRacingPopUpViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 17/08/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit

//Cell declaration
class swapsResults: UITableViewCell {
    
    @IBOutlet weak var swaps: UILabel!
    @IBOutlet weak var margin: UILabel!
}


//Cell declaration
class SeatRacingResults: UITableViewCell {
    @IBOutlet weak var GMT: UILabel!
    @IBOutlet weak var aveSplit: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var lane: UILabel!
    @IBOutlet weak var boatName: UILabel!
}

//Contains the seat racing results which is used  to create cells above
class swapsResultsInfo {
    var afterRace: Int?
    var swaps: String?
    var margin: String?
}

//All changes in crew, two created for each swap
class aSwapUnmatched {
    var rowerOut: Rower?
    var rowerReplacement: Rower?
    var boatLeave: SeatRaceBoat?
    var afterRace: Int?
}

//Class info for a swap where rower replacement beat rower leaving crew
class aSwapMatched: aSwapUnmatched {
    var boatInto: SeatRaceBoat?
    var marginDeciSeconds: Int? //Positive indicates win
    init(unmatched: aSwapUnmatched, boatIntoTemp: SeatRaceBoat) {
        super.init()
        self.rowerOut = unmatched.rowerOut
        self.rowerReplacement = unmatched.rowerReplacement
        self.boatLeave = unmatched.boatLeave
        self.afterRace = unmatched.afterRace
        self.boatInto = boatIntoTemp
    }
}

class SeatRacingPopUpViewController: popUPViewController ,UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var closebutton: UIButton!
    @IBOutlet weak var swapsResultsTableView: UITableView!
    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var exportButton: UIButton!
    
    var seatRaceInfo: SeatRace?
    var seatRaceBoats: [SeatRaceBoat] = []
    var delegate: resultsPopUpDelegate?
    var lastView = false
    var savedView = false
    var preSwaps = false
    var exportAllowed = false
    
    private let sortDescriptorSeatBoatTimes = NSSortDescriptor(key: #keyPath(SeatRaceTime.raceNo), ascending: true)
    private let sortDescriptorRower_Seat = NSSortDescriptor(key: #keyPath(Rower_Seat.seat), ascending: true)
    private var swapResultsInfo: [swapsResultsInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimate()
        
        swapsResultsTableView.delegate = self
        swapsResultsTableView.dataSource = self
        swapsResultsTableView.roundCorners()
        
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.roundCorners()
        
        popUpView.layer.cornerRadius = 5.0
        createResults()
        if (preSwaps) {
            swapsResultsTableView.isHidden = true
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        
        if (!lastView && !exportAllowed) {
            exportButton.isHidden = true
        }
        super.viewDidAppear(animated)
        
        popUpView.addGradientBackground(firstColor: UIColor.init(rgb: 0x1B2BD6), secondColor: UIColor.init(rgb: 0x1b5ad6))
    }
    //Creates results and places all results in swapResults Info
    func createResults(){
        if (preSwaps) {
           
            return //TODO
        }
        let unMatchedSwaps = getUnMatchedSwaps()
        let matchedSwaps = getMatchedSwaps(unmatcheds: unMatchedSwaps)
        
        //For each swap
        for swap in matchedSwaps {
            let newSwapResults = swapsResultsInfo()
            let marginDecisecon = Double(swap.marginDeciSeconds!)
            let marginSecon = marginDecisecon/10.0
            newSwapResults.afterRace = swap.afterRace
            newSwapResults.margin = "by \(marginSecon) seconds"
            if (marginDecisecon == 0) {
                newSwapResults.swaps = "\(swap.rowerReplacement!.name!) drew with \(swap.rowerOut!.name!)"
            } else {
                newSwapResults.swaps = "\(swap.rowerReplacement!.name!) beat \(swap.rowerOut!.name!)"
            }
            
            swapResultsInfo.append(newSwapResults)
        }
    }
    
    //This goes through the unmatched swaps and matches them.
    //Each match will have an opposite as only swapping rowers between boats
    func getMatchedSwaps(unmatcheds: [aSwapUnmatched]) -> [aSwapMatched] {
        var matchedSwaps: [aSwapMatched] = []
        for swapX in unmatcheds {
            //Find its opposites
            
            for swapY in unmatcheds {
                if(swapX.afterRace == swapY.afterRace && swapX.rowerOut == swapY.rowerReplacement) {
                    //Matched swaps creat two matched swaps as unsure which is winner yet
                    let matchedSwapX = aSwapMatched(unmatched: swapX, boatIntoTemp: swapY.boatLeave!)
                    
                    //Don't create matchedSwapY as will be creat in different loop, if creat now it will double create
                    
                    //Get time
                    matchedSwapX.marginDeciSeconds = getMargin(matched: matchedSwapX)
                    if (matchedSwapX.marginDeciSeconds! >= 0) {
                        //Only appends positive (winners)
                        matchedSwaps.append(matchedSwapX)
                    }
                    
                    
                }
            }
        }
        return matchedSwaps
    }
    
    func getMargin(matched: aSwapMatched) -> Int{
        //Get times of boatLeave and boatInto before and after, see change then subtract the two
        let boatIntoTimes = matched.boatInto?.times?.sortedArray(using: [sortDescriptorSeatBoatTimes]) as! [SeatRaceTime]
        let boatLeaveTimes = matched.boatLeave?.times?.sortedArray(using: [sortDescriptorSeatBoatTimes]) as! [SeatRaceTime]
        let boatIntoBefore = boatIntoTimes[matched.afterRace!].deciSeconds
        let boatIntoAfter = boatIntoTimes[matched.afterRace! + 1].deciSeconds
        let boatLeaveBefore = boatLeaveTimes[matched.afterRace!].deciSeconds
        let boatLeaveAfter = boatLeaveTimes[matched.afterRace! + 1].deciSeconds
        
        let boatIntoChange = boatIntoAfter - boatIntoBefore
        let boatLeaveChange = boatLeaveAfter - boatLeaveBefore
        let marginDeciseconds = boatIntoChange - boatLeaveChange
        
        return Int(marginDeciseconds)
    }
    
    //For number of cells created 
    func lowestRaceCountFunc() -> Int {
        var lowestRaceCount = 9999
        for boat in seatRaceBoats {
            let listOfBoatTimes = boat.times?.sortedArray(using: [sortDescriptorSeatBoatTimes]) as! [SeatRaceTime]
            if (listOfBoatTimes.count < lowestRaceCount) {
                lowestRaceCount = listOfBoatTimes.count
            }
            
        }
        if (lastView == false) {
            lowestRaceCount = lowestRaceCount - 1
            //So if pop up through current results press it doesn't show ongoing race
        }
        
        return lowestRaceCount
    }
    
    //Gets every change of person between races, so for each swap you get two unmatched swap as two people move out and two people move in
    func getUnMatchedSwaps() -> [aSwapUnmatched] {
        var unmatchedSwaps: [aSwapUnmatched] = []
        let lowestRaceCount = lowestRaceCountFunc()
        for swapNumber in 0...lowestRaceCount-2 {//Maybe -1
            //1 Find out which rowers swapped
            for boat in seatRaceBoats {
                let listOfBoatTimes = boat.times?.sortedArray(using: [sortDescriptorSeatBoatTimes]) as! [SeatRaceTime]
                let xLineUp = listOfBoatTimes[swapNumber].lineUp?.sortedArray(using: [sortDescriptorRower_Seat]) as! [Rower_Seat]
                let xPlusOneLineUp = listOfBoatTimes[swapNumber+1].lineUp?.sortedArray(using: [sortDescriptorRower_Seat]) as! [Rower_Seat]
                for count in 0...xLineUp.count - 1 {
                    if (xLineUp[count].rower != xPlusOneLineUp[count].rower) {
                        //swap has happened
                        let newSwap = aSwapUnmatched()
                        newSwap.rowerOut = xLineUp[count].rower
                        newSwap.rowerReplacement = xPlusOneLineUp[count].rower
                        newSwap.boatLeave = boat
                        newSwap.afterRace = swapNumber
                        unmatchedSwaps.append(newSwap)
                    }
                }
            }
        }
        
        return unmatchedSwaps
    }
    
    
    @IBAction func closePressed(_ sender: Any) {
        self.delegate?.finished(lastView: lastView)
        removeAnimate()
    }
    
    //MARK: TableView delegates
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (tableView == swapsResultsTableView) {
            return "Swaps between race \(section+1) and \(section+2)"
        } else {
            //Must be results
            return "Race Number: \(section+1)"
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        let lowestRaceCount = lowestRaceCountFunc()
        if (tableView == swapsResultsTableView) {
            return lowestRaceCount-1
            
        } else {
            //Must be results
            return lowestRaceCount
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == swapsResultsTableView) {
            //Number of swaps in each inbetween race
            var count = 0
            for swapCell in swapResultsInfo {
                if(swapCell.afterRace == section) {
                    count = count + 1
                }
            }
            return count
        } else {
            //Must be results
            return seatRaceBoats.count
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == swapsResultsTableView) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "swapsResultsCell", for: indexPath) as! swapsResults
            var count = 0
            for swapInfo in swapResultsInfo {
                if (indexPath.section == swapInfo.afterRace) {
                    if (indexPath.row == count) {
                        cell.swaps.text = swapInfo.swaps
                        cell.margin.text = swapInfo.margin
                    }
                    count = count + 1
                }
            }
            return cell
        } else {
            //Must be results
            let cell = tableView.dequeueReusableCell(withIdentifier: "SeatRaceResultsCell", for: indexPath) as! SeatRacingResults
            let raceNo = indexPath.section
           let listOfTimes = seatRaceBoats[indexPath.row].times?.sortedArray(using: [sortDescriptorSeatBoatTimes]) as! [SeatRaceTime]
            cell.boatName.text = "\(seatRaceBoats[indexPath.row].boatName!)"
            cell.lane.text = "Lane: \(seatRaceBoats[indexPath.row].lane)"
            let formattedTime = varFormatter.detailTime(Int(listOfTimes[raceNo].deciSeconds))
            cell.time.text = "Time: \(formattedTime)"
            cell.GMT.text = "Gold %: \(varFormatter.calculateGMT(distance: Int(seatRaceInfo!.distance), type: seatRaceBoats[indexPath.row].type!, time: Double(listOfTimes[raceNo].deciSeconds)/10.0))"
            cell.aveSplit.text = varFormatter.paceDetail(distance: Measurement(value: Double(seatRaceInfo!.distance), unit: UnitLength.meters), seconds: (Double(listOfTimes[raceNo].deciSeconds)/10.0), outputUnit: UnitSpeed.secondsPerFiveHundredMeter)
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == resultsTableView) {
            let raceNo = indexPath.section
            let listOfTimes = seatRaceBoats[indexPath.row].times?.sortedArray(using: [sortDescriptorSeatBoatTimes]) as! [SeatRaceTime]
            
            let rowers = listOfTimes[raceNo].lineUp?.sortedArray(using: [sortDescriptorRower_Seat]) as! [Rower_Seat]
            let rowerNo = rowers.count
            var rowerLineup = ""
            switch rowerNo {
            case 1: rowerLineup = "Bow: \(rowers[0].rower!.name!)"
            case 2: rowerLineup = "Stroke: \(rowers[1].rower!.name!)\nBow: \(rowers[0].rower!.name!)"
            case 4: rowerLineup = "Stroke: \(rowers[3].rower!.name!)\nThree: \(rowers[2].rower!.name!)\nTwo: \(rowers[1].rower!.name!)\nBow: \(rowers[0].rower!.name!)"
            case 5:rowerLineup = "Cox: \(rowers[4].rower!.name!)\nStroke: \(rowers[3].rower!.name!)\nThree: \(rowers[2].rower!.name!)\nTwo: \(rowers[1].rower!.name!)\nBow: \(rowers[0].rower!.name!)"
            case 9:rowerLineup = "Cox: \(rowers[8].rower!.name!)\nStroke: \(rowers[7].rower!.name!)\nSeven: \(rowers[6].rower!.name!)\nSix: \(rowers[5].rower!.name!)\nFive: \(rowers[4].rower!.name!)\nFour: \(rowers[3].rower!.name!)\nThree: \(rowers[2].rower!.name!)\nTwo: \(rowers[1].rower!.name!)\nBow: \(rowers[0].rower!.name!)"
            default: break
            }
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "crewListInfo") as! CrewListViewController
            self.addChild(popOverVC)
            popOverVC.rowersLineup = rowerLineup
            if (savedView) {
                popOverVC.view.frame = self.view.frame
                popOverVC.view.center = self.popUpView.center
            } else {
                popOverVC.view.frame = self.view.frame
            }
            
            self.view.addSubview(popOverVC.view)
            popOverVC.didMove(toParent: self)
        }
    }
    
    //MARK: Export
    
    @IBAction func exportPressed(_ sender: Any) {
        let df = DateFormatter()
        df.dateFormat = "dd MMM yyyy hh:mm"
        let fileDate = df.string(from: seatRaceInfo!.date!)
        
        let fileName = "Seat Race: \(fileDate).csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        let date = DateFormatter()
        date.dateFormat = "dd MMM yyyy"
        let raceDate = date.string(from: seatRaceInfo!.date!)
        
        let time = DateFormatter()
        time.dateFormat = "hh:mm"
        let raceTime = time.string(from: seatRaceInfo!.date!)
        var csvText = "Seat Race,Date,Time\n,\(raceDate),\(raceTime)\n\n"
        
        csvText.append(seatRaceResults())
        
        let spaceBetween = "\n"
        csvText.append(spaceBetween)
        csvText.append(swapResults())
        
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
    
    func swapResults() -> String {
        var csvText = "Seat Race Results:\n"
      
        for swapInfo in swapResultsInfo {
            var swapDetail = "\(swapInfo.swaps!) \(swapInfo.margin!)\n"
            csvText.append(swapDetail)
        }
        
        return csvText
    }
    
    func seatRaceResults() -> String {
        var csvText = ""
        for raceIndex in 1...lowestRaceCountFunc() {
            let csvSeatRaceHeadline = "Race \(raceIndex):,Lineup:, Time:, Average Split:, % Gold Medal Time:\n"
            csvText.append(csvSeatRaceHeadline)
            for boat in seatRaceBoats {
                //Race Results
                let listOfTimes = boat.times?.sortedArray(using: [sortDescriptorSeatBoatTimes]) as! [SeatRaceTime]
                let boatNameTypeLane = "\(boat.boatName!) (\(boat.type!)) -- Lane \(boat.lane)"
                
                let formattedTime = varFormatter.detailTime(Int(listOfTimes[raceIndex-1].deciSeconds))
                let AveSplit = varFormatter.paceDetail(distance: Measurement(value: Double(seatRaceInfo!.distance), unit: UnitLength.meters), seconds: (Double(listOfTimes[raceIndex-1].deciSeconds)/10.0), outputUnit: UnitSpeed.secondsPerFiveHundredMeter)
                let GMT = varFormatter.calculateGMT(distance: Int(seatRaceInfo!.distance), type: boat.type!, time: Double(listOfTimes[raceIndex-1].deciSeconds)/10.0)
                
                let csvBoatDetail = "\(boatNameTypeLane),,\(formattedTime),\(AveSplit),\(GMT)\n"
                csvText.append(csvBoatDetail)
                
                //Lineup
                let rowers = listOfTimes[raceIndex-1].lineUp?.sortedArray(using: [sortDescriptorRower_Seat]) as! [Rower_Seat]
                let rowerNo = rowers.count
                var rowerLineup = ""
                switch rowerNo {
                case 1: rowerLineup = ",Bow: \(rowers[0].rower!.name!)\n\n"
                case 2: rowerLineup = ",Stroke: \(rowers[1].rower!.name!)\n,Bow: \(rowers[0].rower!.name!)\n\n"
                case 4: rowerLineup = ",Stroke: \(rowers[3].rower!.name!)\n,Three: \(rowers[2].rower!.name!)\n,Two: \(rowers[1].rower!.name!)\n,Bow: \(rowers[0].rower!.name!)\n\n"
                case 5:rowerLineup = ",Cox: \(rowers[4].rower!.name!)\n,Stroke: \(rowers[3].rower!.name!)\n,Three: \(rowers[2].rower!.name!)\n,Two: \(rowers[1].rower!.name!)\n,Bow: \(rowers[0].rower!.name!)\n\n"
                case 9:rowerLineup = ",Cox: \(rowers[8].rower!.name!)\n,Stroke: \(rowers[7].rower!.name!)\n,Seven: \(rowers[6].rower!.name!)\n,Six: \(rowers[5].rower!.name!)\n,Five: \(rowers[4].rower!.name!)\n,Four: \(rowers[3].rower!.name!)\n,Three: \(rowers[2].rower!.name!)\n,Two: \(rowers[1].rower!.name!)\n,Bow: \(rowers[0].rower!.name!)\n\n"
                default: break
                }
                csvText.append(rowerLineup)
            }
            let csvRaceFooter = "\n"
            csvText.append(csvRaceFooter)
        }
        return csvText
    }
}
