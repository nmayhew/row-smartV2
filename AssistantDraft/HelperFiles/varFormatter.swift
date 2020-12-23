//
//  varFormatter.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 04/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import Foundation


struct varFormatter {
    
    static func distance(_ distance: Measurement<UnitLength>) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        let n = NumberFormatter()
        n.maximumFractionDigits = 0
        formatter.numberFormatter = n
        return formatter.string(from: distance)
    }
    
    static func time(_ seconds: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: TimeInterval(seconds))!
    }
    
    static func detailTime (_ deciSeconds: Int) -> String {
        //TODO: FIX THIS TIME COMING IN JUST NEEDS TO BE Fi
        let deciSecondsPrint = deciSeconds % 10
        let secondsPrint = (deciSeconds/10) % 60
        let minutesPrint = (deciSeconds/600) % 60
        return String(format:"%d:%02d.%01d", minutesPrint, secondsPrint, deciSecondsPrint)
        
    }
    
    //Changed to split used in rowing
    static func pace(distance: Measurement<UnitLength>, seconds: Int, outputUnit: UnitSpeed) -> String {
        //let formatter = MeasurementFormatter()
        //formatter.unitOptions = [.providedUnit] // 1
        let speedMagnitude = seconds != 0 ? distance.value / Double(seconds) : 0
        
        let speed = Measurement(value: speedMagnitude, unit: UnitSpeed.metersPerSecond)
        var outputSpeed = speed.converted(to: outputUnit)
        let seconds = TimeInterval(outputSpeed.value)
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [ .minute, .second ]
        formatter.zeroFormattingBehavior = [ .pad ]
        
        let formattedDuration = formatter.string(from: seconds)
        return "\(formattedDuration!) min/500m"
    }
    
    static func calculateGMT(distance: Int, type: String, time: Double) -> String {
        let timeDouble = Double(time)
        let velocity = Double(distance)/timeDouble
        let BoatTypeToSecondsBestTime = boatTypes()
        let GPTimeInSecs = BoatTypeToSecondsBestTime[type]
        let GPvelocity = 2000.0/GPTimeInSecs!
        
        var GP = velocity/GPvelocity
        GP = GP*100
        GP = (round(100*GP)/100)
        return "\(GP)%"
    }
    
    static func paceDetail(distance: Measurement<UnitLength>, seconds: Double, outputUnit: UnitSpeed) -> String {
        let speedMagnitude = seconds != 0 ? distance.value / seconds : 0
        
        let speed = Measurement(value: speedMagnitude, unit: UnitSpeed.metersPerSecond)
        var outputSpeed = speed.converted(to: outputUnit)
        let seconds = TimeInterval(outputSpeed.value)
        return "\(seconds.stringFromTimeInterval()) min/500m"        
    }
    
    static func date(_ timestamp: Date?) -> String {
        guard let timestamp = timestamp as Date? else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: timestamp)
    }
    
    static func boatTypes() -> [String: Double] {
        return ["M8+":318.68, "W8+":354.16, "M4x":332.26, "W4x":366.84, "M4-":337.86,"W4-":374.36, "M4+":358.96,"W4+":403.86, "M2x":359.72, "W2x":397.31, "M2-":368.5, "W2-":409.08, "M1x":390.74,"W1x":427.710, "LM8+":330.24,"LW8+":363.014, "LM4x":342.75,"LW4x": 375.95,"LW4-":396.4, "LM4-":343.16, "LM4+":369.0,"LW4+":418, "LM2x":365.36,"LW2x":407.69, "LM2-":382.91,"LW2-":438.32, "LM1x":401.03,"LW1x":444.46]
    }
    
}
