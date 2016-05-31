//
//  ViewController.swift
//  Hello Chat
//
//  Created by Giovanne Dias on 5/20/16.
//  Copyright © 2016 GED App. All rights reserved.
//

import UIKit
import Firebase





class LoginViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    
    let rootRef = FIRDatabase.database().reference()
    
    let facebookLoginButton = FBSDKLoginButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
            returnUserData()
        }
        //Facebook Login
        facebookLoginButton.delegate = self
        facebookLoginButton.center = view.center
        view.addSubview(facebookLoginButton)
        
        
        
        //Google login
        signInButton.center = view.center

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
            
            /*let navVc = segue.destinationViewController as! UINavigationController // 1
            let chatVc = navVc.viewControllers.first as! ChatViewController // 2
            
            
            let loggedUser = sender as! User
            
            chatVc.user = loggedUser
            chatVc.senderId = loggedUser.identification
            chatVc.senderDisplayName = loggedUser.name*/
            
        }
     
        
        
    }
    
    
    //Facebook Delegate
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        print(result)
        returnUserData()
       /*let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            // ...
            print(user)
            let loggedUser = User()

        }*/
        // ...
    }
    
    func returnUserData()
    {
        
        
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,interested_in,gender,birthday,email,age_range,name,picture.width(480).height(480)"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) == nil) {
             
                print("fetched user: \(result)")
                let id : NSString = result.valueForKey("id") as! String
                let name : NSString = result.valueForKey("name") as! String
                let imgURL : NSString = result.valueForKeyPath("picture.data.url") as! String
              
                let loggedUser = User()
                
                loggedUser.imageURL = NSURL(string:imgURL as String)!
                loggedUser.downloadProfileImage()
                loggedUser.name = name as String
                loggedUser.identification = id as String
                
                DataBaseController.sharedInstance.addUser(loggedUser)
                Controller.sharedInstance.loggedUser = loggedUser
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                     self.performSegueWithIdentifier("SegueMain", sender: loggedUser)
                }
              

                print("User ID is: \(id)")
                //etc...
            }
        })
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
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
        
        //let dimension = round(50 * UIScreen.mainScreen().scale);
        loggedUser.imageURL = user.profile.imageURLWithDimension(50)
        
        loggedUser.downloadProfileImage()
        
        loggedUser.name = user.profile.name
        loggedUser.identification = user.userID
        loggedUser.email = user.profile.email
        
        DataBaseController.sharedInstance.addUser(loggedUser)
        Controller.sharedInstance.loggedUser = loggedUser
        
        performSegueWithIdentifier("SegueMain", sender: loggedUser)
        
        
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        // Perform any operations when the user disconnects from app here.
        // ...
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
