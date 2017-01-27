//
//  ChatLogController.swift
//  GameOfChats
//
//  Created by Andrei Palonski on 27.01.17.
//  Copyright © 2017 Andrei Palonski. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController : UICollectionViewController, UITextFieldDelegate {
  
  
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
    
    navigationItem.title = "ChatLoginController"
    collectionView?.backgroundColor = UIColor.white
    setupInputComponents()
    
  }
  
  // Настройка площадки для ввода текста сообщения внизу вью
  func setupInputComponents() {
    
    let containerView = UIView()
    //containerView.backgroundColor = UIColor.red
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
    let values = ["text" : inputTextField.text!]
    childRef.updateChildValues(values)
    
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    inputTextField.resignFirstResponder() // кнопкой return  клавиатуры можно ее отпустить
    handleSend()
    return true
  }
  
}
