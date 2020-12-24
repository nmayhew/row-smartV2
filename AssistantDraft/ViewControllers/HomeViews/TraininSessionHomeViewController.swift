//
//  TraininSessionHomeViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 28/08/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation


class traininSesHomeCell: UICollectionViewCell {
    @IBOutlet weak var trainDate: UILabel!
    @IBOutlet weak var pieces: UILabel!
    @IBOutlet weak var runTime: UILabel!
    @IBOutlet weak var distance: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}


class TraininSessionHomeViewController: parentHomeViewController, UICollectionViewDataSource {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var trainCollection: UICollectionView!
    
    private var reuseID = "trainSesCell"
    private var trainSesArray: [TrainingSession] = []
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trainCollection.delegate = self
        trainCollection.dataSource = self
        trainSesArray = getSessions()
        setUpButtons(button: addButton)
        let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(TraininSessionHomeViewController.handleLongPress(gestureRecognizer:)))
        lpgr.minimumPressDuration = 0.7
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = true
        self.trainCollection.addGestureRecognizer(lpgr)
        
    }
    
    @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
        //Validation check
        //Checking not placeholder cell
        if (trainSesArray.count == 0) {
            return
        }
        
        if (gestureRecognizer.state != UIGestureRecognizer.State.began){
            return
        }
        
        //Find indexPath, set up alert controller
        let p = gestureRecognizer.location(in: self.trainCollection)
        if let indexPath = (self.trainCollection.indexPathForItem(at: p)) {
            let alertController = UIAlertController(title: "Delete", message: "Confirm to delete this seat race", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Confirm", style: .destructive) { (_) -> Void in
                CoreDataStack.context.delete(self.trainSesArray[indexPath.row])
                CoreDataStack.saveContext()
                
                self.trainSesArray.remove(at: indexPath.row)
                if (self.trainSesArray.count != 0) {
                    self.trainCollection.deleteItems(at: [indexPath])
                    
                } else {
                    self.trainCollection.reloadData()
                }
                
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    
    
    func getSessions() -> [TrainingSession] {
        let fetchRequest: NSFetchRequest = TrainingSession.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(TrainingSession.date), ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            return try CoreDataStack.context.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    
    func isGPSAllowed() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                return false
            case .authorizedWhenInUse, .authorizedAlways:
                return true
            @unknown default:
                return false
            }
        } else {
            return false
        }
    }
    
    @IBAction func addButton(_ sender: Any) {
        if(isGPSAllowed()) {
            performSegue(withIdentifier: "newTraining", sender: self)
        } else {
            let alertController = UIAlertController(title: "Location Required", message: "You can't run a training session without location services. Please go to Settings and allow access to location services", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    //MARK: Collection Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (trainSesArray.count == 0) {
            return 1
        }
        return trainSesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (trainSesArray.count == 0) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as! traininSesHomeCell
            cell.trainDate.text = "No Training Sessions Recorded"
            cell.distance.text = "Press + to record a new training session"
            cell.distance.numberOfLines = 2
            cell.distance.textAlignment = .center
            cell.trainDate.textAlignment = .center
            cell.distance.textColor = .black
            cell.trainDate.textColor = .black
            cell.pieces.text = ""
            cell.runTime.text = ""
            cell.backgroundColor = .white
            return cell
        }
        
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd, yyyy"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as! traininSesHomeCell
       
        cell.addGradientBackground(firstColor: UIColor.init(rgb: 0x1B2BD6), secondColor: UIColor.init(rgb: 0x3d85e7))
        let formattedDistance = varFormatter.distance(Measurement(value: Double(trainSesArray[indexPath.row].distance), unit: UnitLength.meters))
        cell.distance.text = "Distance: \(formattedDistance)"
        let dateCurr = trainSesArray[indexPath.row].date!
        cell.trainDate.text = "Training -- \(dateFormatterPrint.string(from: dateCurr))"
        let formattedTime = varFormatter.time(Int(trainSesArray[indexPath.row].duration))
        cell.runTime.text = "Length: \(formattedTime)"
        //Pieces
        let sortDescriptorPiece = NSSortDescriptor(key: #keyPath(Piece.startTime), ascending: true)
        let pieces = trainSesArray[indexPath.row].pieces?.sortedArray(using:[sortDescriptorPiece]) as! [Piece]
        cell.pieces.text = "Number of Pieces: \(pieces.count)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (trainSesArray.count == 0) {
            
        } else {
            performSegue(withIdentifier: "newShowSessionDetails", sender: self)
        }
        
    }
    
    //MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "newShowSessionDetails",//TODO
            let destination = segue.destination as? SavedSessionsDetailsViewController,
            let trSesIndex = trainCollection.indexPathsForSelectedItems?.first!.row
        {
            destination.session = trainSesArray[trSesIndex]
        }
    }
    
    

}
