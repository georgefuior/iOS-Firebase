//
//  JobDetailsController.swift
//  Mesteri
//
//  Created by George Fuior on 05/05/2020.
//  Copyright © 2020 George Fuior. All rights reserved.
//

import UIKit
import GeoFire
import CoreLocation
import Firebase

class JobDetailsController: UIViewController {
    
    
    //MARK: - Proprieties
    
    
    private let searchMesterView = SearchMesterView()
    private let locationManager = LocationHandler.shared.locationManager
    
    private lazy var jobTitleContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: jobTitleTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let jobTitleTextField: UITextField = {
        return  UITextField().anyTextField(withPlaceholder: "Denumirea lucrării", isSecureTextEntry: false)
    }()
    
    private lazy var jobDescriptionContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: jobDescriptionTextField)
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        return view
    }()
    
    private let jobDescriptionTextField: UITextField = {
        return  UITextField().anyTextField(withPlaceholder: "Descrierea detaliată a lucrării", isSecureTextEntry: false)
    }()
    private lazy var selectMesterContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: selectMesterTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let selectMesterTextField: UITextField = {
        return  UITextField().anyTextField(withPlaceholder: "Selectează tipul de meșter dorit", isSecureTextEntry: false)
    }()
    private lazy var selectTimeContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: selectTimeTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let selectTimeTextField: UITextField = {
        return  UITextField().anyTextField(withPlaceholder: "Selectează data si ora lucrarii", isSecureTextEntry: false)
    }()
    
    private let sendJob: UIButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Trimite lucrarea", for: .normal)
        button.backgroundColor = .mainBlackTint
        button.setTitleColor(UIColor(white: 1, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleJobSend), for: .touchUpInside)
        return button
    }()
    
    
    
    private let picker  = UIPickerView()
    private let data = ["Instalator","Zugrav","Electrician","Altul"]
    
    private let datePicker = UIDatePicker()
    
    private var user: User? {
        didSet {searchMesterView.user = user}
    }
    private var selectedUser = User()
    private var job: Job? {
        didSet{
            guard let job = job else {return}
            if job.state == .isRequested{
            let controller = ListOffersController(job: job)
                controller.modalPresentationStyle = .fullScreen
                controller.delegate = HomeController()
             self.present(controller, animated: true, completion: nil)
            }
        }
    }
    private var offer: Offer?
    //{
//         didSet{
//             guard let offer = offer else {return}
//                guard let job = job else {return}
//                let controller = ListOffersController(offer: offer, job: job)
//             controller.modalPresentationStyle = .fullScreen
//            // controller.delegate = self
//             self.present(controller, animated: true, completion: nil)
//
//         }
//     }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = .white
        createDatePicker()
        configurePickerView()
        configureSearchMesterView()
        fetchUserData()
        observeClientJob()
        configureUIStackMester()
        print("DEBUG: Selected mester: \(selectedUser.fullname)")
        
    }
    
    //MARK: - Helper functions
    
    
    func configureSearchMesterView(){
        searchMesterView.delegate = self
        view.addSubview(searchMesterView)
        searchMesterView.displayTextField.attributedPlaceholder = NSAttributedString(string: "Locația lucrării (implicit: Locația curentă)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        searchMesterView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 130)
        UIView.animate(withDuration: 0.5, animations: {
            self.searchMesterView.alpha = 1
        }) { _ in
            
        }
        didComeFromListController()
    }
    func configureUIStackMester(){
        let stack = UIStackView(arrangedSubviews: [jobTitleContainerView ,
                                                   jobDescriptionContainerView,
                                                   selectMesterContainerView,
                                                   selectTimeContainerView])
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 40
        view.addSubview(stack)
        stack.anchor(top: searchMesterView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16)
        
        
        view.addSubview(sendJob)
        sendJob.anchor( left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 40, paddingBottom: -30, paddingRight: 40)
    }
    
    func configurePickerView(){
        picker.delegate = self
        picker.dataSource = self
        selectMesterTextField.inputView = picker
    }
    
    func createDatePicker(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneBtn], animated: true)
        selectTimeTextField.inputAccessoryView = toolbar
        
        selectTimeTextField.inputView = datePicker
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.minuteInterval = 15
        datePicker.minimumDate = Date()
        
    }
    
    func didComeFromListController(){
        if (MesteriListController.comeFromListController == true){
            self.selectedUser = MesteriListController.selectedUser
            MesteriListController.comeFromListController = false
        }
    }
    
    func uploadJobData(){
        guard let jobCoordinates = locationManager?.location?.coordinate else {return}
        guard let jobTitle = jobTitleTextField.text else {return}
        guard let jobDescription = jobDescriptionTextField.text else {return}
        guard let timeJob = selectTimeTextField.text else {return}
        guard let typeMester = selectMesterTextField.text else {return}
        guard (user?.uid) != nil else {return}
        let preferredMester = selectedUser.uid
        
        let values = ["jobTitle": jobTitle,
                      "jobDescription" : jobDescription,
                      "timeJob": timeJob,
                      "typeMester" : typeMester,
                      "preferredMester": preferredMester] as [String : Any]
        Service.shared.uploadJob(secondValues:values,_jobCoordinates: jobCoordinates) { (err, ref) in
            if let error = err {
                print ("DEBUG: Failed to upload job with error \(error)")
                return
            }
        }

    }
    func observeClientJob(){
         guard let uid = Auth.auth().currentUser?.uid else {return}
         Service.shared.observeMyJobs { job in
            if job.clientUid == uid {
                self.job = job
            }
        }
    }
    
    
    //MARK: - Selectors
    
    
    @objc func handleJobSend(){
        
        uploadJobData()
      
    }
    @objc func donePressed(){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MM yyyy - hh:mm a "
        
        selectTimeTextField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    //MARK: - API
    func fetchUserData(){
        Service.shared.fetchUserData() { user in
            self.user = user
        }
    }
}



//MARK: - SearchMesterViewDelegate

extension JobDetailsController: SearchMesterViewDelegate{
    func executeSearch(query: String) {
        
    }
    
    func handleTapButton() {
        let  controller = HomeController()
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
        
    }
}

//MARK: - PickerViewDelegate


extension JobDetailsController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row]
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectMesterTextField.text = data[row]
        self.view.endEditing(true)
    }
    
}
