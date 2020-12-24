//
//  SingleSwapViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 13/08/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit

class SingleSwapViewController: swapRowersParentViewController {
    
    @IBOutlet weak var boatName: UILabel!
    @IBOutlet weak var bow: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttons = [bow]
        boatName.text = boat?.boatName
        loadRowers()
        setUpButtons(buttons: buttons)
    }
    
    func loadRowers() {
        bow.setTitle(rowersInBoat[0].rower!.name, for: .normal)
    }
    
    @IBAction func bowPressed(_ sender: Any) {
        tapped(sender: bow, rower: rowersInBoat[0].rower!, boat: boat!)
    }
    
}
