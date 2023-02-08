//
//  DirectionSearchView.swift
//  MapDirectionGooglePlaces_Minate
//
//  Created by Tina Tung on 10/19/22.
//

import SwiftUI
import MapKit

struct DirectionMapView: UIViewRepresentable {

    @EnvironmentObject var env: DirectionEnvironment
    
    let mapView = MKMapView()
    
    func makeCoordinator() -> DirectionMapView.Coordinator {
        return Coordinator(mapView: mapView)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        init(mapView: MKMapView) {
            super.init()
            mapView.delegate = self
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .red
            renderer.lineWidth = 5
            return renderer
        }
        
    }
    
    func makeUIView(context: UIViewRepresentableContext<DirectionMapView>) -> MKMapView {
        mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<DirectionMapView>) {
        
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)
        
        [env.sourceMapItem, env.destinationMapItem].compactMap{$0}.forEach { mapItem in
            let annotation = MKPointAnnotation()
            annotation.title =  mapItem.name
            annotation.coordinate = mapItem.placemark.coordinate
            uiView.addAnnotation(annotation)
        }

        uiView.showAnnotations(uiView.annotations, animated: false)
        
        if let route = env.route {
            //to make mapview to draw polylines, you need delegate from itself
            uiView.addOverlay(route.polyline)
        }
    }
}

struct SelectionLocationView: View {
    
    @EnvironmentObject var env: DirectionEnvironment
   
    @State var mapItems = [MKMapItem]()
    @State var searchQuery = ""
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                Button {
                    self.env.isSelectingSource = false
                    self.env.isSelectingDestination = false
                    
                } label: {
                    
                        Image(uiImage: UIImage(imageLiteralResourceName: "back_arrow"))
                        
                }
                TextField("Enter Search Term", text: $searchQuery)
                    .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification).debounce(for: .milliseconds(500), scheduler: RunLoop.main)) { _ in
                        let request = MKLocalSearch.Request()
                        request.naturalLanguageQuery = searchQuery
                        let search = MKLocalSearch(request: request)
                        search.start { resp, err in
                            if let err = err {
                                print("Fail map search", err)
                                return
                            }
                            self.mapItems = resp?.mapItems ?? []
                        }
                    }
        
            }.padding()
     
            
            if mapItems.count > 0 {
                ScrollView {
                    ForEach(mapItems, id: \.self) { item in
                        Button {
                            if self.env.isSelectingSource {
                                self.env.isSelectingSource = false
                                self.env.sourceMapItem = item
                            } else {
                                self.env.isSelectingDestination = false
                                self.env.destinationMapItem = item
                            }
                            
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(item.name ?? "")")
                                        .font(.headline)
                                    Text("\(item.address())")
                                }.padding()
                                Spacer()
                            }.padding()
                        }.foregroundColor(.black)
                    }
                }
            }
            
            Spacer()

        }.edgesIgnoringSafeArea(.bottom)
        .navigationBarTitle("Directions")
        .navigationBarHidden(true)
    }
}

struct DirectionSearchView: View {
    
    @EnvironmentObject var env: DirectionEnvironment
    @State var isPresentingRouteModel = false
    
    var body: some View {
        NavigationView {
            ZStack (alignment: .top) {
                VStack(spacing: 0) {
                    VStack(spacing: 12) {
                        
                        MapItemView(selectingBool: $env.isSelectingSource, title: env.sourceMapItem != nil ? env.sourceMapItem?.name ?? "" : "Source", image: UIImage(imageLiteralResourceName: "start_location_circles"))
                        MapItemView(selectingBool: $env.isSelectingDestination, title: env.destinationMapItem != nil ? env.destinationMapItem?.name ?? "" : "Destination", image: UIImage(imageLiteralResourceName: "annotation_icon"))
                        
                    }.padding()
                    .background(Color.blue)
                    
                    DirectionMapView().edgesIgnoringSafeArea(.bottom)
                }
                
                StatusBarCover()
                
                VStack {
                    Spacer()
                    Button {
                        self.isPresentingRouteModel.toggle()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Show Routes")
                                .padding()
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .background(Color.black)
                        .cornerRadius(5)
                            .padding()
                            
                    }
                
                }.sheet(isPresented: $isPresentingRouteModel) {
                    RouteInfoView(route: self.env.route)
            
                }
                
                CalculateDirectionView()
                
            }.navigationBarTitle("Directions")
            .navigationBarHidden(true)
        }

    }
}

