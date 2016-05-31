//
//  User.swift
//  Hello Chat
//
//  Created by Giovanne Dias on 5/20/16.
//  Copyright © 2016 GED App. All rights reserved.
//

import Foundation

class User {
    
    var name = String()
    var identification = String()
    var email = String()
    var imageURL = NSURL()
    
    var image = UIImageView()
    
    init(){
        
        
    }
    init(model: NSDictionary!){
        
        self.name = model.valueForKeyPath("name") as! String
        self.identification =  model.valueForKeyPath("id") as!  String
        let stringURL =  model.valueForKeyPath("photoURL") as!  String
        self.imageURL = NSURL(string:stringURL)!
      
        

    }
    
    func downloadProfileImage() {
        
        self.image.downloadedFrom(link: String(self.imageURL), contentMode: .ScaleAspectFit)
    }
    
    func toJSON() -> NSDictionary {
        
        return ["id" : self.identification,
                "name" : self.name,
                "photoURL" : String(self.imageURL)]
    }

}
