//
//  TrayViewCell.swift
//  FoodTaskerMobile
//
//  Created by ChengTeLin on 2017/5/9.
//  Copyright © 2017年 Let's Build A App. All rights reserved.
//

import UIKit

class TrayViewCell: UITableViewCell {

    @IBOutlet weak var labelQty: UILabel!
    @IBOutlet weak var labelSubtotal: UILabel!
    @IBOutlet weak var labelMealName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        labelQty.layer.borderColor = UIColor.gray.cgColor
        labelQty.layer.borderWidth = 1.0
        labelQty.layer.cornerRadius = 10
        
    }

}
