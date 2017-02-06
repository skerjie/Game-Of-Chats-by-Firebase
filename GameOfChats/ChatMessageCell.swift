 //
 //  ChatMessageCell.swift
 //  GameOfChats
 //
 //  Created by Andrei Palonski on 02.02.17.
 //  Copyright © 2017 Andrei Palonski. All rights reserved.
 //
 
 import UIKit
 
 class ChatMessageCell: UICollectionViewCell {
  
  let textview : UITextView = {
    
    let tv = UITextView()
    tv.font = UIFont.systemFont(ofSize: 16)
    tv.text = "Text just some text"
    tv.backgroundColor = UIColor.clear
    tv.textColor = UIColor.white
    tv.translatesAutoresizingMaskIntoConstraints = false
    return tv
    
  }()
  
  static let blueColor = UIColor(colorLiteralRed: 0, green: 137, blue: 249, alpha: 1)
  
  let bubbleView : UIView = {
    let buble = UIView()
    buble.backgroundColor = ChatMessageCell.blueColor
    buble.layer.cornerRadius = 16
    buble.layer.masksToBounds = true
    buble.translatesAutoresizingMaskIntoConstraints = false
    return buble
  }()
  
  let profileImageView : UIImageView = {
    let imageView = UIImageView()
    //imageView.image = UIImage(named: "message")
    imageView.layer.cornerRadius = 16
    imageView.layer.masksToBounds = true
    imageView.contentMode = .scaleAspectFill
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  let messageImageView : UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 16
    imageView.layer.masksToBounds = true
    imageView.contentMode = .scaleAspectFill 
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  var bubbleWidthAnchor : NSLayoutConstraint?
  var bubbleViewRightAnchor : NSLayoutConstraint?
  var bubbleViewLeftAnchor : NSLayoutConstraint?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    //backgroundColor = UIColor.red
    
    addSubview(bubbleView)
    addSubview(textview)
    addSubview(profileImageView)
    
    bubbleView.addSubview(messageImageView)
    // нужны ширина, высота, x, y constraints
    messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
    messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
    messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
    messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
    
    
    // нужны ширина, высота, x, y constraints
    //textview.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    textview.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
    textview.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    //textview.widthAnchor.constraint(equalToConstant: 200).isActive = true
    textview.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
    textview.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    
    // нужны ширина, высота, x, y constraints
    //bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    // делаем пузырек слева или справа, в завсисмости от того кто отправлял сообщение
    bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
    bubbleViewRightAnchor?.isActive = true
    bubbleViewLeftAnchor = bubbleView.rightAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
    //bubbleViewLeftAnchor?.isActive = false
    
    bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
    bubbleWidthAnchor?.isActive = true
    bubbleView .heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    
    // нужны ширина, высота, x, y constraints
    profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
    profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
    profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
    
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
 }
