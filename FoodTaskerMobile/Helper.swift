//
//  Helper.swift
//  FoodTaskerMobile
//
//  Created by ChengTeLin on 2017/5/8.
//  Copyright © 2017年 Let's Build A App. All rights reserved.
//

import Foundation

class Helper{
    
    // help to load image
    static func loadImage(imageView: UIImageView, urlString:String){
        if let imgURL = URL(string: urlString){
            
            URLSession.shared.dataTask(with: imgURL, completionHandler: {
                (data, response, error) in
                
                if error != nil{
                    print(error!.localizedDescription)
                    return
                }
                if let downloadData = data {
                    let imgData = UIImage(data: downloadData)
                    DispatchQueue.main.async {
                        imageView.image = imgData
                    }
                }
            }).resume()
        }
    }
    
    // help to show activityIndicator
    static func showActivityIndicator(_ activityIndicator: UIActivityIndicatorView, _ view: UIView){
        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40, height: 40)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.color = UIColor.black
        
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    // help to hide activityIndicator
    static func hideActivityIndicator(_ activityIndicator: UIActivityIndicatorView){
        activityIndicator.stopAnimating()
    }
    
}
