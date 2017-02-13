//
//  LoginController.swift
//  GameOfChats
//
//  Created by Andrei Palonski on 20.01.17.
//  Copyright © 2017 Andrei Palonski. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
  
  var messageController : MessageController?
  
  // MARK: - создаем по центру view сабвью (name login password)
  let inputsContainerView : UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.white
    view.translatesAutoresizingMaskIntoConstraints = false // чтобы стали видны наши Anchors
    view.layer.cornerRadius = 5 // делаем углы закругленными
    view.layer.masksToBounds = true
    return view
  }()
  
  var inputsContainerViewHeightAnchor : NSLayoutConstraint?
  var nameTextFieldHeightAnchor : NSLayoutConstraint?
  var emailTextFieldHeightAnchor : NSLayoutConstraint?
  var passwordTextFieldHeightAnchor : NSLayoutConstraint?
  
  // MARK: - настраиваем Anchor для нашего выше созданного view
  func setupInputContainer() {
    // нужны ширина, высота, x, y constraints
    
    inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
    inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
    inputsContainerViewHeightAnchor?.isActive = true
    
    
    // добавляем наши TextFields
    inputsContainerView.addSubview(nameTextField)
    inputsContainerView.addSubview(nameSeparatorLine)
    inputsContainerView.addSubview(emailTextField)
    inputsContainerView.addSubview(emailSeparatorLine)
    inputsContainerView.addSubview(passwordTextField)
    
    
    // нужны ширина, высота, x, y constraints
    nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
    nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
    nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
    nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
    nameTextFieldHeightAnchor?.isActive = true
    
    // нужны ширина, высота, x, y constraints
    nameSeparatorLine.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
    nameSeparatorLine.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
    nameSeparatorLine.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
    nameSeparatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
    
    // нужны ширина, высота, x, y constraints
    emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
    emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
    emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
    emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
    emailTextFieldHeightAnchor?.isActive = true
    
    // нужны ширина, высота, x, y constraints
    emailSeparatorLine.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
    emailSeparatorLine.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
    emailSeparatorLine.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
    emailSeparatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
    
    // нужны ширина, высота, x, y constraints
    passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
    passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
    passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
    passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
    passwordTextFieldHeightAnchor?.isActive = true
    
  }
  
  // MARK: - создаем кнопку loginRegisteredButton
  let loginRegisteredButton : UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = UIColor(red: 80/255, green: 101/255, blue: 161/255, alpha: 1)
    button.setTitle("Register", for: .normal)
    button.setTitleColor(UIColor.white, for: .normal)
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    button.layer.cornerRadius = 5 // делаем углы закругленными
    button.layer.masksToBounds = true
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
    return button
  }()
  
  func handleLoginRegister() {
    if loginRegisteredSegmentController.selectedSegmentIndex == 0 {
      handleLogin()
    } else {
      handleRegistered()
    }
  }
  
  func handleLogin() {
    
    guard let email = emailTextField.text, let password = passwordTextField.text else {
      // print("Form is not valid")
      return
    }
    
    FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
      
      if error != nil {
        // print(error ?? "Can't Sign In")
        return
      }
      self.messageController?.fetchUserAndSetupNavBarTitle()
      self.dismiss(animated: true, completion: nil)
      
    })
  }
  
  // MARK: - создаем TextField nameTextField
  let nameTextField : UITextField = {
    let ntf = UITextField()
    ntf.placeholder = "Name"
    ntf.translatesAutoresizingMaskIntoConstraints = false
    return ntf
  }()
  
  
  // MARK: - создаем линию сепаратор для отделения наших textField
  let nameSeparatorLine : UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  // MARK: - создаем TextField emailTextField
  let emailTextField : UITextField = {
    let etf = UITextField()
    etf.placeholder = "Email"
    etf.translatesAutoresizingMaskIntoConstraints = false
    return etf
  }()
  
  
  // MARK: - создаем линию сепаратор для отделения наших textField
  let emailSeparatorLine : UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  // MARK: - создаем TextField passwordTextField
  let passwordTextField : UITextField = {
    let ptf = UITextField()
    ptf.placeholder = "Password"
    ptf.translatesAutoresizingMaskIntoConstraints = false
    return ptf
  }()
  
  
  // MARK: - создаем imageView для профиля
  let profileImageView : UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "gameofthrones_splash")
    imageView.contentMode = .scaleAspectFill
    
    imageView.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView))) // добавляем обработку жеста по картинке
    imageView.isUserInteractionEnabled = true // разрешаем интеракцию с изображением
    
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  
  // MARK: - создаем SegmentedControl
  let loginRegisteredSegmentController : UISegmentedControl = {
    let lsc = UISegmentedControl(items: ["Login", "Register"])
    lsc.tintColor = UIColor.white
    lsc.selectedSegmentIndex = 1   // индекс сегмента, который автоматически выбран
    lsc.translatesAutoresizingMaskIntoConstraints = false
    lsc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
    return lsc
  }()
  
  func handleLoginRegisterChange() {
    let title = loginRegisteredSegmentController.titleForSegment(at: loginRegisteredSegmentController.selectedSegmentIndex)  // изменям текст кнопки loginRegisteredButton текстом выбранного индекса loginRegisteredSegmentController
    loginRegisteredButton.setTitle(title, for: .normal)
    
    // изменить высоту inputsContainerView
    inputsContainerViewHeightAnchor?.constant = loginRegisteredSegmentController.selectedSegmentIndex == 0 ? 100 : 150
    
    // изменяем высоту nameTextField
    nameTextFieldHeightAnchor?.isActive = false
    nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisteredSegmentController.selectedSegmentIndex == 0 ? 0 : 1/3)
    nameTextFieldHeightAnchor?.isActive = true
    
    // изменяем высоту emailTextField
    emailTextFieldHeightAnchor?.isActive = false
    emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisteredSegmentController.selectedSegmentIndex == 0 ? 1/2 : 1/3)
    emailTextFieldHeightAnchor?.isActive = true
    
    // изменяем высоту emailTextField
    passwordTextFieldHeightAnchor?.isActive = false
    passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisteredSegmentController.selectedSegmentIndex == 0 ? 1/2 : 1/3)
    passwordTextFieldHeightAnchor?.isActive = true
    
  }
  
  // MARK: - настраиваем Anchor для нашей выше созданной кнопки
  func setuploginRegisteredButton() {
    // нужны ширина, высота, x, y constraints, по y и ширие относительно вышележащего view inputsContainerView
    
    loginRegisteredButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    loginRegisteredButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
    loginRegisteredButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
    loginRegisteredButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    
  }
  
  // MARK: - настраиваем Anchor для нашго выше созданнго ImageView
  func setupprofileImageView() {
    // нужны ширина, высота, x, y constraints
    profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    profileImageView.bottomAnchor.constraint(equalTo: loginRegisteredSegmentController.topAnchor, constant: -12).isActive = true
    profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
    profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
  }
  
  // MARK: - настраиваем Anchor для нашго выше созданнго SegmentControl
  func setuploginRegisterSegmentControl() {
    // нужны ширина, высота, x, y constraints
    loginRegisteredSegmentController.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    loginRegisteredSegmentController.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
    loginRegisteredSegmentController.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, multiplier: 1).isActive = true
    loginRegisteredSegmentController.heightAnchor.constraint(equalToConstant: 36).isActive = true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor(red: 61/255, green: 91/255, blue: 151/255, alpha: 1)
    view.addSubview(inputsContainerView)
    view.addSubview(loginRegisteredButton) // добавляем кнопку на view
    view.addSubview(profileImageView) // добавляем картинку на view
    view.addSubview(loginRegisteredSegmentController)
    
    setupInputContainer()
    setuploginRegisteredButton()
    setupprofileImageView()
    setuploginRegisterSegmentControl()
    
  }
  
  // делаем статус бар не черным, а светлым
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
}

/*
 //Дополнение класса UIColor, чтобы не писать /255
 extension UIColor {
 convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
 self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
 }
 }
 
 //с учетом этого view.backgroundColor выглядел бы так
 view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
 */
