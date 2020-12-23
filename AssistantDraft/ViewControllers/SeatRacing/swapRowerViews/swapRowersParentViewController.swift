//
//  swapRowersParentViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 13/08/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit

protocol sendSwap {
    func sendSwap(rower: Rower, boat: SeatRaceBoat)
}

//Parent class for swap rowers sub view controllers.
//Never intiated but functions are used a lot in children, see rest of classes in folder 
class swapRowersParentViewController: UIViewController, UIGestureRecognizerDelegate {
    var boat: SeatRaceBoat?
    var rowersInBoat: [Rower_Seat] = []
    var delegate: sendSwap?
    var buttons: [UIButton] = [] //Ordered bow to stroke plus cox
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rowersInBoat = getRowers(boat: boat!)
        NotificationCenter.default.addObserver(self, selector: Selector(("cancelSwaps")), name: NSNotification.Name(rawValue: "cancelSwaps"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AnotherSwap), name: NSNotification.Name(rawValue: "AnotherSwap"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    @objc func AnotherSwap(notification: NSNotification) {
        if let swapsXforY = notification.userInfo?["swapsData"] as? [Rower:Rower] {
            for rower_Seat in rowersInBoat {
                if (swapsXforY[rower_Seat.rower!] != nil) {
                    let seat = rower_Seat.seat
                    var count = 1
                    for button in buttons {
                        if (seat == count) {
                            button.isEnabled = false
                            button.setTitle("\(rower_Seat.rower!.name!) --> \(swapsXforY[rower_Seat.rower!]!.name!)", for: .disabled)
                            buttons.remove(at: buttons.firstIndex(of: button)!)
                            
                        }
                        count = count + 1
                    }
                }
            }
        }
    }
    
    @objc func cancelSwaps() {
        for button in buttons {
            button.backgroundColor = UIColor.clear
        }
    }
    
    func getRowers(boat: SeatRaceBoat) -> [Rower_Seat] {
        let sortDescriptorSeatBoatTimes = NSSortDescriptor(key: #keyPath(SeatRaceTime.raceNo), ascending: false)
        let sortDescriptorRowersSeat = NSSortDescriptor(key: #keyPath(Rower_Seat.seat), ascending: true)
        
        let timesArray = boat.times?.sortedArray(using: [sortDescriptorSeatBoatTimes]) as! [SeatRaceTime]
        return timesArray.first?.lineUp?.sortedArray(using: [sortDescriptorRowersSeat]) as! [Rower_Seat]
    }
    
    func setUpButtons(buttons: [UIButton]) {
        for button in buttons {
            button.layer.borderColor = UIColor.lightGray.cgColor;
            button.layer.borderWidth = 2.0;
            button.layer.cornerRadius = 5.0
            let colour = UIColor.white
            button.setTitleColor(colour.withAlphaComponent(0.5), for: .disabled)
        }
    }
    
    func tapped(sender: UIButton, rower: Rower, boat: SeatRaceBoat) {
        sender.backgroundColor = UIColor.lightGray
        self.delegate?.sendSwap(rower: rower, boat: boat)
    }
    
}
