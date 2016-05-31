//
//  ContactsViewController.swift
//  Hello Chat
//
//  Created by Giovanne Dias on 5/21/16.
//  Copyright © 2016 GED App. All rights reserved.
//

import Foundation


class ContacsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var contacts = [User]()
    
    var messageRef = FIRDatabaseReference()
    let rootRef = FIRDatabase.database().reference()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Contacts"
        
        /*DataBaseController.sharedInstance.listUsers { (error, list) in
            self.contacts = list!
            self.tableView.reloadData()
        }*/
        
        messageRef = rootRef.child("Users")
        
        messageRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let modelUser = snapshot.value as! [String : AnyObject]
            print(modelUser)
            let user = User(model:modelUser as NSDictionary)
            user.downloadProfileImage()
            print(user.identification)
            
            if (user.identification != Controller.sharedInstance.loggedUser.identification) {
                self.contacts.append(user)
                self.tableView.reloadData()

            }
          
        })

        
        
        
        
        
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
      return contacts.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CellUser") as! CellUser
        let user = contacts[indexPath.row]
        cell.profileImage.downloadedFrom(link: String(user.imageURL), contentMode: .ScaleAspectFit)
        
        cell.lblContactName.text = user.name
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let receiver = contacts[indexPath.row]
        let chatID = Controller.sharedInstance.chatIDByMembers(receiver)
        DataBaseController.sharedInstance.chatBy(chatID) { (error, chat) in
            
            if error ==  false {
                //exist
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.performSegueWithIdentifier("SegueChatFromContacts", sender: chat)
                }
               
            
            }else {
                //create
                DataBaseController.sharedInstance.addChat(receiver)
                let newChat = Chat()
                newChat.chatID = Controller.sharedInstance.chatIDByMembers(receiver)
                newChat.member1 = Controller.sharedInstance.loggedUser
                newChat.member2 = receiver
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.performSegueWithIdentifier("SegueChatFromContacts", sender: newChat)
                }
                
            }
        }
       

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SegueChatFromContacts" {
            
            let chat = sender as! Chat
            
            let chatViewController = segue.destinationViewController as! ChatViewController
            chatViewController.receiver = chat.receiver(Controller.sharedInstance.loggedUser.identification)
            chatViewController.senderId = Controller.sharedInstance.loggedUser.identification
            chatViewController.senderDisplayName = Controller.sharedInstance.loggedUser.name
            chatViewController.chat = chat
            
            
            
            
            print(chatViewController.senderId)
            
        }
    }
    
    
    
}

class CellUser : UITableViewCell {
    
    @IBOutlet weak var lblContactName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
}