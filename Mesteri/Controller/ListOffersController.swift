//
//  ListOffersController.swift
//  Mesteri
//
//  Created by George Fuior on 16/05/2020.
//  Copyright © 2020 George Fuior. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

protocol  ListOffersControllerDelegate: class{
   func didAcceptOffer(offer: Offer, _ job: Job)
}


private let reuseIdentifier = "Offer Cell"
class ListOffersController: UIViewController{
    
    
    //MARK: - Proprieties
    static var selectedMesterForJob: User?
    private let table = UITableView()
    private var job: Job
    private var offer: Offer?
    private let locationManager = LocationHandler.shared.locationManager
    private var jobList = [Job]()
    private var offerList = [Offer]()
    private var mesteriList = [User]()
    var delegate: ListOffersControllerDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Thonburi-Bold",size: 24)
        label.text = "Ofertele pentru lucrarile tale"
        return label
    }()
    private let rejectOffersButton: UIButton = {
          let button = UIButton()
          button.backgroundColor = .black
          button.setTitle("REFUZĂ OFERTELE", for: .normal)
          button.setTitleColor(.white, for: .normal)
          button.addTarget(self, action: #selector(rejectButtonPressed), for: .touchUpInside)
          
          return button
      }()
    
    //MARK: - Lifecycle
    
    init(job: Job){
        self.job = job
        jobList.append(self.job)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        fetchOffers(job: self.job){
            self.shouldPresentLoadingView(false)
            self.configureTableView()
            self.configureButton()
            self.table.reloadData()
        }
        configureBasicUI()
    }
    
    //MARK: - Selectors
    
    @objc func rejectButtonPressed(){
        for offer in offerList {
            Service.shared.rejectOtherOffers(offer: offer, job: job) { (eror, ref) in
            }
        }
        Service.shared.deleteJob(job: job)
        let  controller = HomeController()
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    //MARK: - Helper Functions
    
    func fetchOffers(job: Job,completion: @escaping ()->Void){
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        REF_Jobs.child(uid).child(job.jobUid).child("offers").observe(.childAdded) { (snapshot) in
            let mesterId = snapshot.key
            self.offerList.append(Offer(jobId: self.job.jobUid, mesterWhoOfferedUid: mesterId,dictionary: snapshot.value as! [String : Any]))
            REF_USERS.child(snapshot.key).observe(.value) { (snapshot) in
                guard  let dictionary = snapshot.value as? [String: Any] else {return}
                self.mesteriList.append(User(uid:mesterId, dictionary: dictionary))
                completion()
            }
        }
    }
    func configureBasicUI(){
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 30)
        titleLabel.centerX(inView: view)
        shouldPresentLoadingView(true, message: "În căutarea unui meșter pentru lucrarea ta")
    }
        func configureTableView(){
        view.addSubview(table)
        table.dataSource = self
        table.delegate = self
        table.register(OfferCell.self, forCellReuseIdentifier: reuseIdentifier)
        table.rowHeight = 55
        let height = view.frame.height
        table.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        table.tableFooterView = UIView()
        self.table.frame.origin.y = 130
    }
    func configureButton(){
        view.addSubview(rejectOffersButton)
        rejectOffersButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor,
                                  paddingLeft: 12, paddingBottom: -18, paddingRight: 12, height: 50)
    }
}


    //MARK: - Delegate

extension ListOffersController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        for job in jobList{
            return "\(job.jobTitle)"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mesteriList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,for: indexPath) as!
               OfferCell
      
        cell.numeMester.text = mesteriList[indexPath.row].fullname
        cell.ocupatieMester.text = mesteriList[indexPath.row].meserie
        cell.offer.text = "\(offerList[indexPath.row].offer ?? 0.0) RON"
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        jobList.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ListOffersController.selectedMesterForJob = mesteriList[indexPath.row]
        print("DEBUG: Selected mester: \(ListOffersController.selectedMesterForJob?.fullname)")
        for (index, offer) in offerList.enumerated() {
            if index == indexPath.row {
                Service.shared.acceptOfferForJob(offer: offer, job: job) { (eror, ref) in
                }
                job.state = .isAccepted
            } else {
                Service.shared.rejectOtherOffers(offer: offer, job: job) { (eror, ref) in
                }
            }
        }
        print("DEBUG Selected offer: \(self.offerList[indexPath.row])")
        self.offer = self.offerList[indexPath.row]
        let  controller = HomeController()
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true){
        self.delegate?.didAcceptOffer(offer: self.offerList[indexPath.row], self.job)
        }
    }
} 
