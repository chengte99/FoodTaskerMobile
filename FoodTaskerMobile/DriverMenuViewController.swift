//
//  DriverMenuViewController.swift
//  FoodTaskerMobile
//
//  Created by ChengTeLin on 2017/5/15.
//  Copyright © 2017年 Let's Build A App. All rights reserved.
//

import UIKit

class DriverMenuViewController: UITableViewController {

    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red:0.18, green:0.18, blue:0.30, alpha:1.0)
        
        lbName.text = User.currentUser.name
        
        imgAvatar.layer.cornerRadius = imgAvatar.frame.size.width / 2
        imgAvatar.layer.borderWidth = 1.0
        imgAvatar.layer.borderColor = UIColor.white.cgColor
        imgAvatar.clipsToBounds = true
        
        if let imgString = User.currentUser.pictureURL{
            if let url = URL(string: imgString){
                DispatchQueue.global().async {
                    do{
                        let imgData = try Data(contentsOf: url)
                        DispatchQueue.main.async {
                            self.imgAvatar.image = UIImage(data: imgData)
                        }
                    }catch{
                        print(error.localizedDescription)
                    }
                }
            }
        }
        
    }


}
