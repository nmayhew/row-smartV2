//
//  SeatRaceCreateViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 30/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//
//Entirely based on race viewController

import UIKit

//MARK: Cell Declaration
class boatSeatRaceTableCell: UITableViewCell {
    
    @IBOutlet weak var boatName: UILabel!
    @IBOutlet weak var laneNumber: UILabel!
    @IBOutlet weak var boatType: UILabel!
}

class addSeatRaceBoatTableCell: UITableViewCell {
    
    @IBOutlet weak var addBoat: UIButton!
    @IBAction func addBoatButton(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newBoat"), object: nil)
    }
}

class SeatRaceCreateViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, popUpDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var distanceInfoButton: UIButton!
    @IBOutlet weak var boats: UITableView!
    @IBOutlet weak var distance: UITextField!
    @IBOutlet weak var confirmBoat: UIButton!
    
    private var seatRaceDistance: Int32?
    private var seatRaceBoats: [SeatRaceBoat] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.boats.dataSource = self
        self.boats.delegate = self
        self.boats.roundCorners()
        NotificationCenter.default.addObserver(self, selector: Selector("newSeatRaceBoat"), name: NSNotification.Name(rawValue: "newBoat"), object: nil)
        self.distance.delegate = self
        self.distance.keyboardType = .numberPad
        
        setUpTextFields()
        confirmBoat.layer.cornerRadius = Constants.CORNERRAD
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //seatRaceBoats having many in it from previous runs
        super.viewDidAppear(animated)
        seatRaceBoats = []
        for index in 0..<boats.numberOfRows(inSection: 0) {
            //TEST whether - 1 is needed
            let customIndexPath = IndexPath(row: index, section: 0)
            let cell = boats.cellForRow(at: customIndexPath) as! boatSeatRaceTableCell
            let newBoat = SeatRaceBoat(context: CoreDataStack.context)
            newBoat.uniqueIdentifier = UUID()
            newBoat.boatName = cell.boatName.text
            let laneNumberChar = cell.laneNumber.text?.last
            let stringVer = String(laneNumberChar!)
            newBoat.lane =  Int16(stringVer)!
            newBoat.type = cell.boatType.text
            seatRaceBoats.append(newBoat)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isMovingFromParent {
            for boat in seatRaceBoats {
                CoreDataStack.context.delete(boat)
            }
        }
    }
    
    func setUpTextFields() {
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: view.frame.size.width, height: 30)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        distance.inputAccessoryView = toolbar
    }
    @objc func doneButtonAction(){
        self.view.endEditing(true)
    }
    
    @objc func newSeatRaceBoat() {
        distance.resignFirstResponder()
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbPopUpID") as! PopUpViewController
        self.addChild(popOverVC)
        popOverVC.delegate = self
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: self)
    }
    
    func boatCreated(boatName: String, lane: Int, boatType: String) {
        let newBoat = SeatRaceBoat(context: CoreDataStack.context)
        newBoat.uniqueIdentifier = UUID()
        
        newBoat.boatName = boatName
        newBoat.lane = Int16(lane)
        newBoat.type = boatType
        seatRaceBoats.append(newBoat)
        boats.reloadData()
        
    }
    
    @IBAction func distanceInfoPushed(_ sender: Any) {
        distance.resignFirstResponder()
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "distanceInfo") as! distanceInfoViewController
        self.addChild(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: self)
    }
    //MARK: Table View Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return seatRaceBoats.count
        } else {
            return 1
        }
    }
    
    //Builds Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 1) {
            //Last Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "addSeatRaceboatCell", for: indexPath) as! addSeatRaceBoatTableCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "boatSeatRaceTableCell", for: indexPath) as! boatSeatRaceTableCell
            cell.boatName.text = seatRaceBoats[indexPath.row].boatName
            cell.boatType.text = seatRaceBoats[indexPath.row].type
            cell.laneNumber.text = "Lane: \(seatRaceBoats[indexPath.row].lane)"
            return cell
        }
    }
    //MARK: Editing boat delegates
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.section == 0) {
            return true
        }
        return false
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0) {
            return "Boats"
        }
        return ""
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //Delete again
            if (indexPath.section == 0) { CoreDataStack.context.delete(seatRaceBoats[indexPath.row])
                seatRaceBoats.remove(at: indexPath.row)
                // Delete the row from the data source
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else {
            }
        }
    }
    //Selection edit boat
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        distance.resignFirstResponder()
        if (indexPath.section == 0) {
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbPopUpID") as! PopUpViewController
            
            self.addChild(popOverVC)
            popOverVC.delegate = self
            popOverVC.view.frame = self.view.frame
            self.view.addSubview(popOverVC.view)
            popOverVC.didMove(toParent: self)
            popOverVC.boatNameField.text = seatRaceBoats[indexPath.row].boatName
            popOverVC.closeButton.setTitle("Delete Boat", for: .normal)
            let index = findScrollerTypeIndex(boatTypes: popOverVC.boatTypes, index: indexPath.row)
            
            popOverVC.laneBoatTypePicker.selectRow(Int(seatRaceBoats[indexPath.row].lane - 1), inComponent: 0, animated: true)
            popOverVC.laneBoatTypePicker.selectRow(index!, inComponent: 1, animated: true)
            popOverVC.createBoatLabel.text = "Edit Boat"
            popOverVC.addBoatButton.setTitle("Edit", for: .normal)
            
            //Delete existing row
            CoreDataStack.context.delete(seatRaceBoats[indexPath.row])
            seatRaceBoats.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
    
    func findScrollerTypeIndex(boatTypes: [String], index: Int) -> Int? {
        var count = 0
        var found: Int?
        for boatType in boatTypes {
            if (boatType == seatRaceBoats[index].type) {
                found = count
                return found
            }
            count = count + 1
        }
        return found
    }
    
    
    //MARK: Segue Runs validation checks
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if let ident = identifier {
            if ident == "fillBoatsGo" {
                let raceDistance = Int(distance.text!)
                if (raceDistance == nil && seatRaceBoats.count == 0) {
                    //Let user know of failure by highlighting border red
                    distance.layer.borderColor = UIColor.red.cgColor
                    distance.layer.cornerRadius = Constants.CORNERRAD
                    distance.layer.borderWidth = 1.0
                    boats.layer.borderColor = UIColor.red.cgColor
                    boats.layer.cornerRadius = Constants.CORNERRAD
                    boats.layer.borderWidth = 1.0
                    return false
                }
                if (raceDistance == nil) {
                    
                    boats.layer.borderWidth = 0.0
                    distance.layer.borderColor = UIColor.red.cgColor
                    distance.layer.borderWidth = 1.0
                    distance.layer.cornerRadius = Constants.CORNERRAD
                    return false
                }
                if (seatRaceBoats.count == 0) {
                    distance.layer.borderWidth = 0.0
                    boats.layer.borderColor = UIColor.red.cgColor
                    boats.layer.borderWidth = 1.0
                    boats.layer.cornerRadius = Constants.CORNERRAD
                    return false
                }
                if (seatRaceBoats.count == 1) {
                    let alertController = UIAlertController(title: "Seat Race", message: "You need at least two boats to seat race.", preferredStyle: .alert)
                    
                    // Create the actions
                    let okAction = UIAlertAction(title: "Confirm", style: UIAlertAction.Style.default) {
                        UIAlertAction in
                    }
                    // Add the actions
                    alertController.addAction(okAction)
                    // Present the controller
                    self.present(alertController, animated: true, completion: nil)
                    //Red lines
                    distance.layer.borderWidth = 0.0
                    boats.layer.borderColor = UIColor.red.cgColor
                    boats.layer.borderWidth = 1.0
                    boats.layer.cornerRadius = Constants.CORNERRAD
                    return false
                }
            }
        }
        return true
    }
    
    
    
    //Does Segue
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        if segue.identifier == "fillBoatsGo", let destination = segue.destination as? FillBoatsOverviewViewController
        {
            let newRace = SeatRace(context: CoreDataStack.context)
            let raceDistance = Int(distance.text!)
            newRace.distance = Int32(raceDistance!)
            newRace.date = Date()
            destination.seatRaceBoats = seatRaceBoats
            destination.seatRace = newRace
        }
    }
    
    
    //MARK: Textfield delegate, ensure only numbers entered
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return string.rangeOfCharacter(from: invalidCharacters) == nil
    }
}
