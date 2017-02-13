//
//  UserCell.swift
//  GameOfChats
//
//  Created by Andrei Palonski on 31.01.17.
//  Copyright © 2017 Andrei Palonski. All rights reserved.
//

import UIKit
import Firebase

class UserCell : UITableViewCell {
  
  var message : Message? {
    didSet {
      
      setupNameAndProfileImage()
      
      detailTextLabel?.text = message?.text
      
      if let seconds = message?.timeStamp?.doubleValue {
        let timeStampDate = NSDate(timeIntervalSince1970: seconds)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss a"
        timeLabel.text = dateFormatter.string(from: timeStampDate as Date)
      }
      
      timeLabel.text = message?.timeStamp?.stringValue
    }
  }
  
  
  private func setupNameAndProfileImage() {
    
    if let id = message?.chatPartnerId() {
      let ref = FIRDatabase.database().reference().child("users").child(id)
      ref.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let dictionary = snapshot.value as? [String : AnyObject] {
          self.textLabel?.text = dictionary["name"] as? String
          
          if let profileImageUrl = dictionary["profileImageUrl"] as? String {
            self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
          }
        }
      }, withCancel: nil)
    }
  }
  
  // переопределяем кастомные textLabel и detailTextLabel чтобы вылядело красивее, точнее сдвигаем правее изображения
  override func layoutSubviews() {
    super.layoutSubviews()
    
    textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
    
    detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height) // +2 и -2 по y чтобы разнести друг от друга по вертикали textLabel и detailTextLabel
    
  }
  
  let profileImageView : UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 24
    imageView.layer.masksToBounds = true
    imageView.contentMode = .scaleAspectFill
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  let timeLabel : UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 13)
    label.textColor = UIColor.darkGray
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    
    // кастомное imageView вместо встроенного в ячейку
    addSubview(profileImageView)
    addSubview(timeLabel)
    
    profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
    profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
    profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
    
    timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
    timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
    timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
