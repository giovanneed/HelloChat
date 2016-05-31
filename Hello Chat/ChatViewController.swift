	//
//  ChatViewController.swift
//
//  Created by Giovanne Dias on 5/20/16.
//  Copyright © 2016 GED App. All rights reserved.
//

import Foundation
import Firebase


class ChatViewController: JSQMessagesViewController {
    
    
    var receiver : User = User()
   
    var chat : Chat = Chat()


    var messages = [JSQMessage]()
    
    let rootRef = FIRDatabase.database().reference()
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
   var messageRef = FIRDatabaseReference()
    
    var usersTypingQuery = FIRDatabaseQuery()
    
    var Timestamp: NSTimeInterval {
        return NSDate().timeIntervalSince1970 * 1000
    }
    
    
    var userIsTypingRef = FIRDatabaseReference() // 1
    private var localTyping = false // 2
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            // 3
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = receiver.name
        
        self.tabBarController?.tabBar.hidden = true
        
     
        
       // let chatMembers = [Controller.sharedInstance.loggedUser,user]
        //DataBaseController.sharedInstance.addChat(chat)
        //chat.chatID = Controller.sharedInstance.chatIDByMembers(chatMembers)

        setupBubbles()
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        messageRef = rootRef.child("chats").child(chat.chatID).child("messages")//rootRef.child("messages")
        
        observeTyping()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        observeMessages()
        
          
        finishReceivingMessage()
        
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        
        
        print(message.senderId + " igual " + Controller.sharedInstance.loggedUser.identification)
        if message.senderId == Controller.sharedInstance.loggedUser.identification { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!,
                                     senderDisplayName: String!, date: NSDate!) {
        
        let messageModel = Message(senderID: Controller.sharedInstance.loggedUser.identification, text: text, timestamp: String(Timestamp))
        DataBaseController.sharedInstance.addMessageInChat(chat.chatID, message: messageModel)

        
       /* let itemRef = messageRef.childByAutoId() // 1
        let messageItem = [ // 2
            "text": text,
            "senderID": senderId
        ]
        itemRef.setValue(messageItem) // 3*/
        
        // 4
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        // 5
        finishSendingMessage()
    }
    
    override func collectionView(collectionView: UICollectionView,
                                 cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
            as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == Controller.sharedInstance.loggedUser.identification {
            cell.textView!.textColor = UIColor.whiteColor()
            
        } else {
            cell.textView!.textColor = UIColor.blackColor()
        }
        
        return cell
    }
    
    
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    
    private func observeMessages() {
        // 1
        let messagesQuery = messageRef.queryLimitedToLast(25)
        // 2
        messagesQuery.observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot!) in
            // 3
            let id = snapshot.value!["senderID"] as! String
            let text = snapshot.value!["text"] as! String
            
            // 4
            self.addMessage(id, text: text)
            
            // 5
            self.finishReceivingMessage()
        }
    }
    
    
    func addMessage(id: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: "", text: text)
      
     
        messages.append(message)
    }
    
    
    private func observeTyping() {
        let typingIndicatorRef = rootRef.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        
        
        // 1
        usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqualToValue(true)
        
        // 2
        usersTypingQuery.observeEventType(.Value) { (data: FIRDataSnapshot!) in
            
            // 3 You're the only typing, don't show the indicator
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            
            // 4 Are there others typing?
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottomAnimated(true)
        }
        
    }
    
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        isTyping = textView.text != ""
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
        print("get file")
    }
    
    @IBAction func logout(sender: AnyObject) {
        try! FIRAuth.auth()!.signOut()
    }

    
}