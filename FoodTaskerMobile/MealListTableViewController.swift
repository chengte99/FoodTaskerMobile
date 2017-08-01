//
//  MealListTableViewController.swift
//  FoodTaskerMobile
//
//  Created by ChengTeLin on 2017/4/27.
//  Copyright © 2017年 Let's Build A App. All rights reserved.
//

import UIKit

class MealListTableViewController: UITableViewController {
    
    var restaurant: Restaurant?
    var meals = [Meal]()
    
    let activityIndicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let restaurantName = restaurant?.name{
            navigationItem.title = restaurantName
        }
        if let id = restaurant?.id{
            loadMeals(restaurantID: id)
        }
    }
    
    func loadMeals(restaurantID:Int){
        Helper.showActivityIndicator(activityIndicator, view)
        
        APIManager.shared.getMeal(restaurantId: restaurantID) {
            (json) in
            if json != nil{
                self.meals = []
                if let listMeal = json["meal"].array{
                    for item in listMeal{
                        let meal = Meal(json: item)
                        self.meals.append(meal)
                    }
                    
                    self.tableView.reloadData()
                    Helper.hideActivityIndicator(self.activityIndicator)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MealDetails"{
            if let dvc = segue.destination as? MealDetailsViewController{
                dvc.meal = meals[(tableView.indexPathForSelectedRow?.row)!]
                dvc.restaurant = restaurant
            }
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealCell", for: indexPath) as! MealTableViewCell
        
        let meal = meals[indexPath.row]
        
        cell.lbMealName.text = meal.name
        cell.lbMealShortDescription.text = meal.short_description
        
        if let price = meal.price{
            cell.lbPrice.text = "\(price)"
        }
        
        if let imageString = meal.image{
            Helper.loadImage(imageView: cell.imgMealImage, urlString: imageString)
        }
        
        return cell
    }
    
}
