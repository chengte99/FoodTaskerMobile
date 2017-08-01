//
//  CustomerMenuTableViewController.swift
//  FoodTaskerMobile
//
//  Created by ChengTeLin on 2017/4/27.
//  Copyright © 2017年 Let's Build A App. All rights reserved.
//

import UIKit

class CustomerMenuTableViewController: UITableViewController {

    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var nameUser: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red:0.18, green:0.18, blue:0.30, alpha:1.0)
        
        nameUser.text = User.currentUser.name
        
        imgUser.layer.cornerRadius = imgUser.frame.size.width / 2
        imgUser.layer.borderWidth = 1.0
        imgUser.layer.borderColor = UIColor.white.cgColor
        imgUser.clipsToBounds = true
        
        if let imgString = User.currentUser.pictureURL{
            if let url = URL(string: imgString){
                DispatchQueue.global().async {
                    do{
                        let imgData = try Data(contentsOf: url)
                        DispatchQueue.main.async {
                            self.imgUser.image = UIImage(data: imgData)
                        }
                    }catch{
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "CustomerLogout"{
            APIManager.shared.logout(completionHandler: { (error) in
                if error == nil{
                    FBManager.shared.logOut()
                    User.currentUser.resetInfo()
                    
                    let appController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainController") as? LoginViewController
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    appDelegate?.window?.rootViewController = appController
                }
            })
            return false
        }
        return true
    }
}
