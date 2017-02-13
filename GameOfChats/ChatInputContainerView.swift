//
//  ChatInputContainerView.swift
//  GameOfChats
//
//  Created by Andrei Palonski on 13.02.17.
//  Copyright © 2017 Andrei Palonski. All rights reserved.
//

import UIKit

class ChatInputContainerView : UIView, UITextFieldDelegate {
  
  var chatLogController : ChatLogController? {
    didSet {
      
      //sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
      // uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
      sendButton.addTarget(chatLogController, action: #selector(ChatLogController.handleSend), for: .touchUpInside)
      uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(ChatLogController.handleUploadTap)))
      
    }
  }
  
  // создаем TextField чтобы получить доступ к нему для методов
  lazy var inputTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "Enter message..."
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.delegate = self
    return textField
  }()
  
  let uploadImageView : UIImageView = {
    let uploadImageView = UIImageView()
    uploadImageView.image = UIImage(named: "addImage")
    uploadImageView.isUserInteractionEnabled = true
    uploadImageView.translatesAutoresizingMaskIntoConstraints = false
    return uploadImageView
  } ()
  
  let sendButton = UIButton(type: .system)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = UIColor.white
    
    addSubview(uploadImageView)
    
    // нужны ширина, высота, x, y constraints
    uploadImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
    uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
    
    sendButton.setTitle("Send", for: .normal)
    sendButton.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(sendButton)
    
    // нужны ширина, высота, x, y constraints
    sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
    sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    
    addSubview(self.inputTextField)
    
    // нужны ширина, высота, x, y constraints
    self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
    self.inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
    self.inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    
    let separatorLineView = UIView()
    separatorLineView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    separatorLineView.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(separatorLineView)
    
    // нужны ширина, высота, x, y constraints
    separatorLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    separatorLineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    separatorLineView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.inputTextField.resignFirstResponder() // кнопкой return  клавиатуры можно ее отпустить
    chatLogController?.handleSend()
    return true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
