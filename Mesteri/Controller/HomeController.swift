//
//  HomeController.swift
//  Mesteri
//
//  Created by George Fuior on 01/05/2020.
//  Copyright © 2020 George Fuior. All rights reserved.
//

import UIKit
import Firebase
import MapKit

private let annotationIdentifier = "MesterAnnotation"

class HomeController: UIViewController, ToJobLocationControllerDelegate{
    
    //MARK: - Proprieties
    
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    private let actionView = ActionView()
    private let userHomeView = UserHomeView()
    private var selectedAnnotation: JobAnnotation?
    private var route: MKRoute?
    private final let actionViewHeight: CGFloat = 330
    private var offer: Offer?
    {
        didSet{
            guard let offer = offer else {return}
            self.actionView.offer = offer
            print("DEBUG: Offer: \(offer)")
            if offer.state == .accepted {
                drawRouteToJob()
                self.animateActionView(shouldShow: true,config: .offerAccepted)
                
            } else if offer.state == .rejected {
                self.animateActionView(shouldShow: true,config: .offerRejected)
               
            }
        }
    }
    private var user: User? {
        didSet{
            self.userHomeView.user = user
            if user?.accountType == 0 {
                configureUserHome()
                
            }else if user?.accountType == 1 {
                configureMesterHome()
            }
        }
    }
    
    private var job: Job? {
        didSet{
            guard let job = job else {return}
            self.actionView.job = job
            Service.shared.observeMyOffer(job: job) { offer in
                print("DEBUG: Offer called in HomeController")
                self.offer = offer
            }
            print("DEBUG: Job set")
            if (( job.preferredMesterUid == Auth.auth().currentUser?.uid  && job.state == .isRequested)
                || (job.preferredMesterUid == "" && job.state == .isRequested)){
                let controller = PickUpController(job: job)
                controller.modalPresentationStyle = .fullScreen
                controller.delegate = self
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Thonburi-Bold",size: 24)
        
        return label
    }()
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal  ), for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    
    //MARK: - Lifecycle
    
    override  func viewDidLoad() {
        super.viewDidLoad()
        actionView.delegate = self
        userHomeView.delegate = self
        checkIfUserIsLoggedIn()
        enableLocationServices()
        //signOut()
    }
    override func viewWillAppear(_ animated: Bool) {
        guard let job = job else {return}
        print("DEBUG: Job state is \(job.state)")
    }
    
    //MARK: - APIs
    
    func fetchUserData(){
        
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        Service.shared.fetchUserData(uid: currentUid){ user in
            self.user = user
        }
    }
    
    func fetchMesteri(){
        guard let location = locationManager?.location  else {return}
        Service.shared.fetchMesteri(location: location) { (mester) in
            guard let coordinate = mester.location?.coordinate else {return}
            let annotation = MesterAnnotation(uid: mester.uid, coordinate: coordinate)
            print("DEBUG: \(mester.fullname) Coordiante is: \(coordinate)")
            var mesterIsVisible: Bool {
                return self.mapView.annotations.contains (where:{ annotation -> Bool in
                    guard let mesterAnno = annotation as? MesterAnnotation else {return false}
                    if mesterAnno.uid ==  mester.uid {
                        mesterAnno.updateAnnotationPosition(withCoordinate: coordinate)
                        return true
                    }
                    return false
                })
            }
            if !mesterIsVisible{
                self.mapView.addAnnotation(annotation)
            }
        }
        
    }
    
    func observeJobs(){
        guard let location = locationManager?.location  else {return}
        Service.shared.observeJobs(location: location) { job in
            self.job = job
            if job.state == .isRequested || job.state == .isQuoted {
                guard let coordinates = job.jobCoordinates else {return}
                let annotation = JobAnnotation(uid: job.jobUid, coordinate: coordinates)
                //print("DEBUG: Job: \(job.jobTitle) coordinate is: \(coordinates)")
                var jobIsVisible: Bool {
                    return self.mapView.annotations.contains (where: { annotation -> Bool in
                        guard let jobAnno = annotation as? JobAnnotation else { return false}
                        if jobAnno.uid == job.jobUid{
                            jobAnno.updateAnnotationPosition(withCoordinate: coordinates)
                            
                            return true
                        }
                        return false
                    })
                }
                if !jobIsVisible{
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    func drawRouteToJob(){
        guard let job = job else {return}
        let anno = MKPointAnnotation()
        anno.coordinate = job.jobCoordinates
        mapView.addAnnotation(anno)
        
        let placemark = MKPlacemark(coordinate: job.jobCoordinates)
        let mapItem = MKMapItem(placemark: placemark)
        generatePolyline(toDestination: mapItem)
        
        mapView.zoomToFit(annotations: mapView.annotations)
        
        
    }

    func checkIfUserIsLoggedIn(){
        if Auth.auth().currentUser?.uid == nil{
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav,animated: true,completion: nil)
            }
        } else {
            configure()
        }
    }
    
    func signOut(){
        do{
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav,animated: true,completion: nil)
            }
            
        }catch{
            print("DEBUG: Error signing out")
        }
    }
    
    //MARK: - Helper functions
    
    func configure (){
        fetchUserData()
        //signOut()
        
    }
    func animateActionView(shouldShow: Bool, config: JobActionViewConfiguration? = nil, user: User? = nil){
        let yOrigin = shouldShow ? self.view.frame.height - self.actionViewHeight :  self.view.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.actionView.frame.origin.y = yOrigin
        }
        if shouldShow {
            print("DEBUG: Should Show")
            guard let config = config else {return}
            actionView.configureUI(withConfig: config)
            
            if let user = user {
                actionView.user = user
            }
        }
    }
    func configureActionView() {
        view.addSubview(actionView)
        actionView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: actionViewHeight)
    }
    func configureUserHomeView() {
          view.addSubview(userHomeView)
        userHomeView.frame = CGRect(x: 0, y: view.frame.height - self.actionViewHeight, width: view.frame.width, height: actionViewHeight)
      }
      
    
    func configureActionButton(){
        view.addSubview(actionButton)
        actionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 16,paddingLeft: 20,width: 30,height:30)
    }
    
    func configureMapView(leftMargin: CGFloat, topMargin: CGFloat, mapWidth: CGFloat, mapHeight: CGFloat){
        
        view.addSubview(mapView)
        view.backgroundColor = .white
        let leftMargin:CGFloat = leftMargin
        let topMargin:CGFloat = topMargin
        let mapWidth:CGFloat =  mapWidth
        let mapHeight:CGFloat = mapHeight
        mapView.frame = CGRect(x: leftMargin, y: topMargin, width: mapWidth, height: mapHeight)
        mapView.addShadow()
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
    }
    
    func configureUserHome(){
        configureMapView(leftMargin: 0,topMargin: 0,mapWidth: view.frame.size.width,mapHeight: view.frame.size.height)
        configureUserHomeView()
        configureActionButton()
        configureActionView()
        fetchMesteri()

  
    }
    func configureMesterHome(){
        configureMapView(leftMargin: 0,topMargin: 0,mapWidth: view.frame.size.width,mapHeight: view.frame.size.height)
        observeJobs()
        configureActionButton()
        configureActionView()
       // observeMesterOffer()
    }
    
    func generatePolyline(toDestination destination: MKMapItem) {
           let request = MKDirections.Request()
           request.source = MKMapItem.forCurrentLocation()
           request.destination = destination
           request.transportType = .automobile
           
           let directionRequest = MKDirections(request: request)
           directionRequest.calculate { (response, error) in
               guard let response = response else { return }
               self.route = response.routes[0]
               guard let polyline = self.route?.polyline else { return }
               self.mapView.addOverlay(polyline)
           }
       }
    
    //MARK: - Selectors
    @objc func actionButtonPressed(){
        print("DEBUG: Handle action button pressed...")
        self.animateActionView(shouldShow: false)
        
    }
    
}


