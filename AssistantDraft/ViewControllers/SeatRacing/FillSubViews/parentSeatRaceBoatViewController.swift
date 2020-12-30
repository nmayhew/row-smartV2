//
//  parentSeatRaceBoatViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 11/08/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit


//Parent class for fill rowers sub view controllers.
//Never intiated but functions are used a lot in children, see rest of classes in folder
class parentBoat: UIViewController, UITextFieldDelegate {
    
    var boat: SeatRaceBoat?
    var delegate: sendRowers?
    var delegateShouldSend: ReadyToSend?
    var full = false
    var activeField: UITextField?
    var sent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: Selector(("confirmRowers")), name: NSNotification.Name(rawValue: "confirmRowers"), object: nil)
        NotificationCenter.default.addObserver(self, selector: Selector(("sendRowers")), name: NSNotification.Name(rawValue: "sendRowers"), object: nil)
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    func setDelegates(textFields: [UITextField], boatLabel: UILabel) {
        for textField in textFields {
            textField.delegate = self           
        }
    }
    
    //Resigns keyboard when return is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func viewWillDisappear(_ animated: Bool) {
        if (activeField != nil) {
            activeField?.resignFirstResponder()
            activeField = nil
        }
        super.viewWillDisappear(animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
}
