//
//  SplashScreenView.swift
//  gasolinaPrecios
//
//  Created by Mario Bravo on 23/1/25.
//

import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject var locationManager: LocationManager
    @State private var isActive = false
    
    var body: some View {
        Group {
            if isActive {
                MainView(locationManager: locationManager)
            } else {
                ZStack {
                    Color("LaunchBackgroundColor")
                        .ignoresSafeArea()
                    
                    VStack {
                        Image(systemName: "fuelpump.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .onAppear {
            locationManager.requestLocationPermission()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
}
