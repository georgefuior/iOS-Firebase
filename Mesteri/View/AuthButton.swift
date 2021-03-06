//
//  AuthButton.swift
//  Mesteri
//
//  Created by George Fuior on 29/04/2020.
//  Copyright © 2020 George Fuior. All rights reserved.
//

import UIKit

class AuthButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setTitleColor(UIColor(white: 1, alpha: 0.5), for: .normal)
        backgroundColor = .mainBlueTint
        layer.cornerRadius = 5
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        heightAnchor.constraint(equalToConstant: 50).isActive = true
       
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
