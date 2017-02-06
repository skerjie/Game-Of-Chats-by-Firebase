//
//  ChatLogController.swift
//  GameOfChats
//
//  Created by Andrei Palonski on 27.01.17.
//  Copyright © 2017 Andrei Palonski. All rights reserved.
//

import UIKit
import Firebase

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
        let message = Message()
        message.setValuesForKeys(dictionary)
        
//        // проверка чтобы текст сообщения был виден только от тех и только тому кому отправил
//        if message.chatPartnerId() == self.user?.id {
//         
//        }
        self.messages.append(message)
        // чтобы не упало приложение и работало в 2х патоках
        DispatchQueue.main.async {
          self.collectionView?.reloadData()
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
    
    collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom:  8, right: 0) // отступ для 1го пузырька с сообщением от верхнего края
    //collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0) // отступ для скрола
    collectionView?.alwaysBounceVertical = true // позволяем работать прокрутке
    collectionView?.backgroundColor = UIColor.white
    collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
    collectionView?.keyboardDismissMode = .interactive
//    setupInputComponents()
 //   setupKeyboardObservers()
    
  }
  
  lazy var inputContainerView: UIView = {
    let containerView = UIView()
    containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
    containerView.backgroundColor = UIColor.white
    

    let uploadImageView = UIImageView()
    uploadImageView.image = UIImage(named: "addImage")
    uploadImageView.isUserInteractionEnabled = true
    uploadImageView.translatesAutoresizingMaskIntoConstraints = false
    uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
    containerView.addSubview(uploadImageView)
    
    // нужны ширина, высота, x, y constraints
    uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
    uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
    uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true

    
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
    
    containerView.addSubview(self.inputTextField)
    
    // нужны ширина, высота, x, y constraints
    self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
    self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
    self.inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
    
    
    let separatorLineView = UIView()
    separatorLineView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    separatorLineView.translatesAutoresizingMaskIntoConstraints = false
    
    containerView.addSubview(separatorLineView)
    
    // нужны ширина, высота, x, y constraints
    separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
    separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
    separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
    separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
 
    
    return containerView
  }()
  
  // обработка нажатия на картинку с вызовом pickerController
  func handleUploadTap() {
    let imagePicker = UIImagePickerController()
    imagePicker.allowsEditing = true
    imagePicker.delegate = self
    present(imagePicker, animated: true, completion: nil)
  }
  
  // метод делегата UIImagePickerControllerDelegate
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
  
  // метод делегата UIImagePickerControllerDelegate выбираем картинку
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    var selectedImageFromPicker : UIImage?
    
    if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
      selectedImageFromPicker = editedImage
    } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      selectedImageFromPicker = originalImage
    }
    
    if let selectedImage = selectedImageFromPicker {
    uploadToFirebaseStorageUsingImage(image: selectedImage)    }
    
    dismiss(animated: true, completion: nil)
    
  }
  
  // загрузка картинок в Firebase storage из поля чата
  private func uploadToFirebaseStorageUsingImage(image: UIImage) {
    let imageName = NSUUID().uuidString
    let ref = FIRStorage.storage().reference().child("message_images").child(imageName)
    if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
      ref.put(uploadData, metadata: nil, completion: { (metadata, error) in
        
        if error != nil {
          print("Failed Upload \(error)")
          return
        }
        
        if let imageUrl = metadata?.downloadURL()?.absoluteString {
          self.sendMessageWithImageUrl(imageUrl: imageUrl)
        }
        
      })
    }
  }
  
  private func sendMessageWithImageUrl(imageUrl : String) {
    let ref = FIRDatabase.database().reference().child("messages")
    let childRef = ref.childByAutoId() // уникальное имя
    let fromId = FIRAuth.auth()!.currentUser!.uid
    let toId = user!.id!
    let timeStamp = Int(Date().timeIntervalSince1970)
    let values = ["imageUrl" : imageUrl, "toId" : toId, "fromId" : fromId, "timestamp" : timeStamp] as [String : Any]
    // childRef.updateChildValues(values)
    
    childRef.updateChildValues(values) { (error, ref) in
      
      if error != nil {
        print(error ?? "Error. Can't connect to Firebase database")
        return
      }
      
      self.inputTextField.text = nil
      
      let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId).child(toId)
      let messageId = childRef.key
      userMessagesRef.updateChildValues([messageId:1])
      let recipientUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(toId).child(fromId)
      recipientUserMessagesRef.updateChildValues([messageId:1])
      
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
  
  //
  func setupKeyboardObservers() {
    NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
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
    let message = messages[indexPath.item]
    cell.textview.text = message.text
    
    setupCell(cell: cell, message: message)
    
    if let text = message.text {
      cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
    }
    
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
    if let text = messages[indexPath.item].text {
      height = estimateFrameForText(text: text).height + 20
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
  
  // Настройка площадки для ввода текста сообщения внизу вью
//  func setupInputComponents() {
//    
//    let containerView = UIView()
//    containerView.backgroundColor = UIColor.white 
//    containerView.translatesAutoresizingMaskIntoConstraints = false
//    
//    view.addSubview(containerView)
//    
//    // нужны ширина, высота, x, y constraints
//    containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//    containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//    containerViewBottomAnchor?.isActive = true
//    containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
//    containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
//    
//    let sendButton = UIButton(type: .system)
//    sendButton.setTitle("Send", for: .normal)
//    sendButton.translatesAutoresizingMaskIntoConstraints = false
//    sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
//    
//    containerView.addSubview(sendButton)
//    
//    // нужны ширина, высота, x, y constraints
//    sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
//    sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//    sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
//    sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
////    
////    
////    let inputTextField = UITextField()
////    inputTextField.placeholder = "Enter message..."
////    inputTextField.translatesAutoresizingMaskIntoConstraints = false
//    
//    containerView.addSubview(inputTextField)
//    
//    // нужны ширина, высота, x, y constraints
//    inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
//    inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//    inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
//    inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
//    
//    
//    let separatorLineView = UIView()
//    separatorLineView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
//    separatorLineView.translatesAutoresizingMaskIntoConstraints = false
//    
//    containerView.addSubview(separatorLineView) // возможно вместо containerView должно быть view
//    
//    // нужны ширина, высота, x, y constraints
//    separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
//    separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
//    separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
//    separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
//    
//  }
  
  
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
      
      let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId).child(toId)
      let messageId = childRef.key
      userMessagesRef.updateChildValues([messageId:1])
      let recipientUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(toId).child(fromId)
      recipientUserMessagesRef.updateChildValues([messageId:1])
      
    }
    
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    inputTextField.resignFirstResponder() // кнопкой return  клавиатуры можно ее отпустить
    handleSend()
    return true
  }
  
}
