//
//  CrewListViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 18/08/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit

//Pops up crew lineup when seat race result is pressed
class CrewListViewController: popUPViewController {
    var rowersLineup = ""
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var close: UIButton!
    @IBOutlet weak var CrewLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimate()
        CrewLabel.text = rowersLineup
        popUpView.layer.cornerRadius = Constants.CORNERRAD
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        popUpView.addGradientBackground(firstColor: UIColor.init(rgb: 0x1B2BD6), secondColor: UIColor.init(rgb: 0x1b5ad6))
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        removeAnimate()
    }
}
