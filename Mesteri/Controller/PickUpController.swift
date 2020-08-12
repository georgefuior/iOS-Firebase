//
//  PickUpController.swift
//  Mesteri
//
//  Created by George Fuior on 11/05/2020.
//  Copyright © 2020 George Fuior. All rights reserved.
//

import UIKit
import MapKit

protocol  PickUpControllerDelegate: class {
    func didSendOffer (_ job: Job)
}
class PickUpController: UIViewController{
    
    //MARK: - Proprieties
    
    weak var delegate: PickUpControllerDelegate?
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    var job: Job
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    }()
    
    private let pickupLabel: UILabel = {
        let label = UILabel()
        label.text = "Vrei să faci o oferta pentru această lucrare?"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    private let mesterLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    private let sendQuotationButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleSendQuotation), for: .touchUpInside)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("TRIMITE OFERTA", for: .normal)
        
        return button
    }()
    private lazy var quotationContainerView: UIView = {
        let view = UIView().inputContainerView(textField: quotationTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        view.backgroundColor = .white
        return view
    }()
    
    
    private let quotationTextField: UITextField = {
        return  UITextField().anyTextField(withPlaceholder: "Oferta ta", isSecureTextEntry: false)
    }()
    
    //MARK: - Lifecycle
    
    init(job: Job){
        self.job = job
        super.init(nibName: nil, bundle: nil)
        guard let location = locationManager?.location  else {return}
        Service.shared.observeLastJobAdded(location: location) { job in
                self.titleLabel.text = job.jobTitle
                self.descriptionLabel.text = job.jobDescription
                self.mesterLabel.text = job.typeMester
                self.timeLabel.text = job.timeJob
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureMapView()
        
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    //MARK: - Selectors
    
    @objc func handleDismissal(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleSendQuotation(){
        guard let quotation = Double(quotationTextField.text!)   else {return}
        Service.shared.sendJobQuotation(quotation: quotation, job: job) { (error, ref) in
            self.delegate?.didSendOffer( self.job)
            self.dismiss(animated: true, completion: nil)
         
        }
    }
    //MARK: - API
    
    //MARK: - Helper functions
    
    func configureMapView(){
        let region = MKCoordinateRegion(center: job.jobCoordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: false)
        
        let anno = MKPointAnnotation()
        anno.coordinate = job.jobCoordinates
        mapView.addAnnotation(anno)
        self.mapView.selectAnnotation(anno, animated: true)
        
    }
    
    func configureUI(){
        view.backgroundColor = .backgroundColor
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.safeAreaLayoutGuide.topAnchor,left: view.leftAnchor, paddingTop: 20,paddingLeft: 16)
        
        view.addSubview(mapView)
        mapView.setDimensions(height: 270, width: 270)
        mapView.layer.cornerRadius = 270 / 2
        mapView.centerX(inView: view)
        mapView.centerY(inView: view, constant: -150)
        
        view.addSubview(pickupLabel)
        pickupLabel.centerX(inView: view)
        pickupLabel.anchor(top: mapView.bottomAnchor, paddingTop: 16)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel ,
                                                   descriptionLabel,
                                                   mesterLabel,
                                                   timeLabel])
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 15
       
        view.addSubview(stack)
        stack.anchor(top: pickupLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16)
        view.addSubview(quotationContainerView)
        quotationContainerView.anchor(top: stack.bottomAnchor,paddingTop: 16)
        quotationTextField.centerX(inView: quotationContainerView)
        quotationTextField.anchor(left:  quotationContainerView.leftAnchor, right: quotationContainerView.rightAnchor, paddingLeft: 8, paddingRight: 8)
        
        quotationContainerView.centerX(inView: view)
        
        view.addSubview(sendQuotationButton)
        sendQuotationButton.anchor(top: quotationContainerView.bottomAnchor, left: view.leftAnchor,
                                   right: view.rightAnchor, paddingTop: 16, paddingLeft: 32,
                                   paddingRight: 32, height: 50)

        
    }
}
