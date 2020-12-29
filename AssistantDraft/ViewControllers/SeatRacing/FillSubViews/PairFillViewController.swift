//
//  PairFillViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 31/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit

class PairFillViewController: parentBoat {
    
    @IBOutlet weak var boatName: UILabel!
    @IBOutlet weak var stroke: UITextField!
    @IBOutlet weak var bow: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        boatName.text = boat?.boatName
        setDelegates(textFields: [bow,stroke], boatLabel: boatName)
    }
    
    @objc func sendRowers() {
        if(!sent) {
            let rowers = [bow.text!, stroke.text!]
            self.delegate?.sendRowers(rowersInOrder: rowers, boat: boat!)
            sent = true
        }
        
    }
    
    @objc func confirmRowers() {
        let textViewsArray: [UITextField] = [stroke, bow]
        let failedTextViews = validationFun.validate(textViewsArray)
        for textView in failedTextViews {
            textView.layer.borderColor = UIColor.red.cgColor
            textView.layer.cornerRadius = Constants.CORNERRAD
            textView.layer.borderWidth = 1.0
        }
        if (failedTextViews.isEmpty) {
            full = true
        }
        self.delegateShouldSend?.ready(ready: full, boat: boat!)
    }
}
