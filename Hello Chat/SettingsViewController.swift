//
//  SettingsViewController.swift
//  Hello Chat
//
//  Created by Giovanne Dias on 5/21/16.
//  Copyright © 2016 GED App. All rights reserved.
//

import Foundation

class SettingsViewController : UIViewController {
    
    
    @IBOutlet weak var imageProfile: UIImageView!
    
    @IBOutlet weak var lblName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageProfile.image = Controller.sharedInstance.loggedUser.image.image
        
        self.lblName.text = Controller.sharedInstance.loggedUser.name
        
    }
    
    @IBAction func signout(sender: UIButton) {
        FBSDKAccessToken.setCurrentAccessToken(nil)
        performSegueWithIdentifier("SegueLogout", sender: nil)
    }
    
    
}