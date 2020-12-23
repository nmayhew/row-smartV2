//
//  LoginView.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 28/04/2020.
//  Copyright © 2020 Mayhew. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

//Pop up to create login details
class loginViewController: popUPViewController {
    //MARK: Outlets
    @IBOutlet weak var loginSubView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var loginIn: UIButton!
    @IBOutlet weak var SignUpview: UIView!
    @IBOutlet weak var realSignUpButton: UIButton!
    @IBOutlet weak var backFromSignUp: UIButton!
    @IBOutlet weak var teamName: UITextField!
    @IBOutlet weak var teamEmailAddress: UITextField!
    @IBOutlet weak var teamPassword: UITextField!
    @IBOutlet weak var forgottenPassword: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        showAnimate()
        //Set up
        loginSubView.layer.cornerRadius = 5.0   
        signUp.layer.cornerRadius = 5.0
        loginIn.layer.cornerRadius = 5.0
        SignUpview.layer.cornerRadius = 5.0
        realSignUpButton.layer.cornerRadius = 5.0
        forgottenPassword.layer.cornerRadius = 5.0
        backFromSignUp.layer.borderWidth = 1.0
        backFromSignUp.layer.borderColor = UIColor.white.cgColor
        backFromSignUp.layer.cornerRadius = 5.0
        SignUpview.isHidden = true
        
        Auth.auth().addStateDidChangeListener() { auth, user in
            user?.reload { (error) in
                if user != nil {
                    if (user!.isEmailVerified) {
                        self.removeAnimate()
                        self.removeFromParent()
                    } else {
                        let alert = UIAlertController(title: "Verify Email",
                                              message: "Please check your inbox and junk to verify your email address",
                                              preferredStyle: .alert)
                
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                
                        self.present(alert, animated: true, completion: nil)
                        self.SignUpview.isHidden = true
                        self.loginSubView.isHidden = false
                        self.teamPassword.text = ""
                        self.teamEmailAddress.text = ""
                        self.teamName.text = ""
                        self.removeAnimate()
                        self.removeFromParent()
                        do { try Auth.auth().signOut()
                        } catch let signOutError as NSError {
                          print ("Error signing out: %@", signOutError)
                        }
                    }
                }
            }
        }

        teamName.delegate = self
        teamEmailAddress.delegate = self
        teamPassword.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @IBAction func realSignUpPressed(_ sender: Any) {
        guard
          let email = teamEmailAddress.text,
          let password = teamPassword.text,
            let teamName = teamName.text,
          email.count > 0,
          password.count > 0,
        teamName.count > 0
          else {
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if error == nil {
                Auth.auth().signIn(withEmail: self.teamEmailAddress.text!, password: self.teamPassword.text!)
                let user = Auth.auth().currentUser!
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = teamName
                changeRequest.commitChanges { (error) in
                    if error != nil {
                        self.handleError(error: error!)
                    }
                }
                switch user.isEmailVerified {
                case true:
                    print("Shouldn't be possible")
                case false:
                    user.sendEmailVerification { (error) in
                        guard let error = error else {
                            return print("useremail verification sent")
                        }
                        self.handleError(error: error)
                    }
                }
            } else {
                self.handleError(error: error!)
            }
            
        }
        
    }
    
    @IBAction func forgottenPassPushed(_ sender: Any) {
        let alert = UIAlertController(title: "Forgotten Password",
                                         message: "Reset your password",
                                         preferredStyle: .alert)
           
           let saveAction = UIAlertAction(title: "Reset", style: .default) { _ in
             
                let emailField = alert.textFields![0]
                Auth.auth().sendPasswordReset(withEmail: emailField.text!) { error in
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
                        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                }
            }
           let cancelAction = UIAlertAction(title: "Cancel",
                                            style: .cancel)
           
           alert.addTextField { textEmail in
             textEmail.placeholder = "Enter your team email"
           }

           alert.addAction(saveAction)
           alert.addAction(cancelAction)
           present(alert, animated: true, completion: nil)
    }
    
    //MARK: Actions
    @IBAction func loginTouch(_ sender: Any) {
        guard
             let email = emailTextField.text,
             let password = passwordTextField.text,
             email.count > 0,
             password.count > 0
             else {
               return
           }
           
           Auth.auth().signIn(withEmail: email, password: password) { user, error in
             if let error = error, user == nil {
                self.handleError(error: error)
             } else {
                let user = Auth.auth().currentUser!
                if (!user.isEmailVerified) {
                    let alert = UIAlertController(title: "Verify Email",
                                                  message: "Please check your inbox and junk to verify your email address",
                                                  preferredStyle: .alert)
                    
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                    do { try Auth.auth().signOut()
                    } catch let signOutError as NSError {
                      print ("Error signing out: %@", signOutError)
                    }
                }
            }
           }
    }
    
    
    @IBAction func signUpTouch(_ sender: Any) {
        SignUpview.isHidden = false
        loginSubView.isHidden = true
    }
    
    @IBAction func backButton(_ sender: Any) {
        SignUpview.isHidden = true
        loginSubView.isHidden = false
    }
    
    func handleError(error: Error) {
        let errorAuthStatus = AuthErrorCode.init(rawValue: error._code)!
        var title = "Failed"
        var message = "Failed to Log in or Sign Up"
         switch errorAuthStatus {
         case .wrongPassword:
            title = "Sign In Failed"
            message = "Invalid password or email address provided"
         case .invalidEmail:
            title = "Invalid Email"
            message = "Invalid email address provided"
         case .operationNotAllowed:
             print("operationNotAllowed")
         case .userDisabled:
            title = "Sign In Failed"
            message = "User is disabledd"
             print("userDisabled")
         case .userNotFound:
             title = "Sign In Failed"
             message = "Invalid Password or email address provided"
         case .tooManyRequests:
             print("tooManyRequests, oooops")
         case .emailAlreadyInUse:
            title = "Invalid Email"
            message = "Email address already in use"
         default: message = error.localizedDescription
         }
         let alert = UIAlertController(title: title,
                                       message: message,
                                       preferredStyle: .alert)
         
         alert.addAction(UIAlertAction(title: "OK", style: .default))
         
         self.present(alert, animated: true, completion: nil)
     }

}
extension loginViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == emailTextField {
      passwordTextField.becomeFirstResponder()
    }
    if textField == passwordTextField {
      textField.resignFirstResponder()
    }
    
    if textField == teamName {
        teamEmailAddress.becomeFirstResponder()
    }
    if textField == teamEmailAddress {
        teamPassword.becomeFirstResponder()
    }
    if textField == teamPassword {
        textField.resignFirstResponder()
    }
    
    return true
  }
}
