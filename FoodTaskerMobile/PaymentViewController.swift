//
//  PaymentViewController.swift
//  FoodTaskerMobile
//
//  Created by ChengTeLin on 2017/4/27.
//  Copyright © 2017年 Let's Build A App. All rights reserved.
//

import UIKit
import Stripe

class PaymentViewController: UIViewController {

    @IBOutlet weak var cardTextField: STPPaymentCardTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }

    @IBAction func placeOrder(_ sender: UIButton) {
        
        APIManager.shared.getLasestOrder { (json) in
            
            
                if json["order"]["status"] == nil || json["order"]["status"] == "Delivered"{
                    // Processing the payment and create an order
                    let card = self.cardTextField.cardParams
                    
                    STPAPIClient.shared().createToken(withCard: card, completion: {
                        (token, error) in
                        
                        if let myError = error{
                            print(myError)
                        }else if let stripeToken = token{
                            
                            APIManager.shared.createOrder(stripeToken: stripeToken.tokenId, completionHandler: { (json) in
                                Tray.currentTray.reset()
                                self.performSegue(withIdentifier: "ViewOrder", sender: self)
                                
                            })
                        }
                        
                    })
                    
                }else{
                    // show alert message
                    let alert = UIAlertController(title: "Already Order?", message: "Your current order isn't completed!", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Go to order", style: .default, handler: {
                        (action) in
                        
                        self.performSegue(withIdentifier: "ViewOrder", sender: self)
                    })
                    let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(okAction)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            
        }
        
    }
}
