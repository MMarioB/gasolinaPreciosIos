import SwiftUI
import CoreLocation

struct StationDetailView: View {
    let station: GasStation
    let userLocation: CLLocation?
    let viewModel: MainViewModel
    @State private var selectedSection = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Mapa mejorado
                if let coordinates = station.coordinates {
                    SingleStationMapView(
                        station: station,
                        userLocation: userLocation
                    )
                    .padding(.horizontal)
                }
                
                VStack(spacing: 16) {
                    // Estado y horario
                    DetailInfoCard(title: "Estado y Horario") {
                        VStack(alignment: .leading, spacing: 12) {
                            // Estado (abierto/cerrado)
                            HStack {
                                Circle()
                                    .fill(station.schedule.contains("24H") ? Color.green : .orange)
                                    .frame(width: 10, height: 10)
                                Text(station.schedule.contains("24H") ? "Abierto 24h" : "Horario regular")
                                    .foregroundColor(.secondary)
                            }
                            
                            InfoRow(icon: "clock", title: "Horario de apertura", value: station.schedule)
                            if !station.schedule.contains("24H") {
                                InfoRow(icon: "exclamationmark.triangle",
                                      title: "Nota",
                                      value: "Confirma el horario en la estación")
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    
                    // Ubicación
                    DetailInfoCard(title: "Ubicación") {
                        VStack(alignment: .leading, spacing: 12) {
                            InfoRow(icon: "mappin.and.ellipse",
                                  title: "Dirección",
                                  value: station.address)
                            
                            InfoRow(icon: "building.2",
                                  title: "Localidad",
                                  value: station.location)
                            
                            InfoRow(icon: "building.columns",
                                  title: "Municipio",
                                  value: station.municipality)
                            
                            InfoRow(icon: "envelope",
                                  title: "Código postal",
                                  value: station.postalCode)
                            
                            if let coordinates = station.coordinates,
                               let userLocation = userLocation {
                                let distance = userLocation.distance(from: CLLocation(
                                    latitude: coordinates.latitude,
                                    longitude: coordinates.longitude
                                ))
                                InfoRow(
                                    icon: "location.fill",
                                    title: "Distancia desde tu ubicación",
                                    value: formatDistance(meters: distance)
                                )
                            }
                            
                            InfoRow(icon: "arrow.left.and.right",
                                  title: "Margen de la vía",
                                  value: interpretMargin(station.margin))
                        }
                    }
                    
                    // Precios actuales
                    DetailInfoCard(title: "Precios Disponibles") {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(FuelType.allCases, id: \.self) { fuelType in
                                if station.getPrice(for: fuelType) != "N/A" {
                                    PriceRow(
                                        fuelType: fuelType,
                                        price: station.getPrice(for: fuelType)
                                    )
                                }
                            }
                        }
                    }
                    
                    // Servicios adicionales
                    DetailInfoCard(title: "Servicios Adicionales") {
                        VStack(alignment: .leading, spacing: 12) {
                            ServiceRow(title: "Autoservicio",
                                     icon: "figure.walk",
                                     available: station.schedule.contains("24H"))
                            
                            ServiceRow(title: "Abierto 24h",
                                     icon: "clock.fill",
                                     available: station.schedule.contains("24H"))
                            
                            ServiceRow(title: "Tienda",
                                     icon: "cart.fill",
                                     available: true)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(station.address)
    }
    
    private func formatDistance(meters: CLLocationDistance) -> String {
        if meters < 1000 {
            return String(format: "%.0f metros", meters)
        } else {
            return String(format: "%.1f kilómetros", meters/1000)
        }
    }
    
    private func interpretMargin(_ margin: String) -> String {
        switch margin {
        case "D":
            return "Derecho"
        case "I":
            return "Izquierdo"
        default:
            return "No especificado"
        }
    }
}

// MARK: - Supporting Views
struct DetailInfoCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            content()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .foregroundColor(.secondary)
            }
            .font(.caption)
            
            Text(value)
                .font(.body)
        }
    }
}

struct PriceRow: View {
    let fuelType: FuelType
    let price: String
    
    var body: some View {
        HStack {
            FuelIconView(fuelType: fuelType)
                .frame(width: 24, height: 24)
            
            Text(fuelType.rawValue)
            
            Spacer()
            
            Text(price)
                .bold()
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.1))
                .foregroundColor(.green)
                .cornerRadius(8)
        }
    }
}

struct ServiceRow: View {
    let title: String
    let icon: String
    let available: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(available ? .green : .red)
                .frame(width: 24)
            
            Text(title)
            
            Spacer()
            
            Image(systemName: available ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(available ? .green : .red)
        }
    }
}

// MARK: - Preview
struct StationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let locationManager = LocationManager()
        NavigationView {
            StationDetailView(
                station: GasStation(
                    postalCode: "28001",
                    address: "Calle de Ejemplo, 1",
                    schedule: "L-D: 24H",
                    latitude: "40.416775",
                    location: "Madrid",
                    longitude: "-3.703790",
                    margin: "D",
                    municipality: "Madrid",
                    biodieselPrice: nil,
                    bioethanolPrice: nil,
                    cngPrice: nil,
                    lngPrice: nil,
                    lpgPrice: nil,
                    dieselAPrice: "1.489",
                    dieselBPrice: nil,
                    dieselPremiumPrice: "1.589",
                    gasoline95E5Price: "1.679",
                    gasoline95E5PremiumPrice: "1.779",
                    gasoline98E5Price: "1.879"
                ),
                userLocation: CLLocation(latitude: 40.416775, longitude: -3.703790),
                viewModel: MainViewModel(locationManager: locationManager)
            )
        }
    }
}
