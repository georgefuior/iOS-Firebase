//
//  TableViewCell.swift
//  Mesteri
//
//  Created by George Fuior on 05/05/2020.
//  Copyright © 2020 George Fuior. All rights reserved.
//

import UIKit

class OfferCell: UITableViewCell {

    //MARK: - Proprities
    
     let numeMester: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Ion Mesterul"
        return label
    }()
    
     let ocupatieMester: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.text = "Zugrav"
        return label
    }()
    let offer: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .lightGray
        
        label.text = "Oferta"
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier : String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let stack = UIStackView(arrangedSubviews: [numeMester, ocupatieMester])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 4
        
        addSubview(stack)
        stack.centerY(inView: self,leftAnchor: leftAnchor, paddingLeft: 12)
        addSubview(offer)
        offer.anchor(right: self.safeAreaLayoutGuide.rightAnchor, paddingRight: 20)
        offer.centerY(inView: self)
      
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
