//
//  gasolinaPreciosApp.swift
//  gasolinaPrecios
//
//  Created by Mario Bravo on 23/1/25.
//

import SwiftUI

@main
struct gasolinaPreciosApp: App {
    let locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(locationManager)
        }
    }
}
