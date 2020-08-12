//
//  Service.swift
//  Mesteri
//
//  Created by George Fuior on 04/05/2020.
//  Copyright © 2020 George Fuior. All rights reserved.
//

import Firebase
import CoreLocation
import GeoFire

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_Mester_Locations = DB_REF.child("mester-locations")
let REF_Jobs = DB_REF.child("jobs")
let REF_Jobs_Locations = DB_REF.child("job-locations")

struct Service{
    
    static let shared = Service()
    func fetchUserData(uid: String, completion: @escaping(User) -> Void){
        
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary =  snapshot.value as? [String: Any] else {return}
            let uid = snapshot.key
            let user = User(uid: uid,dictionary: dictionary)
            completion(user)
            
        }
    }
    func fetchUserData(completion: @escaping(User) -> Void){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        REF_USERS.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary =  snapshot.value as? [String: Any] else {return}
            let uid = snapshot.key
            let user = User(uid:uid, dictionary: dictionary)
            
            completion(user)
            
        }
    }
    
    func fetchMesteri(location: CLLocation, completion: @escaping(User)->Void){
        let geofire = GeoFire(firebaseRef: REF_Mester_Locations)
        
        REF_Mester_Locations.observe(.value){ (snapshot) in
            geofire.query(at: location, withRadius: 10).observe(.keyEntered,with: {(uid,location)in
                self.fetchUserData(uid: uid) { (user) in
                    var mester = user
                    mester.location = location
                    completion(mester)
                }
            })
        }
    }
    
    
    func uploadJob(secondValues: [String: Any],_jobCoordinates: CLLocationCoordinate2D, completion: @escaping(Error?, DatabaseReference) -> Void) {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let jobArray = [_jobCoordinates.latitude,_jobCoordinates.longitude]
        var values = ["jobCoordinates" : jobArray,
                      "serviceCost": 0.0,
                      "state": JobState.isRequested.rawValue] as [String : Any]
        
        values.merge(dict: secondValues)
        let refKey = REF_Jobs.child(uid).childByAutoId()
        refKey.updateChildValues(values, withCompletionBlock: completion)
        refKey.observeSingleEvent(of: .value) { snapshot in
            let geofire = GeoFire(firebaseRef: REF_Jobs_Locations)
            geofire.setLocation(CLLocation(latitude: _jobCoordinates.latitude, longitude: _jobCoordinates.longitude), forKey: snapshot.key) { (error) in
            }
        }
        
    }
    
    func observeJobs(location: CLLocation, completion: @escaping(Job)->Void){
        let geofire = GeoFire(firebaseRef: REF_Jobs_Locations)
        geofire.query(at: location, withRadius: 10).observe(.keyEntered,with: {(uid,location)in
            let jUid = uid
            REF_Jobs.queryLimited(toLast: 1).observe(.childAdded) { snapshot in
                guard  let dictionary = snapshot.value as? [String: Any] else {return}
                for (id,finalDictionary) in dictionary  {
                    if id == jUid {
                        let job = Job(clientUid: snapshot.key, jobUid: jUid, dictionary: finalDictionary as! [String : Any] )
                        completion(job)
                    }
                }
            }
        })
    }
    func observeLastJobAdded(location: CLLocation, completion: @escaping(Job)->Void){
        let geofire = GeoFire(firebaseRef: REF_Jobs_Locations)
        geofire.query(at: location, withRadius: 10).observe(.keyEntered,with: {(uid,location)in
            let jUid = uid
            REF_Jobs.queryLimited(toLast: 1).observe(.childAdded) { (snapshot) in
                let cUid = snapshot.key
                print("DEBUG: Client Id: \(cUid)")
                REF_Jobs.child(cUid).queryLimited(toLast: 1).observe(.childAdded) { (snapshot) in
                    let jobId = snapshot.key
                    print("DEBUG: Job Id: \(jobId)")
                    if jobId == jUid {
                        guard  let dictionary = snapshot.value as? [String: Any] else {return}
                        let job = Job(clientUid: cUid, jobUid: jobId, dictionary: dictionary)
                        print("DEBUG: Job Title: \(job.jobTitle)")
                        completion(job)
                    }
                }
            }
        })
    }
    
    func sendJobQuotation(quotation: Double, job: Job, completion: @escaping(Error?, DatabaseReference)-> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let values = ["state": JobState.isQuoted.rawValue]
        REF_Jobs.child(job.clientUid).child(job.jobUid).updateChildValues(values, withCompletionBlock: completion)
        let offers = ["offerAmount" : quotation,
                      "state": OfferState.sent.rawValue] as [String: Any]
               
        REF_Jobs.child(job.clientUid).child(job.jobUid).child("offers").child(uid).updateChildValues(offers, withCompletionBlock: completion)
       
    }

    func observeMyJobs(completion: @escaping (Job)->Void){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        REF_Jobs.child(uid).observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let job = Job(clientUid: uid, jobUid: snapshot.key, dictionary: dictionary)
            completion(job)
        }
    }
    
    func observeMyOffer(job: Job, completion: @escaping (Offer)->Void){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        REF_Jobs.child(job.clientUid).child(job.jobUid).child("offers")
            .child(uid).observe(.value) { snapshot in
            guard let dictionary =  snapshot.value as? [String: Any] else {return}
                completion(Offer(jobId: job.jobUid, mesterWhoOfferedUid: uid, dictionary: dictionary))
        }
    }

    func acceptOfferForJob(offer: Offer, job: Job, completion: @escaping(Error?, DatabaseReference) -> Void){
        let values = ["mesterUid":offer.mesterWhoOfferedUid ?? "",
                      "state": JobState.isAccepted.rawValue,
                      "serviceCost": offer.offer ?? 0.0] as [String: Any]
        REF_Jobs.child(job.clientUid).child(job.jobUid).updateChildValues(values, withCompletionBlock: completion)
        REF_Jobs.child(job.clientUid).child(job.jobUid).child("offers")
            .child(offer.mesterWhoOfferedUid ?? "").updateChildValues(["state": OfferState.accepted.rawValue])
    }
    
    func rejectOtherOffers(offer: Offer, job: Job, completion: @escaping(Error?, DatabaseReference)->Void){
        REF_Jobs.child(job.clientUid).child(job.jobUid).child("offers")
        .child(offer.mesterWhoOfferedUid ?? "").updateChildValues(["state": OfferState.rejected.rawValue])
    }
    
    func observeResultStatusOfOffers(job:Job, completion: @escaping(Bool)->Void){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        REF_Jobs.child(job.clientUid).child(job.jobUid).child("offers").child(uid).child("status").queryEqual(toValue: 2).observe(.value) { snapshot in
            print("DEBUG: \(snapshot)")
            completion(true)
        }
    }
    
    func deleteJob(job: Job) {
        REF_Jobs.child(job.clientUid).child(job.jobUid).removeValue()
        REF_Jobs_Locations.child(job.jobUid).removeValue()
    }
}
extension Dictionary {
    mutating func merge( dict: [Key: Value]){
        for (k,v) in dict {
            updateValue(v, forKey: k)
        }
    }
}
