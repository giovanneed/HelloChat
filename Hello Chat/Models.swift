//
//  Models.swift
//  Hello Chat
//
//  Created by Giovanne Dias on 5/21/16.
//  Copyright © 2016 GED App. All rights reserved.
//

import Foundation


class Message {
    
    var senderID = String()
    var text = String()
    var timestamp = String()
    
    init(){
        
    }
    
    
    init(senderID: String, text: String, timestamp : String){
        
        self.senderID = senderID
        self.text = text
        self.timestamp = timestamp        
    }
    
    func toJSON() -> NSDictionary {
        let item = [
            "senderID": senderID,
            "text": text,
            "timestamp" : timestamp
        ]
        
        return item
    }
}



class Chat {
    
    var chatID = String()
    
    //didnt have time to implemnt groups :(
    var member1 = User()
    var member2 = User()
    
    var members = [User]()
    var messages = [Message]()
    
    var lastMessage = ""
    
    init(){
        
    }
    
    init(model: NSDictionary){
        
        print(model)
        print(model.valueForKey("user1"))
        
       self.member1.name = (model.valueForKey("user1")?.valueForKey("name"))! as! String
       self.member1.identification = (model.valueForKey("user1")?.valueForKey("id"))! as! String
       self.member1.imageURL = NSURL(string: (model.valueForKey("user1")?.valueForKey("photoURL"))! as! String)!

        self.member2.name = (model.valueForKey("user2")?.valueForKey("name"))! as! String
        self.member2.identification = (model.valueForKey("user2")?.valueForKey("id"))! as! String
        self.member2.imageURL = NSURL(string: (model.valueForKey("user2")?.valueForKey("photoURL"))! as! String)!
        self.member2.downloadProfileImage()

      
        if let dic = model.valueForKey("messages") {
            if dic.isKindOfClass(NSDictionary) {
                print(dic)
                let last  = dic.allValues.last
                if last != nil {
                    self.lastMessage = last?.valueForKey("text") as! String
                    
                }

            }
           
        }
        
        
        
              
        // self.member1 = User(model:model.valueForKey("user1")! as! NSDictionary)
        // self.member2 = User(model:model.valueForKey("user2") as! NSDictionary)

    }
    
    func receiver(loggedUserID: String) -> User {
        
        if self.member1.identification == loggedUserID {
            return member2
        }
        
        return member1
    }
    /*
    init(identification: String, model: NSDictionary){
        
        
        for userID in model.valueForKey("Users") as! Array<String> {
            let user = User()
            user.identification = userID
            self.members.append(user)
            
            DataBaseController.sharedInstance.userBy(user.identification, completionHandler: { (error, userFounded) in
                if error == false {
                    self.members.append(userFounded!)
                }
            })
        }
        
        self.chatID = identification
    }
    func updateMember() {
        
        for user in self.members {
            DataBaseController.sharedInstance.userBy(user.identification, completionHandler: { (error, userFounded) in
                if error == false {
                    user.name = userFounded!.name
                    
                }
            })
        }

        
    }
    func chatTitleWithoutLoggedUserName() -> String {
        
        var names = ""
        
        for user in self.members {
            
            if let _ = self.members.indexOf({$0.identification != Controller.sharedInstance.loggedUser.identification}) {
                names = names + " " + user.name
                
                
            }

        }
        return names
    }
    
    func userWithoutLoggedUserName() -> User? {
        
        
        for user in self.members {
            
            if let _ = self.members.indexOf({$0.identification != Controller.sharedInstance.loggedUser.identification}) {
              return user
                
                
            }
            
        }
        
        return nil
    }*/


}