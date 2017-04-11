//
//  ViewController.swift
//  WeatherReport
///Users/apple/Downloads/SwiftyJSON/SwiftyJSON.xcodeproj
//  Created by Apple on 10/04/2017.
//  Copyright © 2017 me. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblTemperature: UILabel!
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var lblReport: UILabel!
    @IBOutlet weak var imvIcon: UIImageView!
    
    let locationManager = CLLocationManager()
    var latLong = "37.8267,-122.4233"
    
    fileprivate let apiKey = "979ab2a64385bec77a41993a36cad809"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        findMyLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTapRefresh(_ sender: UIButton) {
        rotateAnyView(view: self.refreshButton, formValue: 0, toValue: Float(M_PI * 4), duration: 2)
        
        findMyLocation()
    }
    
    func rotateAnyView(view: UIView, formValue: Double, toValue: Float, duration: Double = 1) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.duration = duration
        animation.fromValue = formValue
        animation.toValue = toValue
        view.layer.add(animation, forKey: nil)
    }
    
    func findMyLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        
        // Here we start locating
        locationManager.startUpdatingLocation()
        
        //getGeoCode(latLong: latLong)
    }
    
    func getGeoCode(latLong: String) {
        
        let geoUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latLong)&sensor=true"
        Alamofire.request(geoUrl).responseJSON { response in
            print(self.latLong)
            if let jsonData = response.result.value {
                //print("JSON: \(jsonData)")
                let json = JSON(data: response.data!)
                //print("JSON: \(json)")
                
                guard let geoCode = json["results"][1]["formatted_address"].string else {
                    //Now you got your value
                    print("no data")
                    return
                }
                
                print("*************",geoCode)
                self.lblCity.text = geoCode
                
            }
        }
    }
    
    func loadJsonForecast(url: String) {
        Alamofire.request(url).responseJSON { response in
            print(self.latLong)
            if let jsonData = response.result.value {
                //print("JSON: \(jsonData)")
                let json = JSON(data: response.data!)
                //print("JSON: \(json)")
                guard let daily = json["currently"]["apparentTemperature"].double else {
                    //Now you got your value
                    print("no data")
                    return
                }
                
                guard let time = json["currently"]["time"].int else {
                    //Now you got your value
                    print("no time data")
                    return
                }
                
                guard let report = json["currently"]["summary"].string else {
                    //Now you got your value
                    print("no report")
                    return
                }
                
                guard let icon = json["currently"]["icon"].string else {
                    //Now you got your value
                    print("no report")
                    return
                }
                
                self.lblTemperature.text = "\(Int(round(daily)))°"
                
                let date = NSDate(timeIntervalSince1970: Double(time))
                let dayTimePeriodFormatter = DateFormatter()
                dayTimePeriodFormatter.locale = Locale(identifier: "fr_FR")
                dayTimePeriodFormatter.dateFormat = "dd MMM YYYY hh:mm a"
                
                let dateString = dayTimePeriodFormatter.string(from: date as Date)
                
                self.lblDateTime.text = "\(dateString)"
                self.lblReport.text = report
                self.imvIcon.image = UIImage(named: icon)
            }
        }
    }
    
}


// We adopt the CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        for location in locations {
            self.latLong = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
            print("THIS IS THE LOCATION \(self.latLong)")
        }
        
        let reportUrl = "https://api.darksky.net/forecast/\(self.apiKey)/\(self.latLong)?units=auto&lang=fr"
        
        self.loadJsonForecast(url: reportUrl)
        
        getGeoCode(latLong: latLong)
        
        // This will stop updating the location.
        locationManager.stopUpdatingLocation()
    }
}

