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
    
    // MARK: - создаем кнопку на NavigationController справа
    let image = UIImage(named: "message")
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
    
    checkIfUserLoggedIn()
    
  }
  
  func handleNewMessage() {
    let newMessageController = NewMessageController()
    let navController = UINavigationController(rootViewController: newMessageController)
    present(navController, animated: true, completion: nil)
    
  }
  
  func checkIfUserLoggedIn() {
    // пользователь не залогинился
    if FIRAuth.auth()?.currentUser?.uid == nil {
      perform(#selector(handleLogout), with: nil, afterDelay: 0)
    } else {
      fetchUserAndSetupNavBarTitle()
    }
  }
  
  
  func fetchUserAndSetupNavBarTitle() {
    
    guard let uid = FIRAuth.auth()?.currentUser?.uid else {
      // если uid = nil
      return
    }
    FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
      
      if let dict = snapshot.value as? [String:AnyObject] {
       // self.navigationItem.title = dict["name"] as? String
        
        let user = User()
        user.setValuesForKeys(dict)
        self.setupNavBarWithUser(user: user)
        
      }
      
    }, withCancel: nil)
  }
  
  // настраиваем NavBarWithUser с картинкой и именем
  func setupNavBarWithUser(user: User) {
    //self.navigationItem.title = user.name
    let titleView = UIView()
    titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
    //titleView.backgroundColor = UIColor.red
    
    
    let containerVIew = UIView()
    containerVIew.translatesAutoresizingMaskIntoConstraints = false
    titleView.addSubview(containerVIew)
    
    let profileImageView = UIImageView()
    profileImageView.translatesAutoresizingMaskIntoConstraints = false
    profileImageView.contentMode = .scaleAspectFill
    profileImageView.layer.cornerRadius = 20
    profileImageView.clipsToBounds = true
    if let profileImageUrl = user.profileImageUrl {
      profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
    }
    
    containerVIew.addSubview(profileImageView)
    
    // нужны ширина, высота, x, y constraints
    profileImageView.leftAnchor.constraint(equalTo: containerVIew.leftAnchor).isActive = true
    profileImageView.centerYAnchor.constraint(equalTo: containerVIew.centerYAnchor).isActive = true
    profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
    profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    
    let nameLabel = UILabel()
    containerVIew.addSubview(nameLabel)
    nameLabel.text = user.name
    nameLabel.translatesAutoresizingMaskIntoConstraints = false
    
    // нужны ширина, высота, x, y constraints
    nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
    nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
    nameLabel.rightAnchor.constraint(equalTo: containerVIew.rightAnchor).isActive = true
    nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
    
    containerVIew.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
    containerVIew.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
    
    
    self.navigationItem.titleView = titleView
    
  }
  
  // каждый раз по нажатию кнопки Logout будем переходить на LoginController view для регистрации и/или входа
  func handleLogout() {
    
    do {
      try FIRAuth.auth()?.signOut() // проверяем вышшел ли пользователь
    } catch let logoutError{
      print(logoutError)
    }
    
    let loginController = LoginController()
    loginController.messageController = self
    present(loginController, animated: true, completion: nil)
  }

}

