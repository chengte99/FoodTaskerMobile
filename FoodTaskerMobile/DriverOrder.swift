//
//  DriverOrder.swift
//  FoodTaskerMobile
//
//  Created by ChengTeLin on 2017/5/15.
//  Copyright © 2017年 Let's Build A App. All rights reserved.
//

import Foundation
import SwiftyJSON

class DriverOrder{
    
    var id:Int?
    var restaurantName:String?
    var customerName:String?
    var customerAddress:String?
    var customerAvatar:String?
    
    init(json: JSON) {
        self.id = json["id"].int
        self.restaurantName = json["restaurant"]["name"].string
        self.customerName = json["customer"]["name"].string
        self.customerAddress = json["address"].string
        self.customerAvatar = json["customer"]["avatar"].string
    }
    
}
