//
//  LoginViewController.swift
//  FoodTaskerMobile
//
//  Created by ChengTeLin on 2017/4/28.
//  Copyright © 2017年 Let's Build A App. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var bLogin: UIButton!
    @IBOutlet weak var bLogout: UIButton!

    var fbLoginSuccess = false
    var userType = USERTYPE_CUSTOMER
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bLogout.isHidden = false
        
        if FBSDKAccessToken.current() != nil{
            FBManager.getFBUserData(completionHandler: { 
                self.bLogin.setTitle("Continue as \(User.currentUser.email!)", for: .normal)
            })
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {

        
        if (FBSDKAccessToken.current() != nil && fbLoginSuccess == true){
            performSegue(withIdentifier: "\(userType.capitalized)View", sender: self)
        }
    }
    
    @IBAction func facebookLogout(_ sender: UIButton) {
        APIManager.shared.logout { (error) in
            if error == nil{
                FBManager.shared.logOut()
                User.currentUser.resetInfo()
                self.bLogout.isHidden = true
                self.bLogin.setTitle("Login with Facebook", for: .normal)
            }
        }
    }
    
    @IBAction func facebookLogin(_ sender: UIButton) {
        
        if FBSDKAccessToken.current() != nil{
            
            APIManager.shared.login(userType: userType, completionHandler: { (error) in
                if error == nil{
                    self.fbLoginSuccess = true
                    self.viewDidAppear(true)
                }
            })
        }else{
            FBManager.shared.logIn(
                withReadPermissions: ["public_profile", "email"],
                from: self,
                handler: {
                    (result, error) in
                    if error == nil{
                        
                        FBManager.getFBUserData(completionHandler: {
                            APIManager.shared.login(userType: self.userType, completionHandler: { (error) in
                                if error == nil{
                                    self.fbLoginSuccess = true
                                    self.viewDidAppear(true)
                                }
                            })
                        })
                    }
            })
        }
    }
    
    @IBAction func switchUserType(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            userType = USERTYPE_CUSTOMER
        }else{
            userType = USERTYPE_DRIVER
        }
        
    }
    

}
