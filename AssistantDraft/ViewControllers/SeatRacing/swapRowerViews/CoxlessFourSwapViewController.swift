//
//  CoxlessFourSwapViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 13/08/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit

class CoxlessFourSwapViewController: swapRowersParentViewController {
    
    @IBOutlet weak var boatName: UILabel!
    
    
    @IBOutlet weak var stroke: UIButton!
    @IBOutlet weak var three: UIButton!
    @IBOutlet weak var two: UIButton!
    @IBOutlet weak var bow: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        boatName.text = boat?.boatName
        loadRowers()
        buttons = [bow,two,three,stroke]
        setUpButtons(buttons: buttons)
    }
    
    func loadRowers() {
        bow.setTitle(rowersInBoat[0].rower!.name, for: .normal)
        two.setTitle(rowersInBoat[1].rower!.name, for: .normal)
        three.setTitle(rowersInBoat[2].rower!.name, for: .normal)
        stroke.setTitle(rowersInBoat[3].rower!.name, for: .normal)
    }
    
    @IBAction func strokePressed(_ sender: Any) {
        tapped(sender: stroke, rower: rowersInBoat[3].rower!, boat: boat!)
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
