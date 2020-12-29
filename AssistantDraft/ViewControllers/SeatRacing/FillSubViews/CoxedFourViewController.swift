//
//  CoxedFourViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 31/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit

//Order of Rowers: Stroke through Bow then Cox if needed
protocol sendRowers {
    func sendRowers(rowersInOrder: [String], boat: SeatRaceBoat)
}

protocol ReadyToSend {
    func ready(ready: Bool, boat: SeatRaceBoat)
}

class CoxedFourViewController: parentBoat {
    
    @IBOutlet weak var boatName: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cox: UITextField!
    @IBOutlet weak var bow: UITextField!
    @IBOutlet weak var two: UITextField!
    @IBOutlet weak var three: UITextField!
    @IBOutlet weak var stroke: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        boatName.text = boat?.boatName
        setDelegates(textFields: [bow,two,three,stroke,cox], boatLabel: boatName)
        registerForKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        deregisterFromKeyboardNotifications()
    }
    
    @objc func sendRowers() {
        if(!sent) {
            let rowers = [bow.text!, two.text!, three.text!, stroke.text!, cox.text!]
            self.delegate?.sendRowers(rowersInOrder: rowers, boat: boat!)
            sent = true
        }
        
    }
    
    @objc func confirmRowers() {
        let textViewsArray: [UITextField] = [stroke, three, two, bow, cox]
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
    
    //MARK: Scroll for Keyboard
    @objc func keyboardWasShown(notification: NSNotification) {
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height, right: 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if activeField != nil
        {
            if (!aRect.contains(activeField!.frame.origin))
            {
                self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
            }
        }
        
        
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        //Once keyboard disappears, restore original positions
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -keyboardSize!.height, right: 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
        
    }
    func registerForKeyboardNotifications() {
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    func deregisterFromKeyboardNotifications() {
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
}
