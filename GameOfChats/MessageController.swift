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
  
  var cellId = "cellId"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // MARK: - создаем кнопку на NavigationController слева
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    
    // MARK: - создаем кнопку на NavigationController справа
    let image = UIImage(named: "message")
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
    
    checkIfUserLoggedIn()
    
    tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
    
    // observeMessages()
    
    tableView.allowsMultipleSelectionDuringEditing = true
    
  }
  
  // позволяем редактировать столбцы
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
    
    let message = messages[indexPath.row]
    if let chatPartnerId = message.chatPartnerId() {
      FIRDatabase.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
        
        if error != nil {
          //print(error ?? "Failed to delete message")
          return
        }
        
        // правильное удаление из словаря сообщений
        self.messagesDictionary.removeValue(forKey: chatPartnerId)
        self.atempReloadOfTable()
        
        //        // не безопасное удаление удаляет не из правильного места, на самом деле сообщения не в массиве, а в словаре
        //        self.messages.remove(at: indexPath.row)
        //        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        
      })
    }
    
  }
  
  var messages = [Message]()
  var messagesDictionary = [String : Message]()
  
  func observeUserMessages() {
    
    guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
    
    let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
    ref.observe(.value, with: { (snapshot) in
      
      let userId = snapshot.key
      FIRDatabase.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
        
        // print(snapshot)
        
        let messageId = snapshot.key
        self.fetchMessageWithMessageId(messageId: messageId)
        
      }, withCancel: nil)
      
    }, withCancel: nil)
    
    ref.observe(.childRemoved, with: { (snapshot) in
      
      // удаляет сообщение из приложение если напрямую из firebase было удалено
      self.messagesDictionary.removeValue(forKey: snapshot.key)
      self.atempReloadOfTable()
      
    }, withCancel: nil)
    
  }
  
  private func fetchMessageWithMessageId(messageId: String) {
    let messageReference = FIRDatabase.database().reference().child("messages").child(messageId)
    messageReference.observe(.value, with: { (snapshot) in
      //print(snapshot)
      
      if let dictionary = snapshot.value as? [String : AnyObject] {
        let message = Message(dictionary: dictionary)
        
        if let chatPartnerId = message.chatPartnerId() {
          self.messagesDictionary[chatPartnerId] = message
        }
        
        self.atempReloadOfTable()
      }
      
    }, withCancel: nil )
  }
  
  private func atempReloadOfTable() {
    // сбрасываем таймер, для того, чтобы таблица обновлялась только раз
    self.timer?.invalidate()
    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
  }
  
  var timer : Timer?
  
  // функция обработчика таймера, для обновления таблицы
  func handleReloadTable() {
    self.messages = Array(self.messagesDictionary.values)
    self.messages.sort(by: { (mes1, mes2) -> Bool in
      return (mes1.timeStamp?.intValue)! > (mes2.timeStamp?.intValue)!
    })
    
    // чтобы приложение не упало, в фоновом потоке делаем асинхронно
    DispatchQueue.main.async {
      self.tableView.reloadData()
    }
    
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }
  
  // переопределяем высоту ячейки
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 72
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let message = messages[indexPath.row]
    
    guard let chatPartnerId = message.chatPartnerId() else { return }
    
    let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
    ref.observe(.value, with: { (snapshot) in
      guard let dictionary = snapshot.value as? [String:AnyObject] else { return }
      
      let user = User()
      user.id = chatPartnerId
      user.setValuesForKeys(dictionary)
      self.showChatControllerForUser(user: user)
    }, withCancel: nil)
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
    let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
    let message = messages[indexPath.row]
    cell.message = message
    return cell
  }
  
  func handleNewMessage() {
    let newMessageController = NewMessageController()
    newMessageController.messageController = self
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
    
    guard let uid = FIRAuth.auth()?.currentUser?.uid else { return } // если uid = nil
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
    
    messages.removeAll()
    messagesDictionary.removeAll()
    tableView.reloadData()
    
    observeUserMessages()
    
    let titleView = UIView()
    titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)

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
    
    //    titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
    
  }
  
  // обработчик нажатия на NavBarWithUser для открытия диалога
  func showChatControllerForUser(user: User) {
    
    // по нажатию открывается диалог
    let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout()) // для CollectionViewController
    chatLogController.user = user
    navigationController?.pushViewController(chatLogController, animated: true)
    
  }
  
  // каждый раз по нажатию кнопки Logout будем переходить на LoginController view для регистрации и/или входа
  func handleLogout() {
    
    do {
      try FIRAuth.auth()?.signOut() // проверяем вышшел ли пользователь
    } catch let logoutError{
      //print(logoutError)
    }
    
    let loginController = LoginController()
    loginController.messageController = self
    present(loginController, animated: true, completion: nil)
  }
  
}
