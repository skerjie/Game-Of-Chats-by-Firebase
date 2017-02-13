//
//  Message.swift
//  GameOfChats
//
//  Created by Andrei Palonski on 30.01.17.
//  Copyright © 2017 Andrei Palonski. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
  
  var fromId : String?
  var toId : String?
  var timeStamp : NSNumber?
  var text : String?
  var imageUrl : String?
  var imageWidth : NSNumber?
  var imageHeight : NSNumber?
  var videoUrl: String?
  
  
  func chatPartnerId() -> String? {
    if fromId == FIRAuth.auth()?.currentUser?.uid {
      return toId
    } else {
      return fromId 
    }
  }
  
  init(dictionary : [String:AnyObject]) {
    super.init()
    fromId = dictionary["fromId"] as? String
    toId = dictionary["toId"] as? String
    timeStamp = dictionary["timeStamp"] as? NSNumber
    text = dictionary["text"] as? String
    imageUrl = dictionary["imageUrl"] as? String
    imageWidth = dictionary["imageWidth"] as? NSNumber
    imageHeight = dictionary["imageHeight"] as? NSNumber
    videoUrl = dictionary["videoUrl"] as? String
  }
}
