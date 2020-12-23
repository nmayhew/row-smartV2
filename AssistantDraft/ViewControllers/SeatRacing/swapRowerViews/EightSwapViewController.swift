//
//  EightSwapViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 13/08/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit

class EightSwapViewController: swapRowersParentViewController {
    
    
    @IBOutlet weak var boatName: UILabel!
    
    @IBOutlet weak var seven: UIButton!
    @IBOutlet weak var cox: UIButton!
    @IBOutlet weak var stroke: UIButton!
    @IBOutlet weak var six: UIButton!
    @IBOutlet weak var five: UIButton!
    @IBOutlet weak var four: UIButton!
    @IBOutlet weak var three: UIButton!
    @IBOutlet weak var two: UIButton!
    @IBOutlet weak var bow: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        boatName.text = boat?.boatName
        buttons = [bow,two, three,four,five,six,seven,stroke,cox]
        loadRowers()
        setUpButtons(buttons: buttons)
    }
    
    func loadRowers() {
        bow.setTitle(rowersInBoat[0].rower!.name, for: .normal)
        two.setTitle(rowersInBoat[1].rower!.name, for: .normal)
        three.setTitle(rowersInBoat[2].rower!.name, for: .normal)
        four.setTitle(rowersInBoat[3].rower!.name, for: .normal)
        five.setTitle(rowersInBoat[4].rower!.name, for: .normal)
        six.setTitle(rowersInBoat[5].rower!.name, for: .normal)
        seven.setTitle(rowersInBoat[6].rower!.name, for: .normal)
        stroke.setTitle(rowersInBoat[7].rower!.name, for: .normal)
        cox.setTitle(rowersInBoat[8].rower!.name, for: .normal)
    }
    @IBAction func coxPressed(_ sender: Any) {
        tapped(sender: cox, rower: rowersInBoat[8].rower!, boat: boat!)
    }
    @IBAction func strokePressed(_ sender: Any) {
        tapped(sender: stroke, rower: rowersInBoat[7].rower!, boat: boat!)
    }
    @IBAction func sevenPressed(_ sender: Any) {
        tapped(sender: seven, rower: rowersInBoat[6].rower!, boat: boat!)
    }
    @IBAction func sixPressed(_ sender: Any) {
        tapped(sender: six, rower: rowersInBoat[5].rower!, boat: boat!)
    }
    @IBAction func fivePressed(_ sender: Any) {
        tapped(sender: five, rower: rowersInBoat[4].rower!, boat: boat!)
    }
    @IBAction func fourPressed(_ sender: Any) {
        tapped(sender: four, rower: rowersInBoat[3].rower!, boat: boat!)
    }
    @IBAction func threePressed(_ sender: Any) {
        tapped(sender: three, rower: rowersInBoat[2].rower!, boat: boat!)
    }
    @IBAction func twoPressed(_ sender: Any) {
        tapped(sender: two, rower: rowersInBoat[1].rower!, boat: boat!)
    }
    
    @IBAction func bowPressed(_ sender: Any) {
        tapped(sender: bow, rower: rowersInBoat[0].rower!, boat: boat!)
    }
    
    
}
