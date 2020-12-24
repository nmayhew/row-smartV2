//
//  allBoatInfo.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 29/08/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import Foundation
import UIKit

//Class used to store all information needed for one cell when running in timing screens in race and seat racing
class BoatInfo {
    
    var laneString = ""
    var boatNameString = ""
    var timeString = ""
    
    var delegate: startDelegate?
    var finishDelegate: finishDelegate?
    var started = false
    var finished = false
    var startTime: Date?
    var deciSeconds: Int = 0
    var timer: Timer?
    var backgroundColour: UIColor?
    var backgroundDate: Date?
    
    func cellPressed () {
        if (started == false) {
            started = true
            self.delegate?.startPressed()
            deciSeconds = 0
            backgroundColour = .green
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                self.eachDeciSecond()
            }
            startTime = Date()
        } else if (started == true && finished == false) {
            finished = true
            self.finishDelegate?.finishPressed()
            timer?.invalidate()
            backgroundColour = .red
        }
    }
    
    func eachDeciSecond() {
        deciSeconds += 1
        let formattedTime = varFormatter.detailTime(deciSeconds)
        timeString = formattedTime
    }
    
}
