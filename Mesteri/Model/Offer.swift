//
//  Offer.swift
//  Mesteri
//
//  Created by George Fuior on 12/05/2020.
//  Copyright © 2020 George Fuior. All rights reserved.
//
enum OfferState: Int {
    case sent
    case accepted
    case rejected
}

struct Offer{
    let mesterWhoOfferedUid: String?
    let offer: Double?
    let jobId: String?
    var state: OfferState!
    


    init(jobId: String, mesterWhoOfferedUid: String,dictionary: [String:Any]){
        self.jobId = jobId
        self.mesterWhoOfferedUid = mesterWhoOfferedUid
        self.offer = dictionary["offerAmount"] as? Double
        if let state = dictionary["state"] as? Int {
                   self.state = OfferState(rawValue: state)
               }
       
    }
}
