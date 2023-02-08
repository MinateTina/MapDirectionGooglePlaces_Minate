//
//  MainController.swift
//  MapDirectionGooglePlaces_Minate
//
//  Created by Tina Tung on 9/24/22.
//

import UIKit
import MapKit
import LBTATools
import Combine

extension MainController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation is MKPointAnnotation) {
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "id")
            annotationView.canShowCallout = true
            return annotationView
        }
        
        return nil
        
    }
}


class MainController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    let mapView = MKMapView()
    
    
    private func requestUserLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            print("Received authorization of user location")
            locationManager.startUpdatingLocation()
        default:
            print("Failed to authorize")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let firstLocation = locations.first else { return }
        mapView.setRegion(.init(center: firstLocation.coordinate, span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: false)
        
        locationManager.stopUpdatingLocation()
    }
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestUserLocation()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        view.addSubview(mapView)
        mapView.fillSuperview()
        
        setupRegionForMap()
        
        performLocalSearch()
        
        setupSearchUI()
        
        setupLocationCarousel()
        
        locationController.mainController = self
    }
    
    let locationController = LocationCarouselController(scrollDirection: .horizontal)
    
    
    private func setupLocationCarousel() {
        let locationView = locationController.view!
        
        view.addSubview(locationView)
        
        locationView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 16, bottom: 0, right: 16), size: .init(width: 0, height: 100))
        
    }

    let searchTextField = UITextField(placeholder: "Search Query")
    
    private func setupSearchUI() {
        
        let whiteContainer = UIView(backgroundColor: .white)
        view.addSubview(whiteContainer)
        
        whiteContainer.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 16, bottom: 0, right: 16))
        
        
        whiteContainer.stack(searchTextField).withMargins(.allSides(16))
        

        setupSearchListener()
    }
    
    var listener: Any!
    //cancel listener bcos might have retain cycles
//    var listener: AnyCancellable!
    private func setupSearchListener() {
        listener = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: searchTextField).debounce(for: .milliseconds(500), scheduler: RunLoop.main).sink(receiveValue: { [weak self] _ in
            self?.performLocalSearch()
        })
        
//        listener.cancel()
    }

    

    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let customAnnotation = view.annotation as? CustomMapItemAnnotation else { return }
                
        guard let index = self.locationController.items.firstIndex(where: {$0.name == customAnnotation.mapItem?.name}) else { return }
        
        self.locationController.collectionView.scrollToItem(at: [0,index], at: .centeredHorizontally, animated: true)
        
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
            self.locationController.items.removeAll()
            
            resp?.mapItems.forEach({ mapItem in
                print(mapItem.address())
                let annotation = CustomMapItemAnnotation()
                annotation.mapItem = mapItem
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = "Location: " + (mapItem.name ?? "")
                self.mapView.addAnnotation(annotation)
                
                //tell my locaionCarouselController
                self.locationController.items.append(mapItem)
            })
            //Once search for new items, scroll back to the first index
            self.locationController.collectionView.scrollToItem(at: [0,0], at: .centeredHorizontally, animated: true)
            
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        }
        
    }
    
    class CustomMapItemAnnotation: MKPointAnnotation {
        var mapItem: MKMapItem?
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
    
    struct ContainerView: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> MainController {
            return MainController()
        }
        
        func updateUIViewController(_ uiViewController: MainController, context: Context) {
            
        }
    }
}





