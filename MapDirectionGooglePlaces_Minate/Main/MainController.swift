//
//  MainController.swift
//  MapDirectionGooglePlaces_Minate
//
//  Created by Minate on 9/24/22.
//

import UIKit
import MapKit
import LBTATools

extension MainController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "id")
        annotationView.canShowCallout = true
        return annotationView
    }
}

class MainController: UIViewController {
    
    let mapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        mapView.fillSuperview()
        
        setupRegionForMap()
        
        performLocalSearch()
    }
    
    private func performLocalSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "apple"
        request.region = mapView.region
        
        let localSearch = MKLocalSearch(request: request)
        localSearch.start { resp, err in
            if let err = err {
                print("Failed local search:", err)
                return
            }
            
            resp?.mapItems.forEach({ mapItem in
                print(mapItem.name ?? "")
                
                let placemark = mapItem.placemark
                var addressString = ""
                if placemark.subThoroughfare != nil {
                    addressString = placemark.subThoroughfare! + " "
                }
                if placemark.thoroughfare != nil {
                    addressString += placemark.thoroughfare! + ", "
                }
                if placemark.postalCode != nil {
                    addressString += placemark.postalCode! + " "
                }
                if placemark.locality != nil {
                    addressString += placemark.locality! + ", "
                }
                if placemark.administrativeArea != nil {
                    addressString += placemark.administrativeArea! + " "
                }
                if placemark.country != nil {
                    addressString += placemark.country!
                }
                print(addressString)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.name
                self.mapView.addAnnotation(annotation)
            })
            
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        }
        
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
