//
//  JobAnnotation.swift
//  Mesteri
//
//  Created by George Fuior on 11/05/2020.
//  Copyright © 2020 George Fuior. All rights reserved.
//


import MapKit

class JobAnnotation: NSObject, MKAnnotation{
    dynamic var coordinate: CLLocationCoordinate2D
    var uid: String
    
    init(uid: String, coordinate: CLLocationCoordinate2D){
        self.uid = uid
        self.coordinate = coordinate
    }
    
    func updateAnnotationPosition(withCoordinate coordinate: CLLocationCoordinate2D){
        UIView.animate(withDuration: 0.2){
            self.coordinate = coordinate
        }
    }
}

