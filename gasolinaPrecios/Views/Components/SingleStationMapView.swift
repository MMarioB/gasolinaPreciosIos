//
//  SingleStationMapView.swift
//  gasolinaPrecios
//
//  Created by Mario Bravo on 24/1/25.
//

import SwiftUI
import MapKit

struct SingleStationMapView: View {
    let station: GasStation
    let userLocation: CLLocation?
    @State private var region: MKCoordinateRegion
    
    init(station: GasStation, userLocation: CLLocation?) {
        self.station = station
        self.userLocation = userLocation
        
        if let coordinates = station.coordinates {
            _region = State(initialValue: MKCoordinateRegion(
                center: coordinates,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
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
                                .background(.white)
                                .cornerRadius(4)
                                .shadow(radius: 1)
                        }
                    }
                }
                .frame(height: 200)
                .cornerRadius(12)
                
                Button {
                    openInMaps()
                } label: {
                    Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
                .padding(8)
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
