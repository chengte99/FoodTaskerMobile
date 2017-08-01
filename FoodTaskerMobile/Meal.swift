//
//  Meal.swift
//  FoodTaskerMobile
//
//  Created by ChengTeLin on 2017/5/8.
//  Copyright © 2017年 Let's Build A App. All rights reserved.
//

import Foundation
import SwiftyJSON

class Meal{
    var id:Int?
    var name:String?
    var short_description:String?
    var image:String?
    var price:Float?
    
    init(json:JSON) {
        
        self.id = json["id"].int
        self.name = json["name"].string
        self.short_description = json["short_description"].string
        self.image = json["image"].string
        self.price = json["price"].float
    }
    
}
