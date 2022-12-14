//
//  MapSearchingView.swift
//  MapDirectionGooglePlaces_Minate
//
//  Created by Minate on 10/10/22.
//

import SwiftUI
import MapKit
import Combine

class MapSearchingViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {

    
    @Published var annotations = [MKPointAnnotation]()
    @Published var isSearching = false
    @Published var searchTerms = "" {
        didSet {
            performSearch(query: searchTerms)
        }
    }
    
    @Published var mapItems = [MKMapItem]()
    @Published var selectedMapItem: MKMapItem?
    @Published var keyboardHeight: CGFloat = 0
    @Published var currentLocation = CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437)
    
    //figuring out user's location
    let locationManager = CLLocationManager()
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let firstLocation = locations.first else { return }
        self.currentLocation = firstLocation.coordinate
    }
    
    var cancellable: AnyCancellable?
    override init() {
        super.init()
        cancellable = $searchTerms.debounce(for: .milliseconds(500), scheduler: RunLoop.main).sink { searchTerms in
            self.performSearch(query: searchTerms)
        }
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        listenToKeyboardNotifications()
        
        NotificationCenter.default.addObserver(forName: MapViewContainer.Coordinator.regionChangeNotification, object: nil, queue: .main) { notification in
            self.region = notification.object as? MKCoordinateRegion
        }
        
    }
    
    private var region: MKCoordinateRegion?
    
    private func listenToKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] (notification) in
            guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
            let keyboardFrame = value.cgRectValue
            let window = UIApplication.shared.windows.filter{$0.isKeyWindow}.first
            
            withAnimation(.easeOut(duration: 0.25)) {
                self?.keyboardHeight = keyboardFrame.height - window!.safeAreaInsets.bottom
            }
            print(keyboardFrame.height)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] (notification) in
            withAnimation(.easeOut(duration: 0.25)) {
                self?.keyboardHeight = 0
            }
            
        }
    }
    
    func performSearch(query: String) {
        self.isSearching = true
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        if let region = self.region {
            request.region = region
        }
        
        let localSearch = MKLocalSearch(request: request)
        localSearch.start { resp, err in
            
            var airportAnnotations = [MKPointAnnotation]()
            if let err =  err {
                print("Failed to fetch local search", err)
                return
            }
            self.mapItems = resp?.mapItems ?? []
            resp?.mapItems.forEach({ mapItem in
                print(mapItem.name ?? "")
                let annotation = MKPointAnnotation()
                annotation.title = mapItem.name
                annotation.coordinate =  mapItem.placemark.coordinate
                airportAnnotations.append(annotation)
                
            })
            self.isSearching = false
            self.annotations = airportAnnotations
        }
    }
}

struct MapSearchingView: View {
    
    @ObservedObject var vm = MapSearchingViewModel()

    
    var body: some View {
        ZStack(alignment: .top) {
            
            MapViewContainer(annotations: vm.annotations, selectedMapItem: vm.selectedMapItem, currentLocation: vm.currentLocation)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    TextField("Search Terms", text: $vm.searchTerms, onCommit: {
                        //filter out blue dot(your own location) while dragging around the map
                        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.endEditing(true)
                    })
                        .padding()
                        .background(Color.white)
                        

                }.padding()
                
                if vm.isSearching {
                    Text("Searching...")
                }
                Spacer()
                
                ScrollView(.horizontal) {
                    HStack(spacing: 16) {
                        ForEach(vm.mapItems, id:\.self) { mapItem in
                            
                            Button {
                                self.vm.selectedMapItem = mapItem
                            } label: {
                                VStack(alignment: .leading){
                                    Text(mapItem.name ?? "")
                                        .font(.headline)
                                    Text(mapItem.address())
                                    
                                }.padding()
                                    .foregroundColor(.black)
                                    .frame(width: 250, height: 100)
                                    .background(Color.white)
                                    .cornerRadius(5)
                            }
                        }

                    }.padding(.horizontal, 16)
                  
                }.shadow(radius: 5)
                
                Spacer().frame(height: vm.keyboardHeight)
            }
           
        }
    }
}


struct MapViewContainer: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        
        return Coordinator(mapView: mapView)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
  
        init(mapView: MKMapView) {
            super.init()
            mapView.delegate = self
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            //make sure blue dot returns
            if !(annotation is MKPointAnnotation) { return nil }
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
            pinAnnotationView.canShowCallout = true
            return pinAnnotationView
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            NotificationCenter.default.post(name: MapViewContainer.Coordinator.regionChangeNotification, object: mapView.region)
        }
        
        static let regionChangeNotification = Notification.Name("regionChangeNotification")
    }
    
    var annotations = [MKPointAnnotation]()
    let mapView = MKMapView()
    var selectedMapItem: MKMapItem?
    var currentLocation = CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437)

    func makeUIView(context: UIViewRepresentableContext<MapViewContainer>) -> MKMapView {
        setupRegionForMap()
        mapView.showsUserLocation = true
        return mapView
    }
    
    private func setupRegionForMap() {
        let centerCoordinate = CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapViewContainer>) {
        
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: currentLocation, span: span)
        
        uiView.setRegion(region, animated: true)
        
        if annotations.count == 0 {
            uiView.removeAnnotations(uiView.annotations)
            return
        }
        
        if shouldRefreshAnnotations(mapView: uiView) {
            uiView.removeAnnotations(uiView.annotations)
            uiView.addAnnotations(annotations)
            uiView.showAnnotations(uiView.annotations, animated: false)
        }

        uiView.annotations.forEach { annotation in
            if annotation.title == selectedMapItem?.name {
                uiView.selectAnnotation(annotation, animated: true)
            }
        }
        
    }
    
    // This checks to see whether or not annotations have changed.  The algorithm generates a hashmap/dictionary for all the annotations and then goes through the map to check if they exist. If it doesn't currently exist, we treat this as a need to refresh the map
    fileprivate func shouldRefreshAnnotations(mapView: MKMapView) -> Bool {
        let grouped = Dictionary(grouping: mapView.annotations, by: { $0.title ?? ""})
        for (_, annotation) in annotations.enumerated() {
            if grouped[annotation.title ?? ""] == nil {
                return true
            }
        }
        return false
    }
}


struct MapSearchingView_Previews: PreviewProvider {

    static var previews: some View {
            MapSearchingView()
    }
}

