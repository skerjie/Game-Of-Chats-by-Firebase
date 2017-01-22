//
//  MessageController.swift
//  GameOfChats
//
//  Created by Andrei Palonski on 20.01.17.
//  Copyright © 2017 Andrei Palonski. All rights reserved.
//

import UIKit
import Firebase

class MessageController: UITableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
        
    // MARK: - создаем кнопку на NavigationController слева
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    
    checkIfUserLoggedIn()
    
  }
  
  func checkIfUserLoggedIn() {
    // пользователь не залогинился
    if FIRAuth.auth()?.currentUser?.uid == nil {
      perform(#selector(handleLogout), with: nil, afterDelay: 0)
    } else {
      let uid = FIRAuth.auth()?.currentUser?.uid
      FIRDatabase.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let dict = snapshot.value as? [String:AnyObject] {
        self.navigationItem.title = dict["name"] as? String
        }
        
      }, withCancel: nil)
    }
  }
  
  // каждый раз по нажатию кнопки Logout будем переходить на LoginController view для регистрации и/или входа
  func handleLogout() {
    
    do {
      try FIRAuth.auth()?.signOut() // проверяем вышшел ли пользователь
    } catch let logoutError{
      print(logoutError)
    }
    
    let loginController = LoginController()
    present(loginController, animated: true, completion: nil)
  }

}

