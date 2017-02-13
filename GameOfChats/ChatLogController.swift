//
//  ChatLogController.swift
//  GameOfChats
//
//  Created by Andrei Palonski on 27.01.17.
//  Copyright © 2017 Andrei Palonski. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogController : UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
  
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
    guard let uid = FIRAuth.auth()?.currentUser?.uid, let toId = user?.id else { return }
    
    let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid).child(toId)
    userMessagesRef.observe(.childAdded, with: { (snapshot) in
      let messageId = snapshot.key
      let messagesRef = FIRDatabase.database().reference().child("messages").child(messageId)
      messagesRef.observe(.value, with: { (snapshot) in
        
        guard let dictionary = snapshot.value as? [String:AnyObject] else { return }
        
        self.messages.append(Message(dictionary: dictionary))
        // чтобы не упало приложение и работало в 2х патоках
        DispatchQueue.main.async {
          self.collectionView?.reloadData()
          let indexPath = NSIndexPath(item: self.messages.count - 1, section: 0)
          self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true) // автоматическая прокрутка вверх при вводе нового сообщения
        }
      }, withCancel: nil)
    }, withCancel: nil )
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // navigationItem.title = "ChatLoginController"
    
    collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom:  8, right: 0) // отступ для 1го пузырька с сообщением от верхнего края
    //collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0) // отступ для скрола
    collectionView?.alwaysBounceVertical = true // позволяем работать прокрутке
    collectionView?.backgroundColor = UIColor.white
    collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
    collectionView?.keyboardDismissMode = .interactive
    
    setupKeyboardObservers()
    
  }
  
  lazy var inputContainerView: ChatInputContainerView = {
    
    let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
    chatInputContainerView.chatLogController = self
    return chatInputContainerView
    
  }()
  
  // обработка нажатия на картинку с вызовом pickerController
  func handleUploadTap() {
    let imagePicker = UIImagePickerController()
    imagePicker.allowsEditing = true
    imagePicker.delegate = self
    imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
    present(imagePicker, animated: true, completion: nil)
  }
  
  // метод делегата UIImagePickerControllerDelegate
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
  
  // метод делегата UIImagePickerControllerDelegate выбираем картинку
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
      
      // выбираем видео
      handleVideoSelectedForUrl(url: videoUrl)
      
    } else {
      
      // выбираем картинку
      handleImageSelectedForInfo(info: info as [String : AnyObject])
    }
    
    dismiss(animated: true, completion: nil)
    
  }
  
  private func handleVideoSelectedForUrl(url : URL) {
    let fileName = NSUUID().uuidString + ".mov"
    let uploadTask = FIRStorage.storage().reference().child("message_movies").child(fileName).putFile(url, metadata: nil, completion: { (metadata, error) in
      
      if error != nil {
        // print(error ?? "Error")
        return
      }
      
      if let videoUrl = metadata?.downloadURL()?.absoluteString {
        //print(videoUrl)
        //
        if let thumbnailImage = self.thumbnailImageForFileUrl(fileUrl: url) {
          
          self.uploadToFirebaseStorageUsingImage(image: thumbnailImage, completion: { (imageUrl) in
            
            let properties = ["imageUrl": imageUrl as AnyObject, "imageWidth": thumbnailImage.size.width as AnyObject, "imageHeight": thumbnailImage.size.height as AnyObject, "videoUrl" : videoUrl] as [String : Any]
            self.sendMessageWithProperties(properties: properties as [String : AnyObject])
            
          })
        }
      }
    })
    
    uploadTask.observe(.progress) { (snapshot) in
      // показываем вместо тайтла имени пользователя процесс в байтах загрузки видео на сервер
      if let completedUnitCount = snapshot.progress?.completedUnitCount {
        self.navigationItem.title = String(completedUnitCount)
      }
    }
    
    // показываем по завершению загрузки видео на сервер обратно имя пользователя в тайтле
    uploadTask.observe(.success) { (snapshot) in
      self.navigationItem.title = self.user?.name
    }
    
  }
  
  // делает картинку thumbnailImage видео
  private func thumbnailImageForFileUrl(fileUrl : URL) -> UIImage? {
    let asset = AVAsset(url: fileUrl)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    
    do {
      let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
      return UIImage(cgImage: thumbnailCGImage)
    } catch let err {
      //print(err)
    }
    
    return nil
  }
  
  private func handleImageSelectedForInfo(info : [String: AnyObject]) {
    var selectedImageFromPicker : UIImage?
    
    if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
      selectedImageFromPicker = editedImage
    } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      selectedImageFromPicker = originalImage
    }
    
    if let selectedImage = selectedImageFromPicker {
      uploadToFirebaseStorageUsingImage(image: selectedImage, completion: { (imageUrl) in
        self.sendMessageWithImageUrl(imageUrl: imageUrl, image: selectedImage)
      })
    }
  }
  
  // загрузка картинок в Firebase storage из поля чата
  private func uploadToFirebaseStorageUsingImage(image: UIImage, completion: @escaping (_ imageUrl : String) -> ()) {
    let imageName = NSUUID().uuidString
    let ref = FIRStorage.storage().reference().child("message_images").child(imageName)
    if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
      ref.put(uploadData, metadata: nil, completion: { (metadata, error) in
        
        if error != nil {
          // print("Failed Upload \(error)")
          return
        }
        
        if let imageUrl = metadata?.downloadURL()?.absoluteString {
          completion(imageUrl)
        }
      })
    }
  }
  
  override var inputAccessoryView: UIView? {
    get {
      return inputContainerView
    }
  }
  
  override var canBecomeFirstResponder: Bool {
    get {
      return true
    }
  }
  
  
  func setupKeyboardObservers() {
    
    NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: .UIKeyboardDidShow, object: nil)
    //    NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    //    NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
  }
  
  func handleKeyboardDidShow() {
    if messages.count > 0 {
      let indexPath = NSIndexPath(item: self.messages.count - 1, section: 0)
      collectionView?.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    NotificationCenter.default.removeObserver(self) // обязательно удаляем иначе будет утеска памяти
  }
  
  // получаем высоту клавиатуры и подвигаем область ввода текста вверх
  func handleKeyboardWillShow(notification : NSNotification) {
    let keyBoardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
    //print(keyBoardFrame?.height) получили высоту клавиатуры
    let keyBoardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue // получаем длительность по]вления клавиатуры
    
    // подвигаем область ввода текста вверх
    containerViewBottomAnchor?.constant = -keyBoardFrame!.height // подвигаем вверх на высоту клавиатуры
    UIView.animate(withDuration: keyBoardDuration!) { // анимируем появление клавиатуры
      self.view.layoutIfNeeded()
    }
  }
  
  // подвигаем область ввода текста обратно вниз
  func handleKeyboardWillHide(notification : NSNotification) {
    let keyBoardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue // получаем длительность по]вления клавиатуры
    // подвигаем область ввода текста вниз
    containerViewBottomAnchor?.constant = 0 // опускаем обратно вниз
    UIView.animate(withDuration: keyBoardDuration!) { // анимируем появление клавиатуры
      self.view.layoutIfNeeded()
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return messages.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
    
    cell.chatLogController = self // делегат
    
    let message = messages[indexPath.item]
    cell.message = message
    cell.textview.text = message.text
    
    setupCell(cell: cell, message: message)
    
    if let text = message.text {
      cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
      cell.textview.isHidden = false
    } else if message.imageUrl != nil {
      // иначе, если не текст то изображение
      cell.bubbleWidthAnchor?.constant = 200
      cell.textview.isHidden = true
    }
    // проверка если сообщение картинка кнопка проигрывания видео будет скрыта, если видео то активна
    if message.videoUrl != nil {
      cell.playVideoButton.isHidden = false
    } else {
      cell.playVideoButton.isHidden = true
    }
    
    // другая  запись
    //cell.playVideoButton.isHidden = message.videoUrl == nil
    
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
    
    // картинка на синем пузыре
    if let messageImageUrl = message.imageUrl {
      cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
      cell.messageImageView.isHidden = false
      cell.bubbleView.backgroundColor = UIColor.clear
    } else {
      cell.messageImageView.isHidden = true
    }
  }
  
  // для режима перевернутого экрана правильно рендерит сообщения к краям
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    collectionView?.collectionViewLayout.invalidateLayout()
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    var height : CGFloat = 80
    
    let message = messages[indexPath.item]
    if let text = message.text {
      height = estimateFrameForText(text: text).height + 20
    } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
      
      // h1 * w1 = h2 * w2
      // h1 = h2 / w2 * w1
      
      height = CGFloat(imageHeight / imageWidth * 200)
      
    }
    let width = UIScreen.main.bounds.width
    return CGSize(width: width, height: height)
  }
  
  // вычисляет размер пузярька для текста в зависимости от текста
  private func estimateFrameForText(text: String) -> CGRect {
    let size = CGSize(width: 200, height: 1000)
    let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
    return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 16)], context: nil)
  }
  
  var containerViewBottomAnchor : NSLayoutConstraint?
  
  // обработка нажатия кнопки Send
  func handleSend() {
    let properties = ["text": inputContainerView.inputTextField.text!]
    sendMessageWithProperties(properties: properties as [String : AnyObject])
  }
  
  private func sendMessageWithImageUrl(imageUrl: String, image: UIImage) {
    let properties = ["imageUrl": imageUrl as AnyObject, "imageWidth": image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject]
    sendMessageWithProperties(properties: properties)
  }
  
  private func sendMessageWithProperties(properties: [String: AnyObject]) {
    let ref = FIRDatabase.database().reference().child("messages")
    let childRef = ref.childByAutoId() // уникальное имя
    let toId = user!.id!
    let fromId = FIRAuth.auth()!.currentUser!.uid
    let timestamp = Int(Date().timeIntervalSince1970)
    
    var values = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "timestamp": timestamp] as [String : Any]
    
    //key $0, value $1
    properties.forEach({values[$0] = $1})
    
    childRef.updateChildValues(values) { (error, ref) in
      if error != nil {
        // print(error ?? "Error")
        return
      }
      
      self.inputContainerView.inputTextField.text = nil
      
      let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId).child(toId)
      
      let messageId = childRef.key
      userMessagesRef.updateChildValues([messageId: 1])
      
      let recipientUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(toId).child(fromId)
      recipientUserMessagesRef.updateChildValues([messageId: 1])
    }
  }
  
  var startFrame : CGRect?
  var blackBackgroundView : UIView?
  var startingImageView : UIImageView?
  
  // zoom изображения
  func performZoomInForStartingImageView(startingImageView: UIImageView) {
    startFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
    
    self.startingImageView = startingImageView
    self.startingImageView?.isHidden = true
    
    let zoomingImageView = UIImageView(frame: startFrame!)
    zoomingImageView.backgroundColor = UIColor.red
    zoomingImageView.image = startingImageView.image
    zoomingImageView.isUserInteractionEnabled = true
    zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
    
    if let keyWindow = UIApplication.shared.keyWindow {
      
      blackBackgroundView = UIView(frame: keyWindow.frame)
      blackBackgroundView?.backgroundColor = UIColor.black
      blackBackgroundView?.alpha = 0
      keyWindow.addSubview(blackBackgroundView!)
      keyWindow.addSubview(zoomingImageView)
      
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
        // h2 / w2 = h1 / w1
        // h2 = h1 / w1 * w2
        
        self.blackBackgroundView?.alpha = 1
        self.inputContainerView.alpha = 0
        
        let height = self.startFrame!.height / self.startFrame!.width * keyWindow.frame.width
        zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
      }, completion: nil)
    }
  }
  
  func handleZoomOut(tapGesture : UITapGestureRecognizer) {
    if let zoomoutImageView = tapGesture.view {
      
      zoomoutImageView.layer.cornerRadius = 16
      zoomoutImageView.clipsToBounds = true
      
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
        
        zoomoutImageView.frame = self.startFrame!
        self.blackBackgroundView?.alpha = 0
        self.inputContainerView.alpha = 1
        
      }, completion: { (completed: Bool) in
        zoomoutImageView.removeFromSuperview()
        self.startingImageView?.isHidden = false
      })
      
    }
  }
  
}
