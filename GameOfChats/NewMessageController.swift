//
//  NewMessageController.swift
//  GameOfChats
//
//  Created by Andrei Palonski on 22.01.17.
//  Copyright © 2017 Andrei Palonski. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
  
  let cellId = "cellId"
  var users = [User]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    
    tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
    
    fetchUser()
    
  }
  
  func fetchUser() {
    
    FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
      
      if let dictionary = snapshot.value as? [String:AnyObject] {
        let user = User()
        user.id = snapshot.key
        user.setValuesForKeys(dictionary)
        self.users.append(user)
        
        DispatchQueue.main.async {
          self.tableView.reloadData()  // чтобы не упало приложение запускаем в параллельном потоке
        }
      }
      
    }, withCancel: nil)
  }
  
  func handleCancel() {
    dismiss(animated: true, completion: nil)
  }
  
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
    let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell // кастим, чтобы cell получил доступ к profileImageView
    let user = users[indexPath.row]
    cell.textLabel?.text = user.name
    cell.detailTextLabel?.text = user.email
    
    // скачиваем и устанавливаем изображение профиля юзера в ячейку
    if let profileUserUrl = user.profileImageUrl {
      
      cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileUserUrl)
      
    }
    
    return cell
  }
  
  // переопределяем высоту ячейки
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 72
  }
  
  var messageController : MessageController?
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    dismiss(animated: true) {
      //print("Dismiss complete")
      let user = self.users[indexPath.row]
      self.messageController?.showChatControllerForUser(user: user)
      
    }
    
  }
  
}
