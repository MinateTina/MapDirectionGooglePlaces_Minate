//
//  DirectionController.swift
//  MapDirectionGooglePlaces_Minate
//
//  Created by Minate on 9/29/22.
//

import UIKit
import MapKit
import LBTATools
import SwiftUI

class DirectionController: UIViewController,MKMapViewDelegate {
    
    let mapView = MKMapView()
    let navBar = UIView(backgroundColor: #colorLiteral(red: 0.3681624411, green: 0.6385091398, blue: 0.9714118838, alpha: 1))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        view.addSubview(mapView)
        
        setupRegionForMap()
        setupNavBarUI()
        setupMapView()
        mapView.showsUserLocation = true
        setupStartEndDummyAnnotations()
        requestForDirections()
    }
    
    let startAnnotation = MKPointAnnotation()
    let endAnnotation = MKPointAnnotation()
    
    private func setupStartEndDummyAnnotations() {
        
        startAnnotation.coordinate = .init(latitude: 37.7666, longitude: -122.427290)
        startAnnotation.title = "Start"
        
        
        endAnnotation.coordinate = .init(latitude: 37.331352, longitude: -122.030331)
        endAnnotation.title = "End"
        
        mapView.addAnnotations([startAnnotation, endAnnotation])
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    private func requestForDirections() {
        let request = MKDirections.Request()
        
        let startingPlacemark = MKPlacemark(coordinate: startAnnotation.coordinate)
        request.source = .init(placemark: startingPlacemark)
        let endingPlacemark = MKPlacemark(coordinate: endAnnotation.coordinate)
        request.destination = .init(placemark: endingPlacemark)
        
       // request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { resp, err in
            if let err = err {
                print("Failed to find routing for:", err)
                return
            }
            //success
            print("Found my directions/routing...")
            //only one route
//            guard let route = resp?.routes.first else { return }
            resp?.routes.forEach({ route in
                print(route.expectedTravelTime)
                self.mapView.addOverlay(route.polyline)
            })
        }
    }
    //renderer for the overlay on the map
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = #colorLiteral(red: 0.1758151352, green: 0.4966287613, blue: 0.7584065795, alpha: 1)
        polylineRenderer.lineWidth = 3
        return polylineRenderer
    }
    
    private func setupMapView() {
        mapView.anchor(top: navBar.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    
    let startTextField = IndentedTextField(padding: 12, cornerRadius: 5)
    let endTextField = IndentedTextField(padding: 12, cornerRadius: 5)
    
    
    private func setupNavBarUI() {
        view.addSubview(navBar)
        navBar.setupShadow(opacity: 0.5, radius: 5)
        navBar.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: -120, right: 0))
        
        startTextField.attributedPlaceholder = .init(string: "Start", attributes: [.foregroundColor: UIColor.init(white: 1, alpha: 0.7)])
        endTextField.attributedPlaceholder = .init(string: "End", attributes: [.foregroundColor: UIColor.init(white: 1, alpha: 0.7)])
        
        [startTextField, endTextField].forEach { tf in
            tf.backgroundColor = .init(white: 1, alpha: 0.3)
            tf.textColor = .white
        }

        let containerView = UIView(backgroundColor: .clear)
        navBar.addSubview(containerView)
        containerView.fillSuperviewSafeAreaLayoutGuide()
        
        
        let startIcon = UIImageView(image: #imageLiteral(resourceName: "start_location_circles"), contentMode: .scaleAspectFit)
        startIcon.constrainWidth(20)
        
        let endIcon = UIImageView(image: #imageLiteral(resourceName: "annotation_icon").withRenderingMode(.alwaysTemplate), contentMode: .scaleAspectFit)
        endIcon.tintColor = .white
        endIcon.constrainWidth(20)
        
        containerView.stack(
            containerView.hstack(startIcon, startTextField, spacing: 16),
            containerView.hstack(endIcon, endTextField, spacing: 16), spacing: 12, distribution: .fillEqually).withMargins(.init(top: 0, left: 16, bottom: 12, right: 16))
        
        startTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleChangeStartLocation)))
        
        navigationController?.navigationBar.isHidden = true
        
    }
    
    @objc private func handleChangeStartLocation() {
        let vc = UIViewController()
        vc.view.backgroundColor = .yellow
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    private func setupRegionForMap() {
        let centerCoordinate = CLLocationCoordinate2D(latitude: 37.774, longitude: -122.4313)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        
        mapView.setRegion(region, animated: true)
    }
}

struct DirectionPreview: PreviewProvider {
    static var previews: some View {

        ContainerView1().edgesIgnoringSafeArea(.all)
        ContainerView1().edgesIgnoringSafeArea(.all)
            .environment(\.colorScheme, .dark)
        
    }
}

struct ContainerView1: UIViewControllerRepresentable {
    
    let navController = UINavigationController()
    
    
    func makeUIViewController(context: Context) -> DirectionController {
        return DirectionController()
    }
    
    
    func updateUIViewController(_ uiViewController: DirectionController, context: Context) {
        
    }
    
    typealias UIViewControllerType = DirectionController
}
