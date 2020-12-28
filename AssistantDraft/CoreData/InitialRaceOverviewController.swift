//
//  RacingViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 19/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit

//MARK: Cell Declaration
class boatTableCell: UITableViewCell {
    
    @IBOutlet weak var boatName: UILabel!
    @IBOutlet weak var laneNumber: UILabel!
    @IBOutlet weak var boatType: UILabel!
    
}

class addBoatTableCell: UITableViewCell {
    @IBOutlet weak var addBoat: UIButton!
    
    @IBAction func addBoatButton(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newBoat"), object: nil)
    }
}

//MARK: Initial view for racing, set distance and create boats overview
class CreateBoatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, popUpDelegate, UITextFieldDelegate  {
    
    
    @IBOutlet weak var distance: UITextField!
    @IBOutlet weak var boatTable: UITableView!
    @IBOutlet weak var infoDistanceButton: UIButton!
    @IBOutlet weak var createRace: UIButton!
    
    private var raceDist: Int32?
    private var raceBoats: [Boat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.boatTable.dataSource = self
        self.boatTable.delegate = self
        self.boatTable.roundCorners()
        
        NotificationCenter.default.addObserver(self, selector: Selector(("newBoat")), name: NSNotification.Name(rawValue: "newBoat"), object: nil)
        
        distance.delegate = self
        distance.keyboardType = .numberPad
        
        //Get rid of keyboard
        setUpTextFields()
        createRace.layer.cornerRadius = 5.0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isMovingFromParent {
            for boat in raceBoats {
                CoreDataStack.context.delete(boat)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //RaceBoats having many in it from previous runs
        super.viewDidAppear(animated)
        raceBoats = []
        for index in 0..<boatTable.numberOfRows(inSection: 0) {
            
            let customIndexPath = IndexPath(row: index, section: 0)
            let cell = boatTable.cellForRow(at: customIndexPath) as! boatTableCell
            let newBoat = Boat(context: CoreDataStack.context)
            newBoat.boatName = cell.boatName.text
            let laneNumberChar = cell.laneNumber.text?.last
            let stringVer = String(laneNumberChar!)
            newBoat.lane =  Int16(stringVer)!
            newBoat.type = cell.boatType.text
            raceBoats.append(newBoat)
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
    
    @objc func newBoat() {
        
        distance.resignFirstResponder()
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbPopUpID") as! PopUpViewController
        self.addChild(popOverVC)
        popOverVC.delegate = self
        
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: self)
    }
    
    func boatCreated(boatName: String, lane: Int, boatType: String) {
        let newBoat = Boat(context: CoreDataStack.context)
        newBoat.boatName = boatName
        newBoat.lane = Int16(lane)
        newBoat.type = boatType
        raceBoats.append(newBoat)
        boatTable.reloadData()
    }
    
    @IBAction func infoDistancePressed(_ sender: Any) {
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
            return raceBoats.count
        } else {
            return 1
        }
    }
    
    //Builds Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 1) {
            //Last Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "addboatCell", for: indexPath) as! addBoatTableCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "boatTableCell", for: indexPath) as! boatTableCell
            cell.boatName.text = raceBoats[indexPath.row].boatName
            cell.boatType.text = raceBoats[indexPath.row].type
            cell.laneNumber.text = "Lane: \(raceBoats[indexPath.row].lane)"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.section == 0) {
            return true
        }
        return false
    }
    
    //Selection edit boat
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Boats"
        } else {
            return ""
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        distance.resignFirstResponder()
        if (indexPath.section == 0) {
            
            //Pop up create boat page
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbPopUpID") as! PopUpViewController
            
            self.addChild(popOverVC)
            popOverVC.delegate = self
            self.view.addSubview(popOverVC.view)
            popOverVC.didMove(toParent: self)
            popOverVC.boatNameField.text = raceBoats[indexPath.row].boatName
            popOverVC.closeButton.setTitle("Delete Boat", for: .normal)
            let index = findScrollerTypeIndex(boatTypes: popOverVC.boatTypes, index: indexPath.row)
            
            popOverVC.laneBoatTypePicker.selectRow(Int(raceBoats[indexPath.row].lane - 1), inComponent: 0, animated: true)
            popOverVC.laneBoatTypePicker.selectRow(index!, inComponent: 1, animated: true)
            popOverVC.createBoatLabel.text = "Edit Boat"
            popOverVC.addBoatButton.setTitle("Edit", for: .normal)
            popOverVC.popUpView.addGradientBackground(firstColor: UIColor.init(rgb: 0x1B2BD6), secondColor: UIColor.init(rgb: 0x1b5ad6))
            

            //Delete existing row
            CoreDataStack.context.delete(raceBoats[indexPath.row])
            raceBoats.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
    
    //Ensures scroller wheel has right index when editing boat
    func findScrollerTypeIndex(boatTypes: [String], index: Int) -> Int? {
        var count = 0
        var found: Int?
        for boatType in boatTypes {
            if (boatType == raceBoats[index].type) {
                found = count
                return found
            }
            count = count + 1
        }
        return found
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //Delete again
            if (indexPath.section == 0) { CoreDataStack.context.delete(raceBoats[indexPath.row])
                raceBoats.remove(at: indexPath.row)
                // Delete the row from the data source
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else {
            }
        }
    }
    
    //MARK: Segue prep
    //Runs validation checks
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if let ident = identifier {
            if ident == "newRace" {
                let raceDistance = Int(distance.text!)
                if (raceDistance == nil && raceBoats.count == 0) {
                    //Let user know of failure by highlighting border red
                    distance.layer.borderColor = UIColor.red.cgColor
                    distance.layer.cornerRadius = 4.0
                    distance.layer.borderWidth = 1.0
                    boatTable.layer.borderColor = UIColor.red.cgColor
                    boatTable.layer.cornerRadius = 4.0
                    boatTable.layer.borderWidth = 1.0
                    return false
                }
                if (raceDistance == nil) {
                    
                    boatTable.layer.borderWidth = 0.0
                    distance.layer.borderColor = UIColor.red.cgColor
                    distance.layer.borderWidth = 1.0
                    distance.layer.cornerRadius = 4.0
                    return false
                }
                if (raceBoats.count == 0) {
                    distance.layer.borderWidth = 0.0
                    boatTable.layer.borderColor = UIColor.red.cgColor
                    boatTable.layer.borderWidth = 1.0
                    boatTable.layer.cornerRadius = 4.0
                    return false
                }
            }
        }
        return true
    }
    
    //Does Segue
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        if segue.identifier == "newRace", let destination = segue.destination as? RacingBoatViewController
        {
            let newRace = Race(context: CoreDataStack.context)
            let raceDistance = Int(distance.text!)
            newRace.distance = Int32(raceDistance!)
            newRace.date = Date()
            destination.currRaceBoats = raceBoats
            destination.currRace = newRace
        }
    }
    
    
    //MARK: Textfield delegate, ensure only numbers entered
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return string.rangeOfCharacter(from: invalidCharacters) == nil
    }
}
