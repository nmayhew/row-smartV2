//
//  PopUpViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 21/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit

//Delegate example to pass information
protocol popUpDelegate {
    func boatCreated(boatName: String, lane:Int, boatType: String)
}

class PopUpViewController: popUPViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var createBoatLabel: UILabel!
    @IBOutlet weak var boatNameField: UITextField!
    @IBOutlet weak var laneBoatTypePicker: UIPickerView!
    @IBOutlet weak var addBoatButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    var delegate: popUpDelegate?
    
    //MARK: Data for pickers
    private var lanes = [1,2,3,4,5,6,7,8]
    var boatTypes = ["M8+", "W8+", "M4x", "W4x", "M4-","W4-", "M4+","W4+", "M2x", "W2x", "M2-", "W2-", "M1x","W1x", "LM8+","LW8+", "LM4x","LW4x", "LW4-", "LM4-", "LM4+","LW4+", "LM2x","LW2x", "LM2-","LW2-", "LM1x","LW1x"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showAnimate()
        
        popUpView.layer.cornerRadius = 5.0
        popUpView.layer.masksToBounds = false
        
        createPicker()
        
        boatNameField.delegate = self
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        popUpView.addGradientBackground(firstColor: UIColor.init(rgb: 0x1B2BD6), secondColor: UIColor.init(rgb: 0x1b5ad6))
        
        super.viewDidAppear(animated)
        
    }
    
    
    //Resigns keyboard when return is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        boatNameField.resignFirstResponder()
        return true
    }
    
    //Creates scroller view
    func createPicker() {
        laneBoatTypePicker.delegate = self
        laneBoatTypePicker.delegate?.pickerView?(laneBoatTypePicker, didSelectRow: 0, inComponent: 0)
    }
    
    @IBAction func addBoatButtonPressed(_ sender: Any) {
        //Pass information and do validation checks
        var boatName = boatNameField.text!
        let currLane = lanes[ laneBoatTypePicker.selectedRow(inComponent: 0)]
        
        let currboatType = boatTypes[laneBoatTypePicker.selectedRow(inComponent: 1)]
        if (boatName == "") {
            //Create Name
            boatName = "\(currboatType) in Lane \(currLane)"
        }
        
        self.delegate?.boatCreated(boatName: boatName, lane: currLane, boatType: currboatType)
        removeAnimate()
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        removeAnimate()
    }
    
    
    
    //MARK: Picker View Delegates
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if (component == 1) {
            let titleData = boatTypes[row]
            let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            
            return myTitle
        } else {
            let titleData = "\(lanes[row])"
            let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            
            return myTitle
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 0) {
            return lanes.count
        } else {
            return boatTypes.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (component == 0) {
            return "\(lanes[row])"
        } else {
            return boatTypes[row]
        }
    }
    
}
