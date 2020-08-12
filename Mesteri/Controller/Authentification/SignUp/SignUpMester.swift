//
//  SignUp.swift
//  Mesteri
//
//  Created by George Fuior on 29/04/2020.
//  Copyright © 2020 George Fuior. All rights reserved.
//

import UIKit
import Firebase
import GeoFire

class SignUpMesterController: UIViewController{
    
    //MARK: - Proprieties
    
    
    private var location = LocationHandler.shared.locationManager.location
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Meșterii tăi"
        label.font = UIFont(name: "Avenir-Light",size: 36)
        label.textColor = UIColor(white: 1, alpha: 0.8)
        return label
    }()
    
    private lazy var emailContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_mail_outline_white_2x"), textField: emailTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    private lazy var fullNameContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: fullNameTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var passwordContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passwordTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
        
    }()
    private lazy var jobContainerView: UIView = {
           let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_highlight_off_white_3x"), textField: jobTextField)
           view.heightAnchor.constraint(equalToConstant: 50).isActive = true
           return view
           
       }()
    
    private lazy var accountTypeContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_account_box_white_2x"), segmentedControl: accountTypeSegmentedControl)
        view.heightAnchor.constraint(equalToConstant: 80).isActive  = true
        return view
        
    }()
    
    private let emailTextField: UITextField = {
        return  UITextField().textField(withPlaceholder: "Email", isSecureTextEntry: false)
    }()
    private let fullNameTextField: UITextField = {
        return  UITextField().textField(withPlaceholder: "Nume complet", isSecureTextEntry: false)
    }()
    
    private let passwordTextField: UITextField = {
        return  UITextField().textField(withPlaceholder: "Parola", isSecureTextEntry: true)
    }()
    private let jobTextField: UITextField = {
           return  UITextField().textField(withPlaceholder: "Meserie", isSecureTextEntry: false)
       }()
    
    private let accountTypeSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Utilizator"," Meșter"])
        sc.backgroundColor = .backgroundColor
        sc.tintColor = UIColor(white: 1, alpha: 0.87)
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleSwitchAccount), for: .valueChanged)
        return sc
    }()
    
    private let signupButton: UIButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Înregistrare", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Ești deja înregistrat?   ", attributes:
            [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
             NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Autentificare ", attributes:
            [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16),
             NSAttributedString.Key.foregroundColor: UIColor.mainBlueTint]))
        
        button.addTarget(self, action: #selector(handleShowLogIn), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: - Selectors
    
    @objc func handleShowLogIn(){
        let controller = LoginController()
        navigationController?.pushViewController(controller, animated: true)
    }
    @objc func handleSignUp(){
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        guard let fullname = fullNameTextField.text else {return}
        guard let meserie = jobTextField.text else {return}
        let accountTypeIndex = accountTypeSegmentedControl.selectedSegmentIndex
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error{
                print("DEBUG: Failed to register user with error \(error.localizedDescription)")
                return
            }
            
            guard let uid = result?.user.uid else {return}
            
            let values = ["email": email,
                          "fullname" : fullname,
                          "meserie": meserie,
                          "accountTypeIndex" : accountTypeIndex] as [String : Any]
            
            
            if accountTypeIndex == 1 {
                 let geofire = GeoFire(firebaseRef: REF_Mester_Locations)
                guard let location = self.location else {return}
                geofire.setLocation(location, forKey: uid) { (error) in
                }
                
                self.UploadUserDataAndShowHomeController(uid: uid, values: values)
        
            }
     
        }
        
    }
    
    @objc func handleSwitchAccount(sender: UISegmentedControl){
        let index = sender.selectedSegmentIndex
        switch index {
        case 0:
            let controller = SignUpUserController()
            navigationController?.pushViewController(controller, animated: false)
            print("DEBUG: User")
            break
        case 1:
            let controller = SignUpMesterController()
            navigationController?.pushViewController(controller, animated: false)
            print("DEBUG: Mester")
            break
        default:
            break
        }
    }
    
    //MARK: - Helper
    
    func UploadUserDataAndShowHomeController(uid: String, values: [String: Any]){
        REF_USERS.child(uid).updateChildValues(values) { (error, ref) in
                    guard let controller = UIApplication.shared.keyWindow?.rootViewController as? HomeController
                        else {return}
                    controller.configure()
                    self.dismiss(animated: true, completion: nil)
                }
    }
    
    func configureUI(){
        
        view.backgroundColor = .backgroundColor
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        titleLabel.centerX(inView: view)
        
        view.addSubview(accountTypeContainerView)
        accountTypeContainerView.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16)
        
        
        configureUIStackMester()
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)
        
    }

    func configureUIStackMester(){
        let stack = UIStackView(arrangedSubviews: [emailContainerView,
                                                   fullNameContainerView,
                                                   jobContainerView,
                                                   passwordContainerView,
                                                   signupButton])
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 24
        view.addSubview(stack)
        stack.anchor(top: accountTypeContainerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16)
    }
    
}

