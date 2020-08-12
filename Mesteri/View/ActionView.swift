//
//  ActionView.swift
//  Mesteri
//
//  Created by George Fuior on 23/05/2020.
//  Copyright © 2020 George Fuior. All rights reserved.
//

import UIKit
import MapKit

protocol ActionViewDelegate: class {
    func handleTapButton()
}
enum JobActionViewConfiguration {
    case offerAccepted
    case offerRejected
    case mesterArrived
    case jobInProgress
    case endJob
    
    init() {
        self = .offerAccepted
    }
}

enum ButtonAction: CustomStringConvertible {
    case cancel
    case getDirections
    case mesterArrived
    case jobFinished
    
    var description: String {
        switch self {
        case .cancel: return "ANULEAZA LUCRAREA"
        case .getDirections: return "PORNESTE"
        case .mesterArrived: return "AM AJUNS"
        case .jobFinished: return "FINALIZARE LUCRARE"
            
        }
    }
    init() {
        self = .getDirections
    }
}

class ActionView: UIView {
    
    
    //MARK: - Proprieties
    
    var job: Job? {
        didSet {
            titleLabel.text = job?.jobTitle
            descriptionLabel.text = job?.jobDescription
            fetchUserData(clientId: job?.clientUid ?? "")
        }
    }
    var offer: Offer? {
        didSet {
            offerLabel.text = "Oferta propusa: \(offer?.offer ?? 0.0) RON"
        }
    }
    var user: User? {
        didSet {
            clientNameLabel.text = user?.fullname
        }
    }
    
    weak var delegate: ActionViewDelegate?
    
    var config = JobActionViewConfiguration()
    
    private let backButton : UIButton = {
           let button = UIButton(type: .system)
           button.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for:  .normal)
           button.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
           return button
       }()
    
    var buttonAction = ButtonAction()
    
    private let offerResult: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        label.text = "X"
        
        view.addSubview(label)
        label.centerX(inView: view)
        label.centerY(inView: view)
        
        return view
    }()
    
    private let clientNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    private  let offerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
       // button.setTitle("AM AJUNS", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addShadow()
        
        let stack = UIStackView(arrangedSubviews: [offerResult,titleLabel,descriptionLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        
        addSubview(backButton)
        backButton.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor,
                          paddingTop: 15, paddingLeft: 12, width: 24, height:24)
        
        addSubview(stack)
        stack.centerX(inView: self)
        stack.anchor(top: topAnchor, paddingTop:  12)
        
        addSubview(infoView)
        infoView.centerX(inView: self)
        infoView.anchor(top: stack.bottomAnchor,paddingTop: 16)
        infoView.setDimensions(height: 60, width: 60)
        infoView.layer.cornerRadius = 60/2
        
        addSubview(clientNameLabel)
        clientNameLabel.anchor(top:infoView.bottomAnchor,paddingTop: 8)
        clientNameLabel.centerX(inView: self)
        
        addSubview(offerLabel)
        offerLabel.anchor(top:clientNameLabel.bottomAnchor, paddingTop: 12)
        offerLabel.centerX(inView: self)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        addSubview(separatorView)
        separatorView.anchor(top:offerLabel.bottomAnchor,left: leftAnchor,right: rightAnchor,paddingTop: 4,height:1)
        
        addSubview(actionButton)
        actionButton.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor,
                            paddingLeft: 12, paddingBottom: -18, paddingRight: 12, height: 50)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    
    @objc func actionButtonPressed() {
        print("DEBUG: 123")
    }
    @objc func handleBackTapped(){
        delegate?.handleTapButton()
     }
    
    //MARK: - Helper functions
    
    func fetchUserData(clientId: String){
        Service.shared.fetchUserData(uid: clientId) { user in
            self.user = user
        }
    }
    
    //MARK: - Helper Functions 
    func configureUI(withConfig config: JobActionViewConfiguration){
        switch config {
        case .offerAccepted:
            offerResult.text = "Ofertă acceptată"
            backButton.alpha = 0
            actionButton.alpha = 1
            buttonAction = .getDirections
            actionButton.setTitle(buttonAction.description, for: .normal)
            
        case .offerRejected:
            offerResult.text = "Ofertă respinsă"
            backButton.alpha = 1
            actionButton.alpha = 0
            
        case .mesterArrived:
            break
        case .jobInProgress:
            break
        case .endJob:
            break
        }
    }
}
