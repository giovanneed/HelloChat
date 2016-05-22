//
//  ViewController.swift
//  Hello Chat
//
//  Created by Giovanne Dias on 5/20/16.
//  Copyright © 2016 GED App. All rights reserved.
//

import UIKit
import Firebase





class ViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
   
    @IBOutlet weak var lblText: UILabel!

    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    
    let rootRef = FIRDatabase.database().reference()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let conditionRef  = rootRef.child("condition")
        conditionRef.observeEventType(.Value) { (snap : FIRDataSnapshot) in
            self.lblText.text = snap.value?.description()
        }
        
        
        
        //Google login
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()!.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // Uncomment to automatically sign in the user.
        //GIDSignIn.sharedInstance().signInSilently()
        
        // TODO(developer) Configure the sign-in button look/feel
        // ...


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "SegueLogged" {
            
            let navVc = segue.destinationViewController as! UINavigationController // 1
            let chatVc = navVc.viewControllers.first as! ChatViewController // 2
            
            
            let loggedUser = sender as! User
            
            chatVc.user = loggedUser
            chatVc.senderId = loggedUser.identification
            chatVc.senderDisplayName = loggedUser.name
            
        }
     
        
        
    }
    
    
    
    //Google Delegate
    
    func application(application: UIApplication,
                     openURL url: NSURL, options: [String: AnyObject]) -> Bool {
        return GIDSignIn.sharedInstance().handleURL(url,
                                                    sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String,
                                                    annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
    }
    
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        let loggedUser = User()
        loggedUser.name = user.profile.name
        loggedUser.identification = user.userID
        loggedUser.email = user.profile.email
        
        DataBaseController.sharedInstance.addUser(loggedUser)
        Controller.sharedInstance.loggedUser = loggedUser
        
        performSegueWithIdentifier("SegueMain", sender: loggedUser)
        print(user.profile.name)
        
        DataBaseController.sharedInstance.listUsers { (error, list) in
            
        }
        // ...
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    
    @IBAction func logout(sender: AnyObject) {
        
        try! FIRAuth.auth()!.signOut()
    }
    
    /*func application(application: UIApplication,
     openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
     var options: [String: AnyObject] = [UIApplicationOpenURLOptionsSourceApplicationKey: sourceApplication,
     UIApplicationOpenURLOptionsAnnotationKey: annotation]
     return GIDSignIn.sharedInstance().handleURL(url,
     sourceApplication: sourceApplication,
     annotation: annotation)
     }*/



}




//Sing out
//try! FIRAuth.auth()!.signOut()
