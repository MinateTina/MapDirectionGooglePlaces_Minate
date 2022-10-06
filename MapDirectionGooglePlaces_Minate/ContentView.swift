//
//  ContentView.swift
//  MapDirectionGooglePlaces_Minate
//
//  Created by Minate on 9/23/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
//     MainView.ContainerView().edgesIgnoringSafeArea(.all)
     DirectionPreview.ContainerView().edgesIgnoringSafeArea(.all)
//        LocationSearch_Previews.ContainerView()
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
