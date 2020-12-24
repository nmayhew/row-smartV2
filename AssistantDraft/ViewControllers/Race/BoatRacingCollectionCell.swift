//
//  CollectionViewCell.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 23/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit

//MARK: Protocol delegations
protocol startDelegate {
    func startPressed()
}

protocol finishDelegate {
    func finishPressed()
}

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lane: UILabel!
    @IBOutlet weak var boatName: UILabel!
    @IBOutlet weak var time: UILabel!
    
}
