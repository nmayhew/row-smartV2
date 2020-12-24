//
//  HomeViewController2nd.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 29/08/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit

class HomeViewController2nd: UITabBarController {

    @IBOutlet weak var myTabBar: UITabBar!
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = index
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewWillAppear(animated)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        super.viewWillDisappear(animated)
    }
}
