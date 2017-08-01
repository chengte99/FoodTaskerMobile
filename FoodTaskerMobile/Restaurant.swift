//
//  Restaurant.swift
//  FoodTaskerMobile
//
//  Created by ChengTeLin on 2017/5/8.
//  Copyright © 2017年 Let's Build A App. All rights reserved.
//

import Foundation
import SwiftyJSON

class Restaurant {
    var id:Int?
    var name:String?
    var address:String?
    var logo:String?
    
    init(json: JSON) {
        self.id = json["id"].int
        self.name = json["name"].string
        self.address = json["address"].string
        self.logo = json["logo"].string
    }
    
}
