//
//  DriverOrderViewController.swift
//  FoodTaskerMobile
//
//  Created by ChengTeLin on 2017/5/15.
//  Copyright © 2017年 Let's Build A App. All rights reserved.
//

import UIKit

class DriverOrderViewController: UITableViewController {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    let activityIndicator = UIActivityIndicatorView()
    var orders = [DriverOrder]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil{
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadOrders()
    }
    
    func loadOrders(){
        Helper.showActivityIndicator(activityIndicator, self.view)
        
        APIManager.shared.getReadyOrder { (json) in
            if json != nil{
                self.orders = []
                if let readyOrder = json["orders"].array{
                    for item in readyOrder{
                        let order = DriverOrder(json: item)
                        self.orders.append(order)
                    }
                }
                self.tableView.reloadData()
                Helper.hideActivityIndicator(self.activityIndicator)
            }
        }
        
    }
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return orders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DriverOrderCell", for: indexPath) as! DriverOrderCell
        
        let order = orders[indexPath.row]
        
        cell.lbRestaurantName.text = order.restaurantName
        cell.lbCustomerName.text = order.customerName
        cell.lbCustomerAddress.text = order.customerAddress
        
        cell.imgCustomerAvatar.layer.cornerRadius = cell.imgCustomerAvatar.frame.size.width / 2
        cell.imgCustomerAvatar.clipsToBounds = true
        Helper.loadImage(imageView: cell.imgCustomerAvatar, urlString: order.customerAvatar!)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let order = orders[indexPath.row]
        
        self.pickOrders(orderID: order.id!)
    }
    
    
    private func pickOrders(orderID:Int){
        APIManager.shared.pickOrder(orderID: orderID) { (json) in
            if json != nil{
                print(json)
                if let status = json["status"].string{
                    switch status{
                    case "failed":
                        //show an alert to saying error
                        let alert = UIAlertController(title: "Error", message: json["error"].string, preferredStyle: UIAlertControllerStyle.alert)
                        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        break
                    default:
                        //show an alert to saying success
                        let alert = UIAlertController(title: nil, message: "Success", preferredStyle: UIAlertControllerStyle.alert)
                        let action = UIAlertAction(title: "Show my map", style: UIAlertActionStyle.default, handler: { (action) in
                            
                            self.performSegue(withIdentifier: "CurrentDelivery", sender: self)
                        })
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        break
                        
                    }
                }
            }
        }
    }
    

}
