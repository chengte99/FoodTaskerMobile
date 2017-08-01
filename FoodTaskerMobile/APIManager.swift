//
//  APIManager.swift
//  FoodTaskerMobile
//
//  Created by ChengTeLin on 2017/5/3.
//  Copyright © 2017年 Let's Build A App. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import Alamofire
import SwiftyJSON
import CoreLocation

class APIManager{
    
    static let shared = APIManager()
    
    let base_url = URL(string: BASE_URL)
    
    var accessToken = ""
    var refreshToken = ""
    var expired = Date()
    
    // API to login an user
    func login(userType: String, completionHandler: @escaping (NSError?) -> Void){
        let path = "api/social/convert-token/"
        
        if let url = base_url?.appendingPathComponent(path){
            let params:[String:Any] = [
                "grant_type": "convert_token",
                "client_id": CLIENT_ID,
                "client_secret": CLIENT_SECRET,
                "backend": "facebook",
                "token": FBSDKAccessToken.current().tokenString,
                "user_type": userType
            ]
            
            Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding(), headers: nil).responseJSON(completionHandler: {
                (response) in
                switch response.result{
                case .success(let value):
                    
                    let json = JSON(value)
                    self.accessToken = json["access_token"].string!
                    self.refreshToken = json["refresh_token"].string!
                    self.expired = Date().addingTimeInterval(TimeInterval(json["expires_in"].int!))
                    
                    completionHandler(nil)
                    break
                    
                case .failure(let error):
                    completionHandler(error as NSError)
                    break
                }
            })
        }
    }
    
    // API to logout an user
    func logout(completionHandler: @escaping (NSError?) -> Void){
        let path = "/api/social/revoke-token/"
        
        if let url = base_url?.appendingPathComponent(path){
            let params:[String:Any] = [
                "client_id": CLIENT_ID,
                "client_secret": CLIENT_SECRET,
                "token": self.accessToken
            ]
            
            Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding(), headers: nil).responseString(completionHandler: {
                (response) in
                switch response.result{
                case .success:
                    completionHandler(nil)
                    break
                    
                case .failure(let error):
                    completionHandler(error as NSError)
                    break
                }
            })
        }
    }
    
    // function to request server
    func requestToServer(_ path:String, _ method:HTTPMethod, _ params:[String:Any]?, _ encoding: ParameterEncoding, completionHandler: @escaping (JSON) -> Void){
        
        refreshTokenIfNeed {
            
            if let url = self.base_url?.appendingPathComponent(path){
                
                Alamofire.request(url, method: method, parameters: params, encoding: encoding, headers: nil).responseJSON(completionHandler: {
                    (response) in
                    
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        completionHandler(json)
                        break
                    case .failure:
                        completionHandler(JSON.null)
                        break
                    }
                })
            }
        }
    }
    
    // API to refresh token when it's expired
    func refreshTokenIfNeed(completionHandler: @escaping () -> Void){
        let path = "api/social/refresh-token/"
        
        if Date() > self.expired{
            if let url = base_url?.appendingPathComponent(path){
                let params:[String:Any] = [
                    "access_token": self.accessToken,
                    "refresh_token": self.refreshToken
                ]
                
                Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding(), headers: nil).responseJSON(completionHandler: {
                    (response) in
                    
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        self.accessToken = json["access_token"].string!
                        self.expired = Date().addingTimeInterval(TimeInterval(json["expires_in"].int!))
                        
                        completionHandler()
                        break
                    case .failure:
                        break
                    }
                })
            }
        }else{
            completionHandler()
        }
    }
    
    //********* Customers ***********//
    
    // API to get restaurant list
    func getRestaurant(completionHandler: @escaping (JSON) -> Void){
        let path = "api/customer/restaurants/"
        
        requestToServer(path, .get, nil, URLEncoding(), completionHandler: completionHandler)
    }
    
    // API to get meal of restaurant
    func getMeal(restaurantId: Int, completionHandler: @escaping (JSON) -> Void){
        let path = "api/customer/meal/\(restaurantId)/"
        
        requestToServer(path, .get, nil, URLEncoding(), completionHandler: completionHandler)
        
    }
    
    // API to creating order
    func createOrder(stripeToken: String, completionHandler: @escaping (JSON) -> Void){
        
        let path = "api/customer/order/add/"
        let simpleArray = Tray.currentTray.items
        let jsonArray = simpleArray.map { (item) in
            [
                "meal_id": item.meal.id,
                "quantity": item.qty
            ]
        }
        
        if JSONSerialization.isValidJSONObject(jsonArray){
            
            do{
                let data = try JSONSerialization.data(withJSONObject: jsonArray, options: [])
                let dataString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                
                let params:[String:Any] = [
                    "access_token": self.accessToken,
                    "restaurant_id": "\(Tray.currentTray.restaurant!.id!)",
                    "address": Tray.currentTray.address!,
                    "order_details": dataString,
                    "stripe_token": stripeToken
                ]
                
                requestToServer(path, .post, params, URLEncoding(), completionHandler: completionHandler)
                
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
    //API to get lasest order
    func getLasestOrder(completionHandler: @escaping (JSON) -> Void){
        let path = "api/customer/order/latest/"
        let params:[String:Any] = [
            "access_token": self.accessToken
        ]
        
        requestToServer(path, .get, params, URLEncoding(), completionHandler: completionHandler)
    }
    
    //API to get driver's location
    func getDriverLocation(completionHandler: @escaping (JSON) -> Void){
        let path = "api/customer/driver/location/"
        let params:[String:Any] = [
            "access_token": self.accessToken
        ]

        requestToServer(path, .get, params, URLEncoding(), completionHandler: completionHandler)
        
    }
    
    
    //********* Drivers ***********//
    //API to get list of order ready
    func getReadyOrder(completionHandler: @escaping (JSON) -> Void){
        let path = "api/driver/orders/ready/"
        
        requestToServer(path, .get, nil, URLEncoding(), completionHandler: completionHandler)
    }
    
    //API to pick order
    func pickOrder(orderID: Int, completionHandler: @escaping (JSON) -> Void){
        let path = "api/driver/order/pick/"
        let params:[String:Any] = [
            "access_token": self.accessToken,
            "order_id": orderID
        ]
        
        requestToServer(path, .post, params, URLEncoding(), completionHandler: completionHandler)
    }
    
    //API to get lasest order of delivery
    func getDriverCurrentOrder(completionHandler: @escaping (JSON) -> Void){
        let path = "api/driver/order/latest/"
        let params:[String:Any] = [
            "access_token": self.accessToken
        ]
        
        requestToServer(path, .get, params, URLEncoding(), completionHandler: completionHandler)
    }
    
    //API to update driver's location
    func updateLocation(location: CLLocationCoordinate2D, completionHandler: @escaping (JSON) -> Void){
        let path = "api/driver/location/update/"
        let params:[String:Any] = [
            "access_token": self.accessToken,
            "location": "\(location.latitude),\(location.longitude)"
        ]
        
        requestToServer(path, .post, params, URLEncoding(), completionHandler: completionHandler)
    }
    
    // API to complete order
    func completeOrder(orderID:Int, completionHandler: @escaping (JSON) -> Void){
        let path = "api/driver/order/complete/"
        let params:[String:Any] = [
            "access_token": self.accessToken,
            "order_id": "\(orderID)"
        ]
        
        requestToServer(path, .post, params, URLEncoding(), completionHandler: completionHandler)
    }
    
    //API to get revenue
    func getDriverRevenue(completionHandler: @escaping (JSON) -> Void){
        let path = "api/driver/revenue/"
        let params:[String:Any] = [
            "access_token": self.accessToken
        ]
        
        requestToServer(path, .get, params, URLEncoding(), completionHandler: completionHandler)
    }
    
    
}
