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
        
        setupSearchdUI()
        
        setupLocationCarousel()
    }
    
    let locationController = LocationCarouselController(scrollDirection: .horizontal)
    
    
    private func setupLocationCarousel() {
        let locationView = locationController.view!
        
        view.addSubview(locationView)
        
        locationView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, size: .init(width: 0, height: 150))
        
    }

    let searchTextField = UITextField(placeholder: "Search Query")
    
    private func setupSearchdUI() {
        
        let whiteContainer = UIView(backgroundColor: .white)
        view.addSubview(whiteContainer)
        
        whiteContainer.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 16, bottom: 0, right: 16))
        
        
        whiteContainer.stack(searchTextField).withMargins(.allSides(16))
        
//        searchTextField.addTarget(self, action: #selector(handleSearchChanges), for: .editingChanged)
        
        //New School Search Throttling
        //search on the last keystroke of text changes and basically wait 500 milliseconds
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: searchTextField)
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { _ in
                self.performLocalSearch()
            }
    }
    
    @objc func handleSearchChanges() {
        performLocalSearch()
    }
    
    private func performLocalSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTextField.text
        request.region = mapView.region
        
        let localSearch = MKLocalSearch(request: request)
        localSearch.start { resp, err in
            if let err = err {
                print("Failed local search:", err)
                return
            }
            //when it's a success to fetch requests, remove old annotations.
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            resp?.mapItems.forEach({ mapItem in
                print(mapItem.address())
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

extension MKMapItem {
    func address() -> String {
        
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
        return addressString
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



