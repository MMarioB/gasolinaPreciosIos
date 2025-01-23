//
//  StationMapView.swift
//  gasolinaPrecios
//
//  Created by Mario Bravo on 23/1/25.
//

import SwiftUI
import MapKit

struct StationMapView: View {
    let station: GasStation
    let userLocation: CLLocation?
    @State private var region: MKCoordinateRegion
    @State private var showingDirections = false
    @State private var selectedAnnotation: GasStation?
    
    init(station: GasStation, userLocation: CLLocation?) {
        self.station = station
        self.userLocation = userLocation
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        if let coordinates = station.coordinates {
            _region = State(initialValue: MKCoordinateRegion(
                center: coordinates,
                span: span
            ))
        } else {
            _region = State(initialValue: MKCoordinateRegion())
        }
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let coordinates = station.coordinates {
                Map(coordinateRegion: $region,
                    showsUserLocation: true,
                    annotationItems: [station]) { station in
                    MapAnnotation(coordinate: coordinates) {
                        VStack {
                            Image(systemName: "fuelpump.circle.fill")
                                .font(.title)
                                .foregroundColor(.red)
                            
                            Text(station.getPrice(for: .dieselA))
                                .font(.caption)
                                .padding(4)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .shadow(radius: 2)
                        }
                    }
                }
                .frame(height: 250)
                .cornerRadius(12)
                
                VStack(spacing: 8) {
                    Button {
                        centerOnStation()
                    } label: {
                        Image(systemName: "location.circle.fill")
                            .mapControlStyle()
                    }
                    
                    if userLocation != nil {
                        Button {
                            centerOnUser()
                        } label: {
                            Image(systemName: "person.circle.fill")
                                .mapControlStyle()
                        }
                    }
                    
                    Button {
                        openInMaps()
                    } label: {
                        Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                            .mapControlStyle()
                    }
                }
                .padding(8)
            }
        }
    }
    
    private func centerOnStation() {
        withAnimation {
            if let coordinates = station.coordinates {
                region.center = coordinates
                region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            }
        }
    }
    
    private func centerOnUser() {
        withAnimation {
            if let userLocation = userLocation {
                region.center = userLocation.coordinate
                region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            }
        }
    }
    
    private func openInMaps() {
        guard let coordinates = station.coordinates else { return }
        
        let placemark = MKPlacemark(coordinate: coordinates)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = station.address
        
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

// MARK: - Styling
extension Image {
    func mapControlStyle() -> some View {
        self
            .font(.title2)
            .foregroundColor(.blue)
            .frame(width: 44, height: 44)
            .background(Color.white)
            .clipShape(Circle())
            .shadow(radius: 3)
    }
}
