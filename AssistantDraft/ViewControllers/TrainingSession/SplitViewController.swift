//
//  SplitViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 09/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit

class SplitViewController: UIViewController {
    //MARK: Labels
    @IBOutlet weak var last5: UILabel!
    @IBOutlet weak var last10: UILabel!
    @IBOutlet weak var last25: UILabel!
    @IBOutlet weak var aveRate: UILabel!
    
    //Stores locally all times of SPMTimes
    var SPMTimes: [TimeInterval] = []
    
    //Sets up observer to receive new SPM times
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(updateAll), name: NSNotification.Name(rawValue: "spmSent"), object: nil)
    }
    
    //Updating labels for details of SPM called by observer
    @objc func updateAll(notification: NSNotification) {
        if let SPMTimes = notification.userInfo?["spmTimes"] as? [TimeInterval] {
            //Check enough
            if (SPMTimes.count < 3) {
                return
            }
            var count = 0.0
            var recent5 = 0.0
            var recent10 = 0.0
            var recent25 = 0.0
            var all = 0.0
            for index in stride(from: SPMTimes.count-1, to: 1, by: -1) {
                let diff = validateGap(recentTime: SPMTimes[index], previousTime: SPMTimes[index-1])
                if (diff == 999) {
                    //Difference is too large //User has just starting redoing SPMtimes
                    workoutAverage(count: count, recent5: recent5, recent10: recent10, recent25: recent25, all: all)
                    return
                }
                if(count < 5){
                    recent5 += diff
                    recent10 += diff
                    recent25 += diff
                } else if (count < 10) {
                    recent10 += diff
                    recent25 += diff
                } else if (count < 25) {
                    recent25 += diff
                }
                all += diff
                count += 1
            }
             workoutAverage(count: count, recent5: recent5, recent10: recent10, recent25: recent25, all: all)
        }
    }
    
    
    func workoutAverage(count: Double, recent5: Double, recent10: Double, recent25: Double, all: Double) {
        //Get ave ensuring enough strokes
        var div5 = 5.0 * 60.0
        var div10 = 10.0 * 60.0
        var div25 = 25.0 * 60.0
        if (count < 5) {
            div5 = count * 60
            div10 = count * 60
            div25 = count * 60
        } else if (count < 10) {
            div10 = count * 60
            div25 = count * 60
        } else {
            div25 = count * 60
        }
        var aveRec5 = recent5 / div5
        var aveRec10 = recent10 / div10
        var aveRec25 = recent25 / div25
        var aveAll = all / (count * 60)
        //reciprocal
        aveRec5 = 1.0 / aveRec5
        aveRec10 = 1.0 / aveRec10
        aveRec25 = 1.0 / aveRec25
        aveAll = 1.0 / aveAll
        //Round
        aveRec5 = round(aveRec5*10)/10
        aveRec10 = round(aveRec10*10)/10
        aveRec25 = round(aveRec25*10)/10
        aveAll = round(aveAll*10)/10
        //Update labels
        last5.text = "Last 5 Strokes: \(aveRec5) SPM"
        last10.text = "Last 10 Strokes: \(aveRec10) SPM"
        last25.text = "Last 25 Strokes: \(aveRec25) SPM"
        aveRate.text = "Average: \(aveAll) SPM"
    }
    
    //To be used to see if gap is too large
    func validateGap(recentTime: TimeInterval, previousTime: TimeInterval) -> TimeInterval {
        //Validate gap return error if big gap between numbers
        let diff = recentTime - previousTime
        if (diff > 10) {
            return 999
        }
        return diff
    }
    
}
