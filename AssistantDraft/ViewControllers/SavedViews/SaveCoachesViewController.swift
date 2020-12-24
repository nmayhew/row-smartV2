//
//  SaveCoachesViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 17/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit

class SaveCoachesViewController: UIViewController {
    
    
    @IBOutlet weak var coachTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(newNotes), name: NSNotification.Name(rawValue: "savedCoachNotesSent"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notesViewLoaded"), object: nil)
        
    }
    
    //Set CoachesNotes
    @objc func newNotes(notification: NSNotification) {
        if let coachNotes = notification.userInfo?["coachNotes"] as? String {
            coachTextView.text = coachNotes
        }
    }
}

