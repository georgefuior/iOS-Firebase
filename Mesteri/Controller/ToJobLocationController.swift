//
//  ToJobLocationController.swift
//  Mesteri
//
//  Created by George Fuior on 20/05/2020.
//  Copyright © 2020 George Fuior. All rights reserved.
//

import UIKit

protocol  ToJobLocationControllerDelegate: class {
  //  func didSendOffer (_ job: Job)
}
class ToJobLocationController: UIViewController {

       weak var delegate: ToJobLocationControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

