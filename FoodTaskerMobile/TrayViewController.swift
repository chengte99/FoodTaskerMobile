//
//  TrayViewController.swift
//  FoodTaskerMobile
//
//  Created by ChengTeLin on 2017/4/27.
//  Copyright © 2017年 Let's Build A App. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class TrayViewController: UIViewController {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    @IBOutlet weak var tbvTray: UITableView!
    @IBOutlet weak var viewTotal: UIView!
    @IBOutlet weak var viewAddress: UIView!
    @IBOutlet weak var viewMap: UIView!
    @IBOutlet weak var buttonAddPayment: UIButton!
    
    @IBOutlet weak var labelTotal: UILabel!
    @IBOutlet weak var textFieldAddress: UITextField!
    @IBOutlet weak var map: MKMapView!
    
    var locationManager:CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil{
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //If Tray is empty, show message
        if Tray.currentTray.items.count == 0 {
            let labelEmpty = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
            labelEmpty.center = self.view.center
            labelEmpty.textAlignment = NSTextAlignment.center
            labelEmpty.text = "Your tray is empty.Please select meal."
            
            self.view.addSubview(labelEmpty)
        }else{//Display all UI controller
            
            self.tbvTray.isHidden = false
            self.viewTotal.isHidden = false
            self.viewAddress.isHidden = false
            self.viewMap.isHidden = false
            self.buttonAddPayment.isHidden = false
            
            loadMeal()
        }
        
        //show user's location
        
        if CLLocationManager.locationServicesEnabled(){
            
            locationManager = CLLocationManager()
            locationManager?.requestWhenInUseAuthorization()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.delegate = self
            locationManager?.startUpdatingLocation()
            
            self.map.showsUserLocation = true
        }
        
    }
    
    func loadMeal(){
        tbvTray.reloadData()
        labelTotal.text = "$\(Tray.currentTray.getTotal())"
    }
    
    @IBAction func addPayment(_ sender: UIButton) {
        if textFieldAddress.text == ""{
            
            let alert = UIAlertController(title: "No address", message: "Address is required", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                (action) in
                self.textFieldAddress.becomeFirstResponder()
            })
            
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            
        }else{
            Tray.currentTray.address = textFieldAddress.text
            performSegue(withIdentifier: "AddPayment", sender: self)
        }
    }
    
}

extension TrayViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last! as CLLocation
        
        let coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(coordinate, span)
        
        map.setRegion(region, animated: true)
    }
    
}

extension TrayViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Tray.currentTray.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrayItemCell", for: indexPath) as! TrayViewCell
        
        let tray = Tray.currentTray.items[indexPath.row]
        cell.labelQty.text = "\(tray.qty)"
        cell.labelMealName.text = tray.meal.name
        cell.labelSubtotal.text = "$\(Float(tray.qty) * tray.meal.price!)"
        
        return cell
    }
}

extension TrayViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textFieldAddress.resignFirstResponder()
        
        if let address = textFieldAddress.text{
            if address != ""{
                Tray.currentTray.address = address
                let geocoder = CLGeocoder()
                
                geocoder.geocodeAddressString(address, completionHandler: {
                    (placemarks, error) in
                    
                    if (error != nil){
                        print(error!.localizedDescription)
                    }
                    
                    if let placemark = placemarks?.first{
                        
                        let coordinate = placemark.location?.coordinate
                        
                        let region = MKCoordinateRegionMake(coordinate!, MKCoordinateSpanMake(0.01, 0.01))
                        self.map.setRegion(region, animated: true)
                        self.locationManager?.stopUpdatingLocation()
                        
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate!
                        self.map.addAnnotation(annotation)
                    }
                })
            }
        }
        
        return true
    }
}
