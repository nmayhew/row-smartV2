//
//  CollectionViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 22/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//
/*
import UIKit

class CollectionViewController: UICollectionViewController {

    
    private let sectionInsets = UIEdgeInsets(top: 50.0,
                                             left: 20.0,
                                             bottom: 50.0,
                                             right: 20.0)
    
    var race: Race?
    private let itemsPerRow: CGFloat = 2
    private var raceBoats: [Boat] = []
    private let reuseIdentifier = "boatTimingCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        let sortDescriptorBoat = NSSortDescriptor(key: #keyPath(Boat.lane), ascending: true)
        raceBoats = race?.boats?.sortedArray(using: [sortDescriptorBoat]) as! [Boat]
        // Do any additional setup after loading the view.
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return raceBoats.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        cell.backgroundColor = .lightGray
        cell.boatName.text = "\(raceBoats[indexPath.row].boatName!) -- \(raceBoats[indexPath.row].type!)"
        cell.lane.text = "Lane: \(raceBoats[indexPath.row].lane)"
        let formattedTime = varFormatter.detailTime(cell.deciSeconds)
        cell.time.text = formattedTime
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}*/
