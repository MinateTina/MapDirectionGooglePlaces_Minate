//
//  MainController.swift
//  MapDirectionGooglePlaces_Minate
//
//  Created by Minate on 9/24/22.
//

import UIKit
import MapKit
import LBTATools

class MainController: UIViewController {
    
    let mapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        mapView.fillSuperview()
        
        setupRegionForMap()
    }
    
    private func setupRegionForMap() {
        let centerCoordinate = CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437)
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        
        mapView.setRegion(region, animated: true)
    }
}


import SwiftUI

struct MainView: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
}

struct ContainerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> MainController {
        return MainController()
    }
    
    func updateUIViewController(_ uiViewController: MainController, context: Context) {
        
    }
    
    typealias UIViewControllerType = MainController

}
