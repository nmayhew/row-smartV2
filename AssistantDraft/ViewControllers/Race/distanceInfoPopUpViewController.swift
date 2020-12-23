//
//  distanceInfoViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 08/08/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit

//Mini pop up that just gives info on what distance does.
//Text is set in storyboard
class distanceInfoViewController: popUPViewController {
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var distanceExplanation: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimate()
        popUpView.layer.masksToBounds = false
        popUpView.layer.cornerRadius = 5.0
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        popUpView.addGradientBackground(firstColor: UIColor.init(rgb: 0x1B2BD6), secondColor: UIColor.init(rgb: 0x1b5ad6))
    }
    
    @IBAction func close(_ sender: Any) {
        removeAnimate()
    }
}
