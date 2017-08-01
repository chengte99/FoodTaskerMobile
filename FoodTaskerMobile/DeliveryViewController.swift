//
//  DeliveryViewController.swift
//  FoodTaskerMobile
//
//  Created by ChengTeLin on 2017/5/15.
//  Copyright © 2017年 Let's Build A App. All rights reserved.
//

import UIKit
import MapKit

class DeliveryViewController: UIViewController {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var lbCustomerName: UILabel!
    @IBOutlet weak var lbCustomerAddress: UILabel!
    @IBOutlet weak var imgCustomerAvatar: UIImageView!
    @IBOutlet weak var buttonStatus: UIButton!
    var orderId:Int?
    let activityIndicator = UIActivityIndicatorView()
    
    var source:MKPlacemark?
    var destination:MKPlacemark?
    
    var locationManager:CLLocationManager?
    var driverPin:MKPointAnnotation?
    var lastLocation:CLLocationCoordinate2D?
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil{
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
        
        // show driver's location
        if CLLocationManager.locationServicesEnabled(){
            
            locationManager = CLLocationManager()
            locationManager?.requestWhenInUseAuthorization()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.delegate = self
            locationManager?.startUpdatingLocation()
            
            self.map.showsUserLocation = true
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updatelocation(_:)), userInfo: nil, repeats: true)
        
    }
    
    func updatelocation(_ sender:AnyObject){
        APIManager.shared.updateLocation(location: lastLocation!) { (json) in
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        getCurrentOrder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.timer.invalidate()
        
    }
    
    func getCurrentOrder(){
        Helper.showActivityIndicator(activityIndicator, self.view)
        
        APIManager.shared.getDriverCurrentOrder { (json) in
            
            if json != nil{
                
                let order = json["order"]
                
                if let id = order["id"].int, order["status"].string == "On the way"{
                    
                    self.orderId = id
                    
                    let from = order["restaurant"]["address"].string
                    let to = order["address"].string
                    
                    self.lbCustomerName.text = order["customer"]["name"].string
                    self.lbCustomerAddress.text = to
                    
                    self.imgCustomerAvatar.layer.cornerRadius = self.imgCustomerAvatar.frame.size.width / 2
                    self.imgCustomerAvatar.clipsToBounds = true
                    Helper.loadImage(imageView: self.imgCustomerAvatar, urlString: order["customer"]["avatar"].string!)
                    
                    self.getLocation(from!, "Restaurant", completionHandler: { (sou) in
                        
                        self.source = sou
                        self.getLocation(to!, "Customer", completionHandler: { (des) in
                            
                            self.destination = des
                            
                        })
                    })
                    
                    Helper.hideActivityIndicator(self.activityIndicator)
                    
                }else{
                    
                    let labelEmpty = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
                    labelEmpty.center = self.view.center
                    labelEmpty.textAlignment = NSTextAlignment.center
                    labelEmpty.text = "You don't have any order for delivery!"
                    self.view.addSubview(labelEmpty)
                    
                    self.map.isHidden = true
                    self.viewInfo.isHidden = true
                    self.buttonStatus.isHidden = true
                    
                    Helper.hideActivityIndicator(self.activityIndicator)
                }
            }
        }
        
        Helper.hideActivityIndicator(self.activityIndicator)
    }
    
    @IBAction func completeOrder(_ sender: UIButton) {
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
            APIManager.shared.completeOrder(orderID: self.orderId!, completionHandler: { (json) in
                
                if json != nil{
                    //Stop update driver location
                    self.timer.invalidate()
                    self.locationManager?.stopUpdatingLocation()
                    
                    //Redirect page to ready orders
                    self.performSegue(withIdentifier: "ViewOrders", sender: self)
                }
            })
        }
        
        let alert = UIAlertController(title: "Complete Order", message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
}

extension DeliveryViewController: MKMapViewDelegate{
    
    //#1 - Set MKPolylineRenderer parameter, it's a delegate function
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 3.0
        renderer.alpha = 0.5
        
        return renderer
    }
    
    //#2 - get location for address string
    func getLocation(_ address:String, _ title:String, completionHandler: @escaping (MKPlacemark) -> Void){
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            
            if error != nil{
                print(error!.localizedDescription)
            }
            
            if let placemark = placemarks?.first{
                if let coordinate = placemark.location?.coordinate{
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = title
                    self.map.addAnnotation(annotation)
                    
                    completionHandler(MKPlacemark(placemark: placemark))
                }
            }
        }
    }
}

extension DeliveryViewController:CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last! as CLLocation
        self.lastLocation = location.coordinate
        
        //create pin annotation for driver
        if driverPin != nil{
            driverPin?.coordinate = lastLocation!
        }else{
            driverPin = MKPointAnnotation()
            driverPin?.coordinate = lastLocation!
            self.map.addAnnotation(driverPin!)
        }
        
        var zoomRect = MKMapRectNull
        
        for annotation in self.map.annotations{
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
            zoomRect = MKMapRectUnion(zoomRect, pointRect)
        }
        
        let insetWidth = -zoomRect.size.width * 0.2
        let insetHeight = -zoomRect.size.height * 0.2
        let insetRect = MKMapRectInset(zoomRect, insetWidth, insetHeight)
        
        self.map.setVisibleMapRect(insetRect, animated: true)
        
    }
}





