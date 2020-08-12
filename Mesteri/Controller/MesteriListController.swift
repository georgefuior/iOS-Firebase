//
//  MesteriListController.swift
//  Mesteri
//
//  Created by George Fuior on 05/05/2020.
//  Copyright © 2020 George Fuior. All rights reserved.
//

import UIKit
import Firebase


private let reuseIdentifier = "Mester Cell"

class MesteriListController: UIViewController{
    
    //MARK: - Proprieties
    
    private let searchMesterView = SearchMesterView()
    
    private let locationManager = LocationHandler.shared.locationManager
    
    private var searchResults: [User] = Array()
    private let tableView = UITableView()
    
    private final let searchMesterHeight: CGFloat = 130
    
    private var user: User? {
        didSet {searchMesterView.user = user}
    }
    
    
    static var selectedUser = User()
    static var comeFromListController: Bool = false
    private var myMesterList = [User]()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureSearchMesterView()
        configureTableView()
        fetchUserData()
        fetchMesteri()
        
    }
    
    
    //MARK: - Helper functions
    
    
    func configureSearchMesterView(){
        searchMesterView.delegate = self
        view.addSubview(searchMesterView)
        searchMesterView.displayTextField.attributedPlaceholder = NSAttributedString(string: "Caută un meșter în listă", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        searchMesterView.displayTextField.returnKeyType = .search 
        searchMesterView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: searchMesterHeight - 3)
        searchMesterView.alpha = 0
        
        UIView.animate(withDuration: 0.5, animations: {
            self.searchMesterView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.5) {
                self.tableView.frame.origin.y = self.searchMesterHeight
            }
            
        }
    }
    
    func configureTableView() {
        
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(MesterCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 55
        
        let height = view.frame.height - searchMesterHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        
        tableView.tableFooterView = UIView()
        
    }
    
    func searchBy(naturalLanguageQuery: String, completion: @escaping([User]) -> Void) {
        var results = [User]()
        for user in myMesterList {
            if (naturalLanguageQuery.lowercased() == user.meserie?.lowercased()) ||
                (user.fullname.lowercased().contains(naturalLanguageQuery.lowercased())) {
                results.append(user)
            }
            
        }
        completion(results)
        
    }
    
    //MARK: - APIs
    
    func fetchUserData(){
        Service.shared.fetchUserData() { user in
            self.user = user
        }
    }
    func fetchMesteri(){
        guard let location = locationManager?.location else {return}
        Service.shared.fetchMesteri(location: location) { (user) in
            self.myMesterList.append(user)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

//MARK: - SearchMesterViewDelegate

extension MesteriListController: SearchMesterViewDelegate{
    func executeSearch(query: String) {
        searchBy(naturalLanguageQuery: query) { (results) in
            self.searchResults = results
            self.tableView.reloadData()
        }
    }
    
    func handleTapButton() {
        let  controller = HomeController()
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }    
}




//MARK: - UITableViewDelegate/Datasource
extension MesteriListController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0{
            return "Rezultatele căutării"
        } else if section == 2{
            return "Meșteri din apropiere"
        }else {
            return "Meșteri recomandați"
        }
        
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? searchResults.count : section == 1 ? 2 : myMesterList.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,for: indexPath) as!
        MesterCell
        
        if indexPath.section == 2{
            let test = myMesterList[indexPath.row]
            cell.numeMester.text = test.fullname
            cell.ocupatieMester.text = test.meserie
        } else if indexPath.section == 0{
            let test = searchResults[indexPath.row]
            cell.numeMester.text = test.fullname
            cell.ocupatieMester.text = test.meserie
            
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("DEBUG: Section: \(indexPath.section): Row selected \(indexPath.row)")
        if indexPath.section == 2{
            MesteriListController.selectedUser = myMesterList[indexPath.row]
            // print("Debug: Selected mester: \(selectedUser.uid)")
        } else if indexPath.section == 0{
            MesteriListController.selectedUser = searchResults[indexPath.row]
            // print("DEBUG: Selected mester: \(selectedUser.uid)")
            
        }
        MesteriListController.comeFromListController = true
        let controller = JobDetailsController()
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
        
    }
}


