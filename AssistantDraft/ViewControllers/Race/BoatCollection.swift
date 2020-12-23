//
//  BoatCollection.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 23/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//
/*
import UIKit

class BoatCollection: UICollectionView {

    let sectionInsets = UIEdgeInsets(top: 50.0,
                                             left: 20.0,
                                             bottom: 50.0,
                                             right: 20.0)
   
    private let itemsPerRow: CGFloat = 2
    private let reuseIdentifier = "boatTimingCell"
    var race: Race?
    var raceBoats: [Boat] = []
    
    
    
    
    // MARK: UICollectionDataSource
    override func numberOfItems(inSection section: Int) -> Int {
        
    }
   
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return raceBoats.count
    }
    
   coll
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        cell.backgroundColor = .lightGray
        cell.boatName.text = "\(raceBoats[indexPath.row].boatName!) -- \(raceBoats[indexPath.row].type!)"
        cell.lane.text = "Lane: \(raceBoats[indexPath.row].lane)"
        let formattedTime = varFormatter.detailTime(cell.deciSeconds)
        cell.time.text = formattedTime
        
        return cell
    }
    
    
}
// MARK: - Collection View Flow Layout Delegate
extension BoatCollection : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = self.view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
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
