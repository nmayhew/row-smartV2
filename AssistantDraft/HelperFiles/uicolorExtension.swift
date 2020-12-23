//
//  uicolorExtension.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 07/08/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    //Create colour use r ,g ,b values
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    //Create colour using rgb values
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension UITableView {
    //Uniform round corners on table
    func roundCorners() {
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
    }
}

extension TimeInterval{
    
    //Create readable time string from Time Interval
    func stringFromTimeInterval() -> String {
        
        let time = NSInteger(self)
        let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 10)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        return String(format: "%0.2d:%0.2d.%0.1d",minutes,seconds,ms)
    }
}