struct RouteInfoView: View {
    
    var route: MKRoute?
    var body: some View {
        ScrollView {
            VStack {
                if route != nil {
                    Text("\(route?.name ?? "")")
                        .font(.system(size: 16, weight: .bold))
                        .padding()
                    
                    ForEach(route!.steps, id:\.self) { step in
                        VStack {
                            if !step.instructions.isEmpty {
                                HStack {
                                    Text(step.instructions)
                                    Spacer()
                                    Text("\(String(format: "%.2f mi", step.distance * 0.00062137))")
                                }.padding()
                            }
                        }
                    }
                }
            }
        }
    }
}

struct CalculateDirectionView: View {
    
    @EnvironmentObject var env: DirectionEnvironment
    
    var body: some View {
        if env.isCalculatingDirection {
            VStack {
                Spacer()
                VStack {
                    LoadingHud()
                    Text("Loading")
                }.padding()
                    .foregroundColor(.white)
                    .background(Color.black)
                    .cornerRadius(5)
                Spacer()
            }
            
        }
        
    }
    
}



struct LoadingHud: UIViewRepresentable {
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let aiv  = UIActivityIndicatorView()
        aiv.color = .white
        aiv.startAnimating()
        return aiv
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

struct MapItemView: View {
    
    @EnvironmentObject var env: DirectionEnvironment
    
    @Binding var selectingBool: Bool
    var title: String
    var image: UIImage
    
    var body: some View {
        HStack(spacing: 16) {
            Image(uiImage: image.withRenderingMode(.alwaysTemplate))
                .frame(width: 24).foregroundColor(.white)
            
            NavigationLink(destination: SelectionLocationView(), isActive: $selectingBool) {
                HStack {
                    Text(title)
                    Spacer()
                }.padding()
                    .background(Color.white)
                    .cornerRadius(5)
            }
        }
        
    }
}

struct StatusBarCover: View {
    var body: some View {
        Spacer().frame(width: UIApplication.shared.windows.filter{$0.isKeyWindow}.first?.frame.width, height: UIApplication.shared.windows.filter{$0.isKeyWindow}.first?.safeAreaInsets.top)
            .background(Color.blue)
            .edgesIgnoringSafeArea(.top)
    }
}

import Combine
//treat your env as the brain of your application
class DirectionEnvironment: ObservableObject {
    @Published var isCalculatingDirection = false
    
    @Published var isSelectingSource = false
    @Published var isSelectingDestination = false
    
    @Published var sourceMapItem: MKMapItem?
    @Published var destinationMapItem: MKMapItem?
    
    @Published var route: MKRoute?
    
    var cancellable: AnyCancellable?
    
    init() {
        //listen for changes among sourceMapItem, destinationMapItem
        cancellable = Publishers.CombineLatest($sourceMapItem, $destinationMapItem).sink{[weak self] items in

            let request =  MKDirections.Request()
            request.source = items.0
            request.destination = items.1
            let directions = MKDirections(request: request)
            
            self?.route = nil
            self?.isCalculatingDirection = true
            directions.calculate {[weak self] resp, err in
                self?.isCalculatingDirection = false

                if let err = err {
                    print("Failed to calculate directions:", err)
                    return
                }
     
                self?.route = resp?.routes.first
            }
        }
    }
    
}

struct DirectionSearchView_Previews: PreviewProvider {
    static var env = DirectionEnvironment()
    
    static var previews: some View {
        DirectionSearchView().environmentObject(env)
    }
}
