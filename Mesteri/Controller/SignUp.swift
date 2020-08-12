//
//  SignUp.swift
//  Mesteri
//
//  Created by George Fuior on 29/04/2020.
//  Copyright © 2020 George Fuior. All rights reserved.
//

import UIKit
import Firebase

class SignUpController: UIViewController{
    
    //MARK: - Proprieties
    
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
        sc.selectedSegmentIndex = 0
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
        navigationController?.popViewController(animated: true)
    }
    @objc func handleSignUp(){
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        guard let fullname = fullNameTextField.text else {return}
        let accountTypeIndex = accountTypeSegmentedControl.selectedSegmentIndex
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error{
                print("Failed to register user with error \(error)")
                return
            }
            
            guard let uid = result?.user.uid else {return}
            
            let values = ["email": email,
                          "fullname" : fullname,
                          "accountTypeIndex" : accountTypeIndex] as [String : Any]
            
            Database.database().reference().child("users").child(uid).updateChildValues(values) { (error, ref) in
                print("Succesfully registred user and saved data...")
            }
        }
        
    }
    
    @objc func handleSwitchAccount(sender: UISegmentedControl){
        let index = sender.selectedSegmentIndex
        switch index {
        case 0:
            print("User")
            break
        case 1:
            print("Mester")
            break
        default:
            break
        }
    }
    
    //MARK: - Helper
    
    func configureUI(){
        
        view.backgroundColor = .backgroundColor
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        titleLabel.centerX(inView: view)
        
        view.addSubview(accountTypeContainerView)
        accountTypeContainerView.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16)
        
        configureUIStackUser()
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)
        
    }
    func configureUIStackUser(){
        let stack = UIStackView(arrangedSubviews: [emailContainerView,
                                                   fullNameContainerView,
                                                   passwordContainerView,
                                                   signupButton])
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 24
        view.addSubview(stack)
        stack.anchor(top: accountTypeContainerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16)
        
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

