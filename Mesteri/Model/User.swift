//
//  User.swift
//  Mesteri
//
//  Created by George Fuior on 04/05/2020.
//  Copyright © 2020 George Fuior. All rights reserved.
//

import CoreLocation

struct User{
    let fullname: String
    let email: String
    let accountType: Int
    var location: CLLocation?
    let meserie: String?
    let uid: String
    
    init(uid: String, dictionary: [String: Any]){
        self.uid = uid
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.accountType = dictionary["accountTypeIndex"] as? Int ?? -1
        self.meserie = dictionary["meserie"] as? String ?? ""
        
    }
    init(){
        self.uid = ""
        self.email = ""
        self.accountType = -1
        self.fullname = ""
        self.meserie = ""
    }
}
