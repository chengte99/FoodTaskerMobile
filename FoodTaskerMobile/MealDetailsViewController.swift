//
//  MealDetailsViewController.swift
//  FoodTaskerMobile
//
//  Created by ChengTeLin on 2017/4/27.
//  Copyright © 2017年 Let's Build A App. All rights reserved.
//

import UIKit

class MealDetailsViewController: UIViewController {
    
    var restaurant:Restaurant?
    var meal:Meal?
    var qty = 1
    
    @IBOutlet weak var imgMealImage: UIImageView!
    @IBOutlet weak var lbMealName: UILabel!
    @IBOutlet weak var lbMealShortDescription: UILabel!
    
    @IBOutlet weak var lbQty: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadMealDetails()
    }
    
    func loadMealDetails(){
        
        lbMealName.text = meal?.name
        lbMealShortDescription.text = meal?.short_description
        
        if let imgString = meal?.image{
            Helper.loadImage(imageView: imgMealImage, urlString: imgString)
        }
        
        if let priceFloat = meal?.price{
            lbPrice.text = "$\(priceFloat)"
        }
        
    }
    
    
    @IBAction func addToTray(_ sender: UIButton) {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
        imageView.image = UIImage(named: "button_chicken")
        imageView.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height - 100)
        self.view.addSubview(imageView)
        
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: { 
            imageView.center = CGPoint(x: self.view.frame.width - 40, y: 25)
        }) { (bool) in
            imageView.removeFromSuperview()
            
            
            let trayItem = TrayItem(meal: self.meal!, qty: self.qty)
            
            guard let trayRestaurant = Tray.currentTray.restaurant, let currentRestaurant = self.restaurant else{
                
                Tray.currentTray.restaurant = self.restaurant
                Tray.currentTray.items.append(trayItem)
                
                return
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            //If ordering meal from same restaurant
            if trayRestaurant.id == currentRestaurant.id{
                
                let indexMealInTray = Tray.currentTray.items.index(where: {
                    (item) -> Bool in
                    
                    return item.meal.id == trayItem.meal.id
                })
                
                if let index = indexMealInTray{
                    
                    let alert = UIAlertController(title: "Add more?", message: "Your tray already has this meal.Do you want to add more?", preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "Add more", style: UIAlertActionStyle.default, handler: {
                        (action) in
                        
                        Tray.currentTray.items[index].qty += self.qty
                    })
                    alert.addAction(okAction)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }else{
                    
                    Tray.currentTray.items.append(trayItem)
                }
                
            }else{//If ordering meal from another restaurant
                
                let alert = UIAlertController(title: "Start new tray", message: "You'are ordering meal from another restaurant.Would you like to clear the current tray?", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "Start new tray", style: UIAlertActionStyle.default, handler: {
                    (action) in
                    
                    Tray.currentTray.restaurant = self.restaurant
                    Tray.currentTray.items = []
                    Tray.currentTray.items.append(trayItem)
                    
                })
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    @IBAction func removeQty(_ sender: UIButton) {
        if qty >= 2{
            qty -= 1
            lbQty.text = String(qty)
            if let priceFloat = meal?.price{
                lbPrice.text = "$\(priceFloat * Float(qty))"
            }
        }
    }
    
    @IBAction func addQty(_ sender: UIButton) {
        if qty < 99{
            qty += 1
            lbQty.text = String(qty)
            if let priceFloat = meal?.price{
                lbPrice.text = "$\(priceFloat * Float(qty))"
            }
        }
    }
}
