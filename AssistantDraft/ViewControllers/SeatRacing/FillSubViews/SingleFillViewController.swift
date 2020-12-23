//
//  SingleFillViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 31/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit

class SingleFillViewController: parentBoat {    
    
    @IBOutlet weak var boatName: UILabel!
    @IBOutlet weak var bow: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        boatName.text = boat?.boatName
        setDelegates(textFields: [bow], boatLabel: boatName)
    }
    
    @objc func sendRowers() {
        if(!sent) {
            let rowers = [bow.text!]
            self.delegate?.sendRowers(rowersInOrder: rowers, boat: boat!)
            sent = true
        }
        
    }
    
    @objc func confirmRowers() {
        let textViewsArray: [UITextField] = [bow]
        let failedTextViews = validationFun.validate(textViewsArray)
        for textView in failedTextViews {
            textView.layer.borderColor = UIColor.red.cgColor
            textView.layer.cornerRadius = 4.0
            textView.layer.borderWidth = 1.0
        }
        if (failedTextViews.isEmpty) {
            full = true
        }
        self.delegateShouldSend?.ready(ready: full, boat: boat!)
    }
    
}
