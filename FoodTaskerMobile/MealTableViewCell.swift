//
//  MealTableViewCell.swift
//  FoodTaskerMobile
//
//  Created by ChengTeLin on 2017/5/8.
//  Copyright © 2017年 Let's Build A App. All rights reserved.
//

import UIKit

class MealTableViewCell: UITableViewCell {

    @IBOutlet weak var imgMealImage: UIImageView!
    @IBOutlet weak var lbMealName: UILabel!
    @IBOutlet weak var lbMealShortDescription: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


}
