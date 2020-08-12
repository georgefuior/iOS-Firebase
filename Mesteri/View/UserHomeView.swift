//
//  UserHomeView.swift
//  Mesteri
//
//  Created by George Fuior on 08/06/2020.
//  Copyright © 2020 George Fuior. All rights reserved.
//

import UIKit

protocol UserHomeViewDelegate: class {
    func handleCautaMester()
    func handlePublicaLucrare()
}

class UserHomeView: UIView {

    //MARK: - Proprieties
    
    weak var delegate: UserHomeViewDelegate?
    
    var user: User? {
        didSet {
            welcomeLabel.text = "Bine ai venit, \(user?.fullname ?? "")!"
            UIView.animate(withDuration: 0.3, animations: {
                self.separatorView.alpha = 0
            }) {_ in
                UIView.animate(withDuration: 0.3) {
                    self.separatorView.alpha = 1
                }
            }
            welcomeLabel.text = "Bine ai venit, \(user?.fullname ?? "")!"
        }
    }
    
    private let welcomeLabel: UILabel = {
          let label = UILabel()
          label.font = UIFont(name: "Thonburi-Bold",size: 24)
          
          return label
      }()
  
        private let separatorView = UIView()
      
      private let cautaMester: UIButton = {
          let button = AuthButton(type: .system)
          button.setTitle("Caută un meșter", for: .normal)
          button.backgroundColor = .mainBlackTint
          button.setTitleColor(UIColor(white: 1, alpha: 1), for: .normal)
          button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
          button.addTarget(self, action: #selector(handleCautaMester), for: .touchUpInside)
          return button
      }()
      
      private let publicaLucrare: UIButton = {
          let button = AuthButton(type: .system)
          button.setTitle("Publică o lucrare", for: .normal)
          button.backgroundColor = .mainBlackTint
          button.setTitleColor(UIColor(white: 1, alpha: 1), for: .normal)
          button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
          button.addTarget(self, action: #selector(handlePublicaLucrare), for: .touchUpInside)
          return button
      }()
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addShadow()
        configureBottomHalfView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helper functions
        func configureBottomHalfView(){
            addSubview(welcomeLabel)
            welcomeLabel.anchor(top:self.safeAreaLayoutGuide.topAnchor,paddingTop: 20)
            welcomeLabel.centerX(inView: self)
            addSubview(separatorView)
            separatorView.backgroundColor = .lightGray
            separatorView.anchor(top: welcomeLabel.bottomAnchor,left: self.leftAnchor,
                                 right: self.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingRight: 8,height: 0.75)
            separatorView.alpha = 0
            let stack = UIStackView(arrangedSubviews: [cautaMester,
                                                       publicaLucrare,])
            stack.axis = .vertical
            stack.distribution = .fillEqually
            stack.spacing = 24
            
            addSubview(stack)
            stack.anchor(top: welcomeLabel.bottomAnchor, left: self.leftAnchor, right: self.rightAnchor, paddingTop: 80, paddingLeft: 16, paddingRight: 16)
    }
    
    //MARK: - Selectors
    
    @objc func handleCautaMester(){
        delegate?.handleCautaMester()         
     }
     @objc func handlePublicaLucrare(){
        delegate?.handlePublicaLucrare()
     }
    
}
