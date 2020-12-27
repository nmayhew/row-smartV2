//
//  RateMonitorCollectionViewCell.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 29/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit

//Rate Monitor Cell. Allows coach to check SPM of current crews 
class RateMonitorCollectionViewCell: UICollectionViewCell {
    
    private var spmPresses: [TimeInterval] = []
    private var colorTimer = Timer()
    
    @IBOutlet weak var rateMonitor: UILabel!
    @IBOutlet weak var rateButton: UIButton!
    
    
    @IBAction func rateButtonPressed(_ sender: Any) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        let currentTime = Date().timeIntervalSince1970
        let currColor = self.backgroundColor
        self.backgroundColor = currColor?.withAlphaComponent(0.8)
        colorTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.restoreColor), userInfo: nil, repeats: false)
        if (spmPresses.count > 1) {
            let twoDiff = currentTime - spmPresses[spmPresses.count-1] + spmPresses[spmPresses.count-1] - spmPresses[spmPresses.count-2]
            let splitRe = twoDiff / 120
            let split = 1.0 / splitRe
            let rounded = round(split*10.0)/10.0
            if (rounded > 60 || rounded < 5) {
                rateMonitor.text = "Only press \n at catch"
            } else {
                rateMonitor.text = "\(rounded) SPM"
            }
        } else {
            rateMonitor.text = "More strokes"
        }
        spmPresses.append(currentTime)
    }
    
    @objc func restoreColor() {
        let currColor = self.backgroundColor
        self.backgroundColor = currColor?.withAlphaComponent(1)
    }
}
