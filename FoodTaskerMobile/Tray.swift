//
//  File.swift
//  FoodTaskerMobile
//
//  Created by ChengTeLin on 2017/5/9.
//  Copyright © 2017年 Let's Build A App. All rights reserved.
//

import Foundation

class TrayItem{
    
    var meal:Meal
    var qty:Int
    
    init(meal:Meal, qty:Int) {
        self.meal = meal
        self.qty = qty
    }
}

class Tray{
    
    var restaurant:Restaurant?
    var items = [TrayItem]()
    var address:String?
    
    static let currentTray = Tray()
    
    func getTotal() -> Float{
        var total :Float = 0
        for item in items{
            print("Before#### \(total)")
            total = total + (Float(item.qty) * item.meal.price!)
            print("After##### \(total)")
        }
        
        return total
    }
    
    func reset(){
        self.restaurant = nil
        self.items = []
        self.address = nil
    }
    
    
}
