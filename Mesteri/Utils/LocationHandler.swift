//
//  LocationHandler.swift
//  Mesteri
//
//  Created by George Fuior on 06/05/2020.
//  Copyright © 2020 George Fuior. All rights reserved.
//

import CoreLocation

class LocationHandler: NSObject, CLLocationManagerDelegate{
    
    static let shared = LocationHandler()
    var locationManager: CLLocationManager!
    var location: CLLocation?
    
    override init(){
        super.init()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            locationManager.requestAlwaysAuthorization()
        }
    }
    
}
