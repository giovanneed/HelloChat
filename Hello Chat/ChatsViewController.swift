 //
//  ChatsViewController.swift
//  Hello Chat
//
//  Created by Giovanne Dias on 5/21/16.
//  Copyright © 2016 GED App. All rights reserved.
//

import Foundation

class ChatsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var chats = [Chat]()
    
    @IBOutlet weak var tableView: UITableView!
    
    var messageRef = FIRDatabaseReference()
    let rootRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Chats"
        self.tabBarController?.tabBar.hidden = false
        
       /* DataBaseController.sharedInstance.listChats { (error, list) in
            self.chats = list!
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
               self.tableView.reloadData()
            }
           
        }*/
        
        
        messageRef = rootRef.child("chats")
        
        messageRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let modelChat = snapshot.value as! [String : AnyObject]
            print(modelChat)
            let dicChat = modelChat as NSDictionary
             print(dicChat)
            let chat = Chat(model: modelChat as NSDictionary)
            let receiver = chat.receiver(Controller.sharedInstance.loggedUser.identification)
            let chatID = Controller.sharedInstance.chatIDByMembers(receiver)
            chat.chatID = chatID
            
            if Controller.sharedInstance.chatBelongsToMe(chat, me: Controller.sharedInstance.loggedUser) {
                self.chats.append(chat)
                self.tableView.reloadData()
            }
            
            
            //check if its for me   if (user.identification != Controller.sharedInstance.loggedUser.identification) {
            
        })

        
        
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return chats.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CellChat") as! CellChat
        let chat = chats[indexPath.row]
        let receiver = chat.receiver(Controller.sharedInstance.loggedUser.identification)
        cell.lblChatMembers.text =  receiver.name
        cell.lblLastMessage.text = chat.lastMessage
        cell.imageChat.downloadedFrom(link: String(receiver.imageURL), contentMode: .ScaleAspectFit)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let chat = chats[indexPath.row]
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.performSegueWithIdentifier("SegueChatFromChats", sender: chat)
        }

       
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SegueChatFromChats" {
            
            let chat = sender as! Chat
            
            let chatViewController = segue.destinationViewController as! ChatViewController
            
            chatViewController.senderId = Controller.sharedInstance.loggedUser.identification
            chatViewController.senderDisplayName = Controller.sharedInstance.loggedUser.name
            
            chatViewController.receiver = chat.receiver(Controller.sharedInstance.loggedUser.identification)
            chatViewController.chat = chat
            
          //  chatViewController.user = nil//chat.userWithoutLoggedUserName()!
            
        }
    }
    
    
    
}

class CellChat : UITableViewCell {
    @IBOutlet weak var imageChat: UIImageView!
    @IBOutlet weak var lblChatMembers: UILabel!
    @IBOutlet weak var lblLastMessage: UILabel!
    
}