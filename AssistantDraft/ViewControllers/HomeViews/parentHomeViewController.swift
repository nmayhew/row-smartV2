//
//  parentHomeViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 28/08/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit
import CoreData
class parentHomeViewController: UIViewController, UIGestureRecognizerDelegate {
    
    private let itemsPerRow: CGFloat = 1
    let sectionInsets = UIEdgeInsets(top: 50.0,
                                     left: 15.0,
                                     bottom: 50.0,
                                     right: 15.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    func setUpButtons(button: UIButton) {
        button.layer.cornerRadius = 20.0
        button.layer.masksToBounds = false
        button.layer.shadowColor = UIColor.darkGray.cgColor
        button.layer.shadowOpacity = 0.8
        button.layer.shadowOffset = CGSize(width: 0, height: 4.0)
        button.layer.shadowRadius = 3
    }

}

// MARK: - Collection View Flow Layout Delegate
extension parentHomeViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem/2)
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
}



