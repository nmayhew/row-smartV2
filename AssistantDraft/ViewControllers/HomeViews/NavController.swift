//
//  NavController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 18/08/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit
import Firebase

class NavController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("Hello")
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Auth.auth().addStateDidChangeListener() { auth, user in
          if user == nil {
            self.popUpLogin()
          }
        }
        
    }
    
    func popUpLogin() {
        let logInPopOver = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login") as! loginViewController
        self.addChild(logInPopOver)
        logInPopOver.view.frame = self.view.frame
        
        self.view.addSubview(logInPopOver.view)
        logInPopOver.didMove(toParent: self)
    }
}
