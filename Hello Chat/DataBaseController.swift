//
//  DataBaseController.swift
//  Hello Chat
//
//  Created by Giovanne Dias on 5/20/16.
//  Copyright © 2016 GED App. All rights reserved.
//

import Foundation




class Controller
{
    
    
    var loggedUser : User = User()
    
    class var sharedInstance: Controller {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: Controller? = nil
        }
        dispatch_once(&Static.onceToken){
            Static.instance = Controller()
        }
        return Static.instance!
    }
    
    func chatIDByMembers(receiver: User) -> String {
        var chatID = String()
        let loggedUser = Controller.sharedInstance.loggedUser
        let list  = [receiver,loggedUser]
        let sortedList = list.sort({$0.name > $1.name})
        for user in sortedList {
            chatID = chatID + "+" + user.identification
        }
        
        return chatID
    }
    
    
    func chatBelongsToMe(chat: Chat, me: User) -> Bool {
        if chat.member1.identification == me.identification {
            return true
        }
        
        if chat.member2.identification == me.identification {
            return true
        }
        
        return false
    }
    
    //group
   /* func chatIDByMembers(users : Array<User>) -> String {
        var chatID = String()
        let sortedList = users.sort({$0.name > $1.name})
        for user in sortedList {
            chatID = chatID + "+" + user.identification
        }
        
        return chatID
    }*/


}
class DataBaseController {
    
    var messageRef = FIRDatabaseReference()
    let rootRef = FIRDatabase.database().reference()
    
    
    class var sharedInstance: DataBaseController {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: DataBaseController? = nil
        }
        dispatch_once(&Static.onceToken){
            Static.instance = DataBaseController()
        }
        return Static.instance!
    }
    
    func chatBy(identification: String, completionHandler:((error: Bool?,chat: Chat?)->Void)?) -> Void {
        
        let messageRefUser = rootRef.child("chats").child(identification)
        messageRefUser.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            print(snapshot.value)
            
            if snapshot.value!.isKindOfClass(NSNull) {
                completionHandler!(error: true, chat: nil)
                
            } else {
                let modelChat = snapshot.value as! [String : AnyObject]
                print(modelChat)
                let dicChat = modelChat as NSDictionary
                print(dicChat)
                let chat = Chat(model: modelChat as NSDictionary)
                let receiver = chat.receiver(Controller.sharedInstance.loggedUser.identification)
                let chatID = Controller.sharedInstance.chatIDByMembers(receiver)
                chat.chatID = chatID
                
                print(chat.chatID)
                
                completionHandler!(error: false, chat: chat)


                //let modelUsers = snapshot.value as! [String : AnyObject]
                //let user = User(model: modelUsers)
                //completionHandler!(error: false, user: user)
            }
            
            
            
        })
        
    
        
    }

    
    
    
    func userBy(identification: String, completionHandler:((error: Bool?,user: User?)->Void)?) -> User? {
        
        let messageRefUser = rootRef.child("Users").child(identification)
        messageRefUser.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
           print(snapshot.value)
      
            if snapshot.value!.isKindOfClass(NSNull) {
                completionHandler!(error: true, user: nil)

            } else {
                let modelUsers = snapshot.value as! [String : AnyObject]
                let user = User(model: modelUsers)
                completionHandler!(error: false, user: user)
            }
            
           
           
        })

        return nil
        
    }
    
    func listUsers(completionHandler:((error: Bool?,list: Array<User>?)->Void)?) -> Void {
        
        messageRef = rootRef.child("Users")

        messageRef.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            let modelUsers = snapshot.value as! [String : AnyObject]
            
             var listOfUsers : [User] = []
            
            for model in modelUsers {
                let user = User(model:model.1 as! NSDictionary)
                print(user.identification)
                
                
                if (user.identification != Controller.sharedInstance.loggedUser.identification) {
                    listOfUsers.append(user)
                }
            }
            
            completionHandler!(error: false, list: listOfUsers)
        })
    
    }
    
    
    
    func addUser(user: User) -> Bool {
        
        messageRef = rootRef.child("Users")
        
        let itemRef = messageRef.child(user.identification)
        
        let userItem = [
            "name": user.name,
            "id": user.identification,
            "photoURL": String(user.imageURL)
        ]
        
        itemRef.setValue(userItem)
         return true
    }
    
    
    func addMessageInChat(chatID: String, message : Message) -> Bool {
        messageRef = rootRef.child("chats").child(chatID).child("messages")
        
        let itemRef = messageRef.childByAutoId()
        itemRef.setValue(message.toJSON())
        
        
        
        
        return true

    
    }
    
    
    func addChat(receiver: User) -> Bool {
        
        let chatID = Controller.sharedInstance.chatIDByMembers(receiver)
        let loggedUser = Controller.sharedInstance.loggedUser

     
        
        messageRef = rootRef.child("chats")
        
        let itemRef = messageRef.child(chatID)
        
        
        let userItem = [
            "user1": loggedUser.toJSON(),
            "user2": receiver.toJSON(),
            "messages": ""
        ]
        
        itemRef.setValue(userItem)

        
        
        return true
    }
    
    
    func listChats(completionHandler:((error: Bool?,list: Array<Chat>?)->Void)?) -> Void {
        
        messageRef = rootRef.child("AllChats")
        
        messageRef.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            let modelChats = snapshot.value as! [String : AnyObject]
            
            var listOfChats : [Chat] = []
            
            for model in modelChats {
                print(model)
               // let chat = Chat(identification: model.0, model:model.1 as! NSDictionary)
                
                
                
                //if let _ = chat.members.indexOf({$0.identification == Controller.sharedInstance.loggedUser.identification}) {
                    
                    //listOfChats.append(chat)
                    //chat.updateMember()

                //}
                
            }
            
            completionHandler!(error: false, list: listOfChats)
        })
        
    }

    
    
}






extension UIImageView {
    func downloadedFrom(link link:String, contentMode mode: UIViewContentMode) {
        guard
            let url = NSURL(string: link)
            else {return}
        contentMode = mode
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            guard
                let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
                let mimeType = response?.MIMEType where mimeType.hasPrefix("image"),
                let data = data where error == nil,
                let image = UIImage(data: data)
                else { return }
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.image = image
            }
        }).resume()
    }
}