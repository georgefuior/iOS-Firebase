//
//  File.swift
//  Mesteri
//
//  Created by George Fuior on 10/05/2020.
//  Copyright © 2020 George Fuior. All rights reserved.
//

import CoreLocation

enum JobState: Int{
    
    case notPublished
    case isRequested
    case isQuoted
    case isAccepted
    case inProgress
    case isCompleted
}

enum JobPlanned: Int {
    case urgent
    case planned
}

struct Job {
    var jobCoordinates: CLLocationCoordinate2D!
    let clientUid: String!
    let jobUid: String!
    var jobTitle: String
    var jobDescription: String
    var timeJob: String
    var typeMester: String
    let preferredMesterUid: String
    var serviceCost: Double
    
    var mesterUid: String?
    var state: JobState!
    var urgency: JobPlanned!
    
    init(clientUid: String,jobUid: String, dictionary: [String:Any]){
        self.clientUid = clientUid
        self.jobUid = jobUid
        
        self.mesterUid = dictionary["mesterUid"] as? String ?? ""
        self.jobTitle = dictionary["jobTitle"] as? String ?? ""
        self.jobDescription = dictionary["jobDescription"] as? String ?? ""
        self.timeJob = dictionary["timeJob"] as? String ?? ""
        self.typeMester = dictionary["typeMester"] as? String ?? ""
        self.preferredMesterUid = dictionary["preferredMester"] as? String ?? ""
        self.serviceCost = dictionary["serviceCost"] as? Double ?? 0.0
        if let jobCoordinates = dictionary["jobCoordinates"] as? NSArray {
            guard let lat = jobCoordinates[0] as? CLLocationDegrees else {return}
            guard let long = jobCoordinates[1] as? CLLocationDegrees else {return}
            self.jobCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        if let state = dictionary["state"] as? Int {
            self.state = JobState(rawValue: state)
        }
        if let urgency = dictionary["urgency"] as? Int {
            self.urgency = JobPlanned(rawValue: urgency)
        }
    }
    
    init(clientUid: String, dictionary: [String : Any]){
        self.clientUid = clientUid
        self.jobUid = ""
        
        self.mesterUid = dictionary["mesterUid"] as? String ?? ""
        self.jobTitle = dictionary["jobTitle"] as? String ?? ""
        self.jobDescription = dictionary["jobDescription"] as? String ?? ""
        self.timeJob = dictionary["timeJob"] as? String ?? ""
        self.typeMester = dictionary["typeMester"] as? String ?? ""
        self.preferredMesterUid = dictionary["preferredMester"] as? String ?? ""
        self.serviceCost = dictionary["serviceCost"] as? Double ?? 0.0
        
        if let jobCoordinates = dictionary["jobCoordinates"] as? NSArray {
            guard let lat = jobCoordinates[0] as? CLLocationDegrees else {return}
            guard let long = jobCoordinates[1] as? CLLocationDegrees else {return}
            self.jobCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        if let state = dictionary["state"] as? Int {
            self.state = JobState(rawValue: state)
        }
        if let urgency = dictionary["urgency"] as? Int {
                 self.urgency = JobPlanned(rawValue: urgency)
             }
    }
}




