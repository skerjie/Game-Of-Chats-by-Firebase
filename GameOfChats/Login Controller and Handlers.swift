//
//  Login Controller and Handlers.swift
//  GameOfChats
//
//  Created by Andrei Palonski on 24.01.17.
//  Copyright © 2017 Andrei Palonski. All rights reserved.
//

import UIKit
import Firebase

extension LoginController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  // MARK: - обработка нажатия на изображение для выбора картинки профиля
  func handleSelectProfileImageView() {
    
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.allowsEditing = true
    present(picker, animated: true, completion: nil)
    
  }
  
  // метод делегата
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    var selectedImageFromPicker : UIImage?
    
    if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
      selectedImageFromPicker = editedImage
    } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      selectedImageFromPicker = originalImage
    }
    
    if let selectedImage = selectedImageFromPicker {
      profileImageView.image = selectedImage
    }
    
    dismiss(animated: true, completion: nil)
    
  }
  
  // метод делегата
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    //print("Canceled")
    dismiss(animated: true, completion: nil)
  }
  
  // MARK: - обработка нажатия кнопки Регистрация
  func handleRegistered() {
    
    guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
      //print("Form not valid")
      return
    }
    
    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
      
      if error != nil {
        //print(error?.localizedDescription ?? "Error! Can't create user...")
        return
      }
      
      guard let uid = user?.uid else { return }
      
      // successfully authenticated
      // MARK: - коннектимся к storage FIRStorage чтобы загрузить профиль картинки
      
      let imageName = NSUUID().uuidString
      let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
      
      //      if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!) {
      if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
        
        //      if let uploadData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.1) {
        
        storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
          
          if error != nil {
            //print(error ?? "Error while uploading image")
            return
          }
          
          if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
            let values = ["name" : name, "email" : email, "profileImageUrl" : profileImageUrl]
            self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
          }
        })
      }
    })
  }
  
  
  // MARK: - коннектимся к database FIRDatabase и регистрируемся
  private func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
    
    let ref = FIRDatabase.database().reference()
    let userReference = ref.child("users").child(uid)
    userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
      
      if err != nil {
        //print(err?.localizedDescription ?? "Error in registration")
        return
      }
      
      // self.messageController?.fetchUserAndSetupNavBarTitle()
      // self.messageController?.navigationItem.title = values["name"] as? String
      
      let user = User()
      user.setValuesForKeys(values)
      self.messageController?.setupNavBarWithUser(user: user )
      
      self.dismiss(animated: true, completion: nil)
      
    })
  }
  
}
