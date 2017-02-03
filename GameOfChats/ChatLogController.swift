//
//  ChatLogController.swift
//  GameOfChats
//
//  Created by Andrei Palonski on 27.01.17.
//  Copyright © 2017 Andrei Palonski. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController : UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout  {
  
  let cellId = "cellId"
  var messages = [Message]()
  
  var user : User? {
    didSet {
      navigationItem.title = user?.name
      observeMessages()
    }
  }
  
  // функция которая получает список сообщений, то что видно на вьюхе диалог
  func observeMessages() {
    guard let uid = FIRAuth.auth()?.currentUser?.uid else {
      return
    }
    
    let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid)
    userMessagesRef.observe(.childAdded, with: { (snapshot) in
      let messageId = snapshot.key
      let messagesRef = FIRDatabase.database().reference().child("messages").child(messageId)
      messagesRef.observe(.value, with: { (snapshot) in
        
        guard let dictionary = snapshot.value as? [String:AnyObject] else {
          return
        }
        let message = Message()
        message.setValuesForKeys(dictionary)
        
        // проверка чтобы текст сообщения был виден только от тех и только тому кому отправил
        if message.chatPartnerId() == self.user?.id {
          self.messages.append(message)
          // чтобы не упало приложение и работало в 2х патоках
          DispatchQueue.main.async {
            self.collectionView?.reloadData()
          }
        }
        
      }, withCancel: nil)
      
    }, withCancel: nil )
  }
  
  // создаем TextField чтобы получить доступ к нему для методов
  lazy var inputTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "Enter message..."
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.delegate = self
    return textField
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // navigationItem.title = "ChatLoginController"
    
    collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0) // отступ для 1го пузырька с сообщением от верхнего края
    collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0) // отступ для скрола
    collectionView?.alwaysBounceVertical = true // позволяем работать прокрутке
    collectionView?.backgroundColor = UIColor.white
    collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
    setupInputComponents()
    
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return messages.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
    let message = messages[indexPath.item]
    cell.textview.text = message.text
    
    setupCell(cell: cell, message: message)
    
    cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.text!).width + 32
    
    return cell
  }
  
  // проверка входящее или исходящее сообщение, пузырек серого или синего цвета
  private func setupCell(cell: ChatMessageCell, message: Message) {
    
    if let profImageUrl =  self.user?.profileImageUrl {
      cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profImageUrl)
    }
    
    if message.fromId == FIRAuth.auth()?.currentUser?.uid {
      // исходящее синего
      cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
      cell.textview.textColor = UIColor.white
      cell.profileImageView.isHidden = true
      cell.bubbleViewRightAnchor?.isActive = false
      cell.bubbleViewLeftAnchor?.isActive = true
      
    } else {
      // входящее серого
      cell.bubbleView.backgroundColor = UIColor(red: 240, green: 240, blue: 240, alpha: 1)
      cell.textview.textColor = UIColor.black
      cell.profileImageView.isHidden = false
      cell.bubbleViewRightAnchor?.isActive = true
      cell.bubbleViewLeftAnchor?.isActive = false
    }
  }
  
  // для режима перевернутого экрана правильно рендерит сообщения к краям
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    collectionView?.collectionViewLayout.invalidateLayout()
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    var height : CGFloat = 80
    if let text = messages[indexPath.item].text {
      height = estimateFrameForText(text: text).height + 20
    }
    return CGSize(width: view.frame.width, height: height)
  }
  
  // вычисляет размер пузярька для текста в зависимости от текста
  private func estimateFrameForText(text: String) -> CGRect {
    let size = CGSize(width: 200, height: 1000)
    let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
    return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 16)], context: nil)
  }
  
  // Настройка площадки для ввода текста сообщения внизу вью
  func setupInputComponents() {
    
    let containerView = UIView()
    containerView.backgroundColor = UIColor.white 
    containerView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(containerView)
    
    // нужны ширина, высота, x, y constraints
    containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    let sendButton = UIButton(type: .system)
    sendButton.setTitle("Send", for: .normal)
    sendButton.translatesAutoresizingMaskIntoConstraints = false
    sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
    
    containerView.addSubview(sendButton)
    
    // нужны ширина, высота, x, y constraints
    sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
    sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
    sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
//    
//    
//    let inputTextField = UITextField()
//    inputTextField.placeholder = "Enter message..."
//    inputTextField.translatesAutoresizingMaskIntoConstraints = false
    
    containerView.addSubview(inputTextField)
    
    // нужны ширина, высота, x, y constraints
    inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
    inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
    inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
    
    
    let separatorLineView = UIView()
    separatorLineView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    separatorLineView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(separatorLineView)
    
    // нужны ширина, высота, x, y constraints
    separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
    separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
    separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
    separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    
  }
  
  
  // обработка нажатия кнопки Send
  func handleSend() {
    
    // создаем ноду messages
    let ref = FIRDatabase.database().reference().child("messages")
    let childRef = ref.childByAutoId() // уникальное имя
    let fromId = FIRAuth.auth()!.currentUser!.uid
    let toId = user!.id!
    let timeStamp = Int(Date().timeIntervalSince1970)
    let values = ["text" : inputTextField.text!, "toId" : toId, "fromId" : fromId, "timestamp" : timeStamp] as [String : Any]
    // childRef.updateChildValues(values)
    
    childRef.updateChildValues(values) { (error, ref) in
      
      if error != nil {
        print(error ?? "Error. Can't connect to Firebase database")
        return
      }
      
      self.inputTextField.text = nil
      
      let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId)
      let messageId = childRef.key
      userMessagesRef.updateChildValues([messageId:1])
      let recipientUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(toId)
      recipientUserMessagesRef.updateChildValues([messageId:1])
      
    }
    
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    inputTextField.resignFirstResponder() // кнопкой return  клавиатуры можно ее отпустить
    handleSend()
    return true
  }
  
}
