//
//  TeamViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 28/04/2020.
//  Copyright © 2020 Mayhew. All rights reserved.
//

import Foundation
import UIKit
//import Firebase

class TeamViewController: UIViewController {
    
    @IBOutlet weak var deleteAccount: UIButton!
    @IBOutlet weak var passwordChange: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var teamLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logOutButton.layer.cornerRadius = 5.0
        passwordChange.layer.cornerRadius = 5.0
        deleteAccount.layer.cornerRadius = 5.0
        //let user = Auth.auth().currentUser
        //teamLabel.text = user?.displayName
        /*Auth.auth().addStateDidChangeListener() { auth, user in
                 if user != nil {
                    self.teamLabel.text = user?.displayName
                 }
        }*/
    }
    
    @IBAction func changePassword(_ sender: Any) {
        /*Auth.auth().sendPasswordReset(withEmail: Auth.auth().currentUser!.email!) { error in
            if (error != nil) {
                let title = "Failed Password Reset"
                var message = "Failed to reset your password"
                let errorAuthStatus = AuthErrorCode.init(rawValue: error!._code)!
                if (errorAuthStatus == .invalidEmail) {
                    message = "Email address provided is invalid"
                } else if (errorAuthStatus == .invalidSender) {
                    message = "There is no account for this email address"
                } else {
                    message = error!.localizedDescription
                }
                let alert = UIAlertController(title: title,
                                              message: message,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            } else {
                let title = "Password Reset"
                let message = "Please check your email to reset your password"
                let alert = UIAlertController(title: title,message: message, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
                let firebaseAuth = Auth.auth()
                do {
                  try firebaseAuth.signOut()
                } catch let signOutError as NSError {
                  print ("Error signing out: %@", signOutError)
                }
            }
            
        }*/
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        /*let title = "Delete Account"
        let message = "We're sorry to see you go :(. Please confirm"
        let alert = UIAlertController(title: title,message: message, preferredStyle: .alert)
        let delete = UIAlertAction(title: "Confirm", style: .destructive) { _ in
            self.deleteAccountHelper()
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(delete)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }*/
    }
    
    func deleteAccountHelper() {
        /*let user = Auth.auth().currentUser
        user?.delete { error in
            if let error = error {
                let errorAuthStatus = AuthErrorCode.init(rawValue: error._code)!
                if (errorAuthStatus == .requiresRecentLogin) {
                    self.reauthorise()
                } else {
                    let alert = UIAlertController(title: "Deletion Failed", message: error.localizedDescription,preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            } 
        }*/
    }
    
    func reauthorise() {
        /*let alert = UIAlertController(title: "Authenticate",
                                      message: "For security reasonse we have to verify your account details",
                                      preferredStyle: .alert)
        let confirmDeletion = UIAlertAction(title: "Confirm", style: .destructive) { _ in
          
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            let user = Auth.auth().currentUser
            let credential = EmailAuthProvider.credential(withEmail: emailField.text!, password: passwordField.text!)
            user?.reauthenticate(with: credential, completion: { result, error in
                
                if (error != nil) {
                    let alert = UIAlertController(title: "Reauthentication Failed", message: error!.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.deleteAccountHelper()
                }
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        alert.addTextField { textEmail in
          textEmail.placeholder = "Enter your team email"
        }
        
        alert.addTextField { textPassword in
          textPassword.isSecureTextEntry = true
          textPassword.placeholder = "Enter your team password"
        }
        
        alert.addAction(confirmDeletion)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)*/
    }
}
