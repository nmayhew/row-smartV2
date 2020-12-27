//
//  CoachNotesViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 10/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit
protocol sendNotes {
    func sendNotes(notes: String)
}
protocol notesLoaded {
    func loadNotes()
}
class CoachNotesViewController: UIViewController, UITextViewDelegate {

    //MARK: Variables
    @IBOutlet weak var CoachNotesView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var delegate: sendNotes?
    var delegateLoaded: notesLoaded?
    
    //Sets up observer for receiving updated coaches notes.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegateLoaded?.loadNotes()
        
        CoachNotesView.layer.cornerRadius = 5.0
        CoachNotesView.isScrollEnabled = true
        CoachNotesView.delegate = self
        CoachNotesView.text = "Coaches' Notes"
        CoachNotesView.textColor = UIColor.lightGray
        CoachNotesView.selectedTextRange = CoachNotesView.textRange(from: CoachNotesView.beginningOfDocument, to: CoachNotesView.beginningOfDocument)
        CoachNotesView.tintColor = .systemBlue
        setUpTextFields()
        
        CoachNotesView.layer.borderColor = UIColor.lightGray.cgColor
        CoachNotesView.layer.borderWidth = 1.0
        CoachNotesView.isDirectionalLockEnabled = true
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(confirmSession), name: NSNotification.Name(rawValue: "confirmSession"), object: nil)
    }
    
    //Adjust text view for coach notes when keyboard appears
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            CoachNotesView.contentInset = .zero
        } else {
            CoachNotesView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom - 100, right: 0)
        }
        CoachNotesView.scrollIndicatorInsets = CoachNotesView.contentInset
        let selectedRange = CoachNotesView.selectedRange
        CoachNotesView.scrollRangeToVisible(selectedRange)
    }
    
    //Adds done button to keyboard to dismiss keyboard
    func setUpTextFields() {
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: view.frame.size.width, height: 30)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        CoachNotesView.inputAccessoryView = toolbar
    }
    
    //Called when done button on keyboard pressed
    @objc func doneButtonAction(){
        self.view.endEditing(true)
    }
    
    //Function call by observer to update coachesNotes
    @objc func confirmSession(notification: NSNotification) {
        self.delegate?.sendNotes(notes: CoachNotesView.text)
    }
    
    //MARK: Placeholder Text
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if CoachNotesView.textColor == UIColor.lightGray {
                CoachNotesView.selectedTextRange = CoachNotesView.textRange(from: CoachNotesView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:String = CoachNotesView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            
            CoachNotesView.text = "Coaches' Notes"
            CoachNotesView.textColor = UIColor.lightGray
            
            CoachNotesView.selectedTextRange = CoachNotesView.textRange(from: CoachNotesView.beginningOfDocument, to: CoachNotesView.beginningOfDocument)
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, set
            // the text color to black then set its text to the
            // replacement string
        else if CoachNotesView.textColor == UIColor.lightGray && !text.isEmpty {
            CoachNotesView.textColor = UIColor.black
            CoachNotesView.text = text
        }
            
            // For every other case, the text should change with the usual
            // behavior...
        else {
            return true
        }
        
        // ...otherwise return false since the updates have already
        // been made
        return false
    }
   
}


