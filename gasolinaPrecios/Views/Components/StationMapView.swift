import SwiftUI
import MapKit

struct StationMapView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var region: MKCoordinateRegion
    @State private var selectedStation: GasStation?
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        
        // Inicializar con la ubicación del usuario o Madrid como fallback
        if let userLocation = viewModel.locationManager.location {
            _region = State(initialValue: MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        } else {
            // Madrid como ubicación por defecto
            _region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(coordinateRegion: $region,
                showsUserLocation: true,
                annotationItems: viewModel.filteredStations) { station in
                MapAnnotation(coordinate: station.coordinates!) {
                    StationMapMarker(
                        station: station,
                        fuelType: viewModel.selectedFuelType,
                        isSelected: selectedStation == station
                    )
                    .onTapGesture {
                        withAnimation {
                            selectedStation = station
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            
            VStack(spacing: 16) {
                // Botón para centrar en ubicación del usuario
                Button {
                    centerOnUser()
                } label: {
                    Image(systemName: "location.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
                
                // Botón para ajustar zoom para ver todas las gasolineras
                Button {
                    showAllStations()
                } label: {
                    Image(systemName: "map.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
            }
            .padding()
            
            if let selected = selectedStation {
                StationPreviewCard(
                    station: selected,
                    fuelType: viewModel.selectedFuelType,
                    userLocation: viewModel.locationManager.location,
                    viewModel: viewModel
                )
                .transition(.move(edge: .bottom))
            }
        }
        .navigationTitle("Mapa de Gasolineras")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func centerOnUser() {
        if let userLocation = viewModel.locationManager.location {
            withAnimation {
                region.center = userLocation.coordinate
                region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            }
        }
    }
    
    private func showAllStations() {
        guard !viewModel.filteredStations.isEmpty else { return }
        
        let coordinates = viewModel.filteredStations.compactMap { $0.coordinates }
        guard !coordinates.isEmpty else { return }
        
        let minLat = coordinates.map { $0.latitude }.min()!
        let maxLat = coordinates.map { $0.latitude }.max()!
        let minLon = coordinates.map { $0.longitude }.min()!
        let maxLon = coordinates.map { $0.longitude }.max()!
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5,
            longitudeDelta: (maxLon - minLon) * 1.5
        )
        
        withAnimation {
            region = MKCoordinateRegion(center: center, span: span)
        }
    }
}

struct StationMapMarker: View {
    let station: GasStation
    let fuelType: FuelType
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(station.getPrice(for: fuelType))
                .font(.caption)
                .padding(4)
                .background(.white)
                .cornerRadius(4)
                .shadow(radius: 1)
            
            Image(systemName: "fuelpump.circle.fill")
                .font(.title)
                .foregroundColor(isSelected ? .blue : .red)
        }
        .scaleEffect(isSelected ? 1.2 : 1.0)
        .animation(.spring(), value: isSelected)
    }
}

struct StationPreviewCard: View {
    let station: GasStation
    let fuelType: FuelType
    let userLocation: CLLocation?
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        NavigationLink(destination: StationDetailView(
            station: station,
            userLocation: userLocation,
            viewModel: viewModel
        )) {
            VStack(alignment: .leading, spacing: 8) {
                Text(station.address)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(station.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    FuelIconView(fuelType: fuelType)
                        .frame(width: 20, height: 20)
                    
                    Text(station.getPrice(for: fuelType))
                        .font(.title3)
                        .bold()
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    if let coordinates = station.coordinates,
                       let userLocation = userLocation {
                        let distance = userLocation.distance(from: CLLocation(
                            latitude: coordinates.latitude,
                            longitude: coordinates.longitude
                        ))
                        Text(String(format: "%.1f km", distance/1000))
                            .font(.caption)
                            .padding(4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 5)
            .padding()
        }
    }
}
