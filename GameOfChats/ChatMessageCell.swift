 //
 //  ChatMessageCell.swift
 //  GameOfChats
 //
 //  Created by Andrei Palonski on 02.02.17.
 //  Copyright © 2017 Andrei Palonski. All rights reserved.
 //
 
 import UIKit
 import AVFoundation
 
 class ChatMessageCell: UICollectionViewCell {
  
  var chatLogController : ChatLogController?
  var message : Message?
  
  let activityIndicatorView : UIActivityIndicatorView = {
    
    let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    aiv.translatesAutoresizingMaskIntoConstraints = false
    aiv.hidesWhenStopped = true
    return aiv
    
  }()
  
  let playVideoButton : UIButton = {
    
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    let image = UIImage(named: "play")
    button.tintColor = UIColor.white
    button.setImage(image, for: .normal)
    button.addTarget(self, action: #selector(handlePlayVideo), for: .touchUpInside)
    return button
    
  }()
  
  var playerLayer : AVPlayerLayer?
  var player : AVPlayer?
  
  func handlePlayVideo() {
    if let videoUrlString = message?.videoUrl, let url = URL(string: videoUrlString) {
      player = AVPlayer(url: url)
      playerLayer = AVPlayerLayer(player: player)
      playerLayer?.frame = bubbleView.bounds
      bubbleView.layer.addSublayer(playerLayer!)
      player?.play()
      activityIndicatorView.startAnimating()
      playVideoButton.isHidden = true
    }
  }
  
  // когда проигрывается видео и пролистывается чат убирает playerLayer с Superlayer и убирает баги с отобажением, а также останавиливает воспроизведение видео и аудио и кручение activityIndicatorView
  override func prepareForReuse() {
    super.prepareForReuse()
    playerLayer?.removeFromSuperlayer()
    player?.pause()
    activityIndicatorView.stopAnimating()
  }
  
  let textview : UITextView = {
    
    let tv = UITextView()
    tv.font = UIFont.systemFont(ofSize: 16)
    tv.text = "Text just some text"
    tv.backgroundColor = UIColor.clear
    tv.textColor = UIColor.white
    tv.translatesAutoresizingMaskIntoConstraints = false
    tv.isEditable = false
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
    imageView.isUserInteractionEnabled = true
    
    imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
    
    return imageView
  }()
  
  // зум анимация для тапа по картинке
  func handleZoomTap(tapGesture : UITapGestureRecognizer) {
    // если это видео, то не зумим
    if message?.videoUrl != nil {
      return
    }
    
    if let imageView = tapGesture.view as? UIImageView {
      self.chatLogController?.performZoomInForStartingImageView(startingImageView: imageView) // метод делегата
    }
    
  }
  
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
    
    bubbleView.addSubview(playVideoButton)
    // нужны ширина, высота, x, y constraints
    playVideoButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
    playVideoButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
    playVideoButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
    playVideoButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    bubbleView.addSubview(activityIndicatorView)
    // нужны ширина, высота, x, y constraints
    activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
    activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
    activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
    activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
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
