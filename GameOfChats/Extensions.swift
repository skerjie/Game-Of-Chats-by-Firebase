//
//  Extensions.swift
//  GameOfChats
//
//  Created by Andrei Palonski on 25.01.17.
//  Copyright © 2017 Andrei Palonski. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
  
  // код взятый из NewMessageController для скачивания картинки закоменченный и переделанный под функцию
  func loadImageUsingCacheWithUrlString(urlString: String) {
    
      self.image = nil // так как используется reuseIdentifyer при прокрутке ячеек видны вспышки меняющихся картинок, а так будет белоя пятно, пока не подгрузится картинка
    
    // проверяем находятся ли картинки уже в кэше, чтобы не скачивать заново
    if let cachedImage = imageCache.object(forKey: urlString as NSString) {
      self.image = cachedImage
      return
    }
    
    let url = URL(string: urlString)
    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
      
      if error != nil {
        print(error)
        return
      }
      
      DispatchQueue.main.async {
        
        // кешируем скаченные изображения
        if let downloadedImage = UIImage(data: data!) {
          imageCache.setObject(downloadedImage, forKey: urlString as NSString)
          self.image = downloadedImage
        }

      }
      
      
    }).resume()
    
    
  }
  
  
  
}
