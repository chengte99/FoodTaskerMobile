//
//  FBManager.swift
//  FoodTaskerMobile
//
//  Created by ChengTeLin on 2017/4/28.
//  Copyright © 2017年 Let's Build A App. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import SwiftyJSON

class FBManager{
    
    static let shared = FBSDKLoginManager()
    
    public class func getFBUserData(completionHandler: @escaping () -> Void ){
        if FBSDKAccessToken.current() != nil{
            
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, email, picture.type(normal)"]).start(completionHandler: {
                (connect, result, error) in
                if (error == nil){
                    let json = JSON(result!)
                    
                    //print(json)
                    
                    User.currentUser.setInfo(json: json)
                    
                    completionHandler()
                }
            })
        }
    }
}
