//
//  SlideMenuView.swift
//  MapDirectionGooglePlaces_Minate
//
//  Created by Minate on 10/21/22.
//

import SwiftUI
import MapKit

struct MenuItem: Identifiable, Hashable {
    let id = UUID().uuidString
    let title: String
    let mapType: MKMapType
    let imageName: String
}

struct SlideMenuView: View {
    @State var isMenuShowing = false
    @State var mapType: MKMapType = .standard
    
    let menuItems: [MenuItem] = [.init(title: "Standard", mapType: .standard, imageName: "car"), .init(title: "Hybrid", mapType: .hybrid, imageName: "antenna.radiowaves.left.and.right"), .init(title: "Globe", mapType: .satelliteFlyover, imageName: "safari")]
    
    var body: some View {
        ZStack {
            SlideMenuMapView(mapType: mapType).edgesIgnoringSafeArea(.all)
            
            Color.init(UIColor(white: 0, alpha: self.isMenuShowing ? 0.5 : 0)).edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    self.isMenuShowing.toggle()
                }
                .animation(.spring())
            
            HStack {
                VStack {
                    Button {
                        self.isMenuShowing.toggle()
                    } label: {
                        Image(systemName: "line.horizontal.3.decrease.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                    }
                    Spacer()
                }
                Spacer()
            }.padding()
            
          
            
            HStack {
                ZStack {
                    Color(.systemBackground)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            self.isMenuShowing.toggle()
                        }
                    
                    HStack {
                        VStack {
                            HStack {
                                Text("Menu")
                                    .font(.system(size: 24, weight: .bold))
                                    .padding()
                                Spacer()
                            }
                            
                            ForEach(menuItems, id:\.self) { item in
                                Button {
                                    self.mapType = item.mapType
                                    self.isMenuShowing.toggle()
                                } label: {
                                    HStack(spacing: 16) {
                                        Image(systemName: item.imageName)
                                        Text(item.title)
                                        Spacer()
                                    }.padding()
                                }.foregroundColor(self.mapType != item.mapType ? Color(.label) : Color(.systemBackground))
                                    .background(self.mapType == item.mapType ? Color(.label) : Color(.systemBackground))
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                }.frame(width: 200)
                Spacer()
            }.offset(x: self.isMenuShowing ? 0 : -200)
                .animation(.spring())
        }
       
    }
}

struct SlideMenuMapView: UIViewRepresentable {
    
    var mapType: MKMapType
    
    func makeUIView(context: Context) -> MKMapView {
        MKMapView()
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.mapType = mapType
    }
}

struct SlideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SlideMenuView().colorScheme(.dark)
        SlideMenuView().colorScheme(.light)
        
    }
}
