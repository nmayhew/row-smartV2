//
//  PairSwapViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 13/08/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit

class PairSwapViewController: swapRowersParentViewController {
    
    @IBOutlet weak var boatName: UILabel!
    
    @IBOutlet weak var stroke: UIButton!
    @IBOutlet weak var bow: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        boatName.text = boat?.boatName
        loadRowers()
        buttons = [bow,stroke]
        setUpButtons(buttons: buttons)
    }
    
    func loadRowers() {
        bow.setTitle(rowersInBoat[0].rower!.name, for: .normal)
        stroke.setTitle(rowersInBoat[1].rower!.name, for: .normal)
    }
    @IBAction func strokePressed(_ sender: Any) {
        tapped(sender: stroke, rower: rowersInBoat[1].rower!, boat: boat!)
    }
    @IBAction func bowPressed(_ sender: Any) {
        tapped(sender: bow, rower: rowersInBoat[0].rower!, boat: boat!)
    }
}
