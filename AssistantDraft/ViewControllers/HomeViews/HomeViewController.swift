//
//  ViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 30/06/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//
/*
import UIKit

class homeButton: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var buttonName: UILabel!
}

import CoreLocation
class NavBarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var homeButtonsCollection: UICollectionView!
    
    
    let sectionInsets = UIEdgeInsets(top: 50.0,
                                     left: 15.0,
                                     bottom: 50.0,
                                     right: 15.0)
    private let reuseIdentifier = "homeButton"
    private let itemsPerRow: CGFloat = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeButtonsCollection.dataSource = self
        homeButtonsCollection.delegate = self
        //dataSource and delegate
    }
    override func viewDidAppear(_ animated: Bool) {
        homeButtonsCollection.reloadData()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: collection view funcs
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! homeButton
        cell.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = true
        cell.backgroundColor = UIColor.init(rgb: 0x1B2BD6)
        switch indexPath.row {
        case 0: cell.buttonName.text = "Saved Sessions"
        //case 1: cell.buttonName.text = "Pairs Matrix"
            
        case 1:cell.buttonName.text = "Seat Racing"

        case 2:cell.buttonName.text = "Racing"

        case 3:cell.buttonName.text = "Training"
            if (!isGPSAllowed())  {
                //cell.backgroundColor = .darkGray
            }

        default: print("AHHH")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = homeButtonsCollection.cellForItem(at: indexPath)
        let colour = cell?.backgroundColor
        cell?.backgroundColor = colour?.withAlphaComponent(0.8)
        switch indexPath.row {
        case 0: performSegue(withIdentifier: "mySessionsSegue", sender: self)
       // case :print("TODO:")
        case 1:
            performSegue(withIdentifier: "startSeatRaceSegue", sender: self)
            
        case 2:performSegue(withIdentifier: "raceSegue", sender: self)
           
        case 3:
            if(shouldPerformSegue(withIdentifier: "trainingSesSegue", sender: self)) {
                performSegue(withIdentifier: "trainingSesSegue", sender: self)
            }
        default: print("AHHH")
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = homeButtonsCollection.cellForItem(at: indexPath)
        let colour = cell?.backgroundColor
        cell?.backgroundColor = colour?.withAlphaComponent(1.0)
    
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
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "trainingSesSegue") {
            if (isGPSAllowed()) {
                return true
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
                return false
            }
        }
        return true
    }
    
}

// MARK: - Collection View Flow Layout Delegate
extension NavBarViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem/2.5)//TODO: Change this with images
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}*/
