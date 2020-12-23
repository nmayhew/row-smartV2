//
//  unitCalculations.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 04/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import Foundation

//Unit calculations
class UnitConverterPace: UnitConverter {
    private let coefficient: Double
    
    init(coefficient: Double) {
        self.coefficient = coefficient
    }
    
    override func baseUnitValue(fromValue value: Double) -> Double {
        return reciprocal(value * coefficient)
    }
    
    override func value(fromBaseUnitValue baseUnitValue: Double) -> Double {
        return reciprocal(baseUnitValue * coefficient)
    }
    
    private func reciprocal(_ value: Double) -> Double {
        guard value != 0 else { return 0 }
        return 1.0 / value
    }
}
//Extension of unit speed for my program
extension UnitSpeed {
    class var secondsPerMeter: UnitSpeed {// For Testing
        return UnitSpeed(symbol: "sec/m", converter: UnitConverterPace(coefficient: 1))
    }
    class var secondsPerFiveHundredMeter: UnitSpeed {
        return UnitSpeed(symbol: "sec/500", converter: UnitConverterPace(coefficient: 1 / 500.0 ))
    }
    class var minutesPerKilometer: UnitSpeed {
        return UnitSpeed(symbol: "min/km", converter: UnitConverterPace(coefficient: 60.0 / 1000.0))
    }
    
}
