//
//  OrderViewController.swift
//  FoodTaskerMobile
//
//  Created by ChengTeLin on 2017/4/27.
//  Copyright © 2017年 Let's Build A App. All rights reserved.
//

import UIKit
import SwiftyJSON
import MapKit

class OrderViewController: UIViewController {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var orderStatus: UILabel!
    @IBOutlet weak var tbvOrder: UITableView!
    
    var meal = [JSON]()
    
    var source:MKPlacemark?
    var destination:MKPlacemark?
    
    var driverPin:MKPointAnnotation?
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil{
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        loadLastOrder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.timer.invalidate()
    }
    
    func loadLastOrder(){
        
        APIManager.shared.getLasestOrder { (json) in
            
            if json != nil{
                
                print(json)
                let order = json["order"]
                
                if order["status"] != nil{
                    
                    if let orderDetail = order["order_details"].array{
                        self.meal = orderDetail
                        self.tbvOrder.reloadData()
                    }
                    
                    self.orderStatus.text = order["status"].string?.uppercased()
                    
                    let from = order["restaurant"]["address"].string
                    let to = order["address"].string
                    
                    self.getLocation(from!, "RES", completionHandler: { (sou) in
                        
                        self.source = sou
                        
                        self.getLocation(to!, "CUS", completionHandler: { (des) in
                            
                            self.destination = des
                            
                            self.getDirections()
                        })
                    })
                    
                    if order["status"] != "Delivered"{
                        if order["driver"] != nil{
                            self.runTimer()
                        }
                    }
                }
            }
        }
    }
    
    func runTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(getLocation(_:)), userInfo: nil, repeats: true)
    }
    
    func getLocation(_ sender:AnyObject){
        APIManager.shared.getDriverLocation { (json) in
            if json != nil{
                if let location = json["location"].string{
                    
                    let split = location.components(separatedBy: ",")
                    let lat = split[0]
                    let lng = split[1]
                    
                    let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(lat)!, CLLocationDegrees(lng)!)
                    
                    //create pin annotation for driver
                    if self.driverPin != nil{
                        self.driverPin?.coordinate = coordinate
                    }else{
                        self.driverPin = MKPointAnnotation()
                        self.driverPin?.coordinate = coordinate
                        self.driverPin?.title = "DRI"
                        self.map.addAnnotation(self.driverPin!)
                    }
                    
                    self.autoZoom()
                }
            }
        }
    }
    
    func autoZoom(){
        
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

extension OrderViewController: MKMapViewDelegate{
    
    //#1 - Delegate method of MKMapView
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 3.0
        renderer.alpha = 0.5
        
        return renderer
    }
    
    //#2 - convert an address to a location
    func getLocation(_ address:String, _ title:String, completionHandler: @escaping (MKPlacemark) -> Void){
        
        Tray.currentTray.address = address
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address, completionHandler: {
            (placemarks, error) in
            
            if (error != nil){
                print(error!.localizedDescription)
            }
            
            if let placemark = placemarks?.first{
                
                let coordinate = placemark.location?.coordinate
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate!
                annotation.title = title
                self.map.addAnnotation(annotation)
                
                completionHandler(MKPlacemark(placemark: placemark))
            }
            
        })
    }
    
    //#3 - Get direction and zoom to address
    func getDirections(){
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem.init(placemark: self.source!)
        request.destination = MKMapItem.init(placemark: self.destination!)
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            
            if error != nil{
                print(error!.localizedDescription)
            }else{
                //show route
                self.showRoute(response: response!)
            }
        }
    }
    
    //#4 - Show route between locations and make a visible zoom
    func showRoute(response: MKDirectionsResponse){
        
        for route in response.routes{
            self.map.add(route.polyline, level: MKOverlayLevel.aboveRoads)
        }
        
    }
    
    //#5 - Customize pin point with image
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationIdentifier = "MyPin"
        
        var annotationView: MKAnnotationView?
        if let dequeueAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier){
            
            annotationView = dequeueAnnotationView
            annotationView?.annotation = annotation
        }else{
            
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        }
        
        if let finAnnotationView = annotationView, let name = annotation.title! {
            
            switch name {
            case "RES":
                finAnnotationView.canShowCallout = true
                finAnnotationView.image = UIImage(named: "pin_restaurant")
            case "CUS":
                finAnnotationView.canShowCallout = true
                finAnnotationView.image = UIImage(named: "pin_customer")
            case "DRI":
                finAnnotationView.canShowCallout = true
                finAnnotationView.image = UIImage(named: "pin_car")
            default:
                finAnnotationView.canShowCallout = true
                finAnnotationView.image = UIImage(named: "pin_car")
            }
        }
        
        return annotationView
    }
    
    
}

extension OrderViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meal.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderItemCell", for: indexPath) as! OrderViewCell
        
        let orderDetail = meal[indexPath.row]
        
        cell.labelQty.text = String(orderDetail["quantity"].int!)
        cell.labelSubtotal.text = "$\(orderDetail["sub_total"].int!)"
        cell.labelMealName.text = orderDetail["meal"]["name"].string
        
        return cell
    }
}
