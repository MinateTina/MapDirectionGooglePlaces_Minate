//
//  MapDirectionGooglePlaces_MinateApp.swift
//  MapDirectionGooglePlaces_Minate
//
//  Created by Minate on 9/23/22.
//

import SwiftUI
import GooglePlaces

@main
struct MapDirectionGooglePlaces_MinateApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
           ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        GMSPlacesClient.provideAPIKey("")
        return true
    }
}

