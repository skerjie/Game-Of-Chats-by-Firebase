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
  
  
  func chatPartnerId() -> String? {
    if fromId == FIRAuth.auth()?.currentUser?.uid {
      return toId
    } else {
      return fromId 
    }
  }
}
