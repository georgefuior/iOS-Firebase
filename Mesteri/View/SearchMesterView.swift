//
//  SearchMester.swift
//  Mesteri
//
//  Created by George Fuior on 05/05/2020.
//  Copyright © 2020 George Fuior. All rights reserved.
//

import UIKit
import Firebase

protocol SearchMesterViewDelegate: class {
   func handleTapButton()
    func executeSearch(query: String)
}

class SearchMesterView: UIView {

   //MARK: - Proprieties
    
    var user: User?{
        didSet{titleLabel.text = user?.fullname}
    }
    weak var delegate: SearchMesterViewDelegate?
    
    private let backButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for:  .normal)
        button.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
        return button
    }()

    private let titleLabel: UILabel = {
             let label = UILabel()
          label.font = UIFont.systemFont(ofSize: 16)
          label.textColor = .darkGray
             return label
         }()
    
    private let IndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
     lazy var displayTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .lightGray
        tf.font = UIFont.systemFont(ofSize: 12)
        tf.delegate = self
        let paddingView = UIView()
        paddingView.setDimensions(height: 30, width: 8)
        tf.leftView = paddingView
        tf.leftViewMode = .always
        return tf
        
      
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        addShadow()
        
        backgroundColor = .white
        addSubview(backButton)
        backButton.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor,
                          paddingTop: 15, paddingLeft: 12, width: 24, height:24)
        
        addSubview(titleLabel)
        titleLabel.centerY(inView: backButton)
        titleLabel.centerX(inView: self )
        
        addSubview(displayTextField)
        displayTextField.anchor(top: backButton.bottomAnchor,
                                left: leftAnchor, right: rightAnchor,
                                paddingTop:12, paddingLeft: 40, paddingRight: 40, height: 30)
        
        addSubview(IndicatorView)
        IndicatorView.centerY(inView: displayTextField, leftAnchor: leftAnchor, paddingLeft: 20)
        IndicatorView.setDimensions(height: 6, width: 6)
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Selectors
    
    
    @objc func handleBackTapped(){
        delegate?.handleTapButton()
    }
    
    //MARK: - APIs
    

    
    //MARK: Helper Function
    
     

}

//MARK: - UITextFieldDelegate

extension SearchMesterView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text else {return false}
        delegate?.executeSearch(query: query)
        return true
    }
}