//MARK: - Location Services
extension HomeController {
    func enableLocationServices(){
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("DEBUG: Not determined..")
            locationManager?.requestWhenInUseAuthorization()
        case .restricted,.denied:
            break
        case .authorizedAlways:
            print("DEBUG: Auth always..")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: Auth when in use..")
            locationManager?.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
}


//MARK: - MKMapViewDelegate

extension HomeController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MesterAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            view.image = #imageLiteral(resourceName: "Image")
            return view
        }
        if let annotation = annotation as? JobAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            view.image = #imageLiteral(resourceName: "chevron-sign-to-right")
            return view
        }
        
        return nil
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.selectedAnnotation = view.annotation as? JobAnnotation
        print("DEBUG: \(selectedAnnotation?.uid)")
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
            lineRenderer.strokeColor = .mainBlueTint
            lineRenderer.lineWidth = 3
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
}
//MARK: - PickUpControllerDelegate

extension HomeController: PickUpControllerDelegate{
    
    func didSendOffer(_ job: Job) {
        self.job?.state = .isQuoted
        self.dismiss(animated: true, completion: nil)
    }
}
//MARK: - ActionViewDelegate

extension HomeController: ActionViewDelegate {
    func handleTapButton() {
        animateActionView(shouldShow: false)
    }
}

//MARK: - ListOffersControllerDelegate

extension HomeController: ListOffersControllerDelegate{
    
    func didAcceptOffer(offer: Offer, _ job: Job) {
        self.job?.state = .isAccepted
        self.job?.mesterUid = job.mesterUid
        print("DEBUG: Delegate accepted")
        self.animateActionView(shouldShow: true, config: .offerAccepted)
        
    }
}

//MARK: - UserHomeViewDelegate

extension HomeController: UserHomeViewDelegate {
    func handleCautaMester(){
        let controller = MesteriListController()
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
        print("DEBUG: Cauta mester")
    }
    func handlePublicaLucrare(){
        let controller = JobDetailsController()
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
        print("DEBUG: Publica lucrare")
    }
}
