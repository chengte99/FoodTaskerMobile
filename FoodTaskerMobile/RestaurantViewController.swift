//
//  RestaurantViewController.swift
//  FoodTaskerMobile
//
//  Created by ChengTeLin on 2017/4/27.
//  Copyright © 2017年 Let's Build A App. All rights reserved.
//

import UIKit

class RestaurantViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var restaurantTableView: UITableView!
    @IBOutlet weak var searchRestaurant: UISearchBar!
    
    let activityIndicator = UIActivityIndicatorView()
    
    var restaurants = [Restaurant]()
    var filterdrestaurants = [Restaurant]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil{
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        loadRestaurant()
    }
    
    func loadRestaurant(){
        Helper.showActivityIndicator(activityIndicator, view)
        
        APIManager.shared.getRestaurant { (json) in
            
            if json != nil {
                //print(json)
                self.restaurants = []
                if let listRes = json["restaurants"].array{
                    for item in listRes{
                        let restaurant = Restaurant(json: item)
                        self.restaurants.append(restaurant)
                    }
                    
                    self.restaurantTableView.reloadData()
                    Helper.hideActivityIndicator(self.activityIndicator)
                }
            }
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchRestaurant.text != ""{
            return filterdrestaurants.count
        }
        
        return restaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell", for: indexPath) as! RestaurantTableViewCell
        
        let restaurant:Restaurant
        
        if searchRestaurant.text != ""{
            restaurant = filterdrestaurants[indexPath.row]
        }else{
            restaurant = restaurants[indexPath.row]
        }
        
        cell.lbRestaurantName.text = restaurant.name
        cell.lbRestaurantAddress.text = restaurant.address
        
        if let logoString = restaurant.logo{
            Helper.loadImage(imageView: cell.imgRestaurant, urlString: logoString)
        }
        
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MealList"{
            if let dvc = segue.destination as? MealListTableViewController{
                dvc.restaurant = restaurants[(restaurantTableView.indexPathForSelectedRow?.row)!]
            }
        }
    }
}

extension RestaurantViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filterdrestaurants = restaurants.filter {
            (res) -> Bool in
            if (res.name?.lowercased().contains(searchText.lowercased()))!{
                return true
            }else{
                return false
            }
        }
        restaurantTableView.reloadData()
    }
    
}
