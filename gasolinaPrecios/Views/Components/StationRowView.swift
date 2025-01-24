import SwiftUI
import CoreLocation

struct StationRowView: View {
    let station: GasStation
    let fuelType: FuelType
    let userLocation: CLLocation?
    @ObservedObject var viewModel: MainViewModel
    
    private var distanceString: String {
        guard let userLocation = userLocation,
              let stationLocation = station.coordinates else {
            return ""
        }
        
        let stationCLLocation = CLLocation(
            latitude: stationLocation.latitude,
            longitude: stationLocation.longitude
        )
        
        let distanceInMeters = userLocation.distance(from: stationCLLocation)
        if distanceInMeters < 1000 {
            return String(format: "%.0f m", distanceInMeters)
        } else {
            let distanceInKm = distanceInMeters / 1000
            return String(format: "%.1f km", distanceInKm)
        }
    }
    
    private var stationStatus: (isOpen: Bool, message: String) {
        viewModel.getStationStatus(schedule: station.schedule)
    }
    
    var body: some View {
        NavigationLink(destination: StationDetailView(
            station: station,
            userLocation: userLocation,
            viewModel: viewModel
        )) {
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 12) {
                    // Icono de estado
                    Circle()
                        .fill(stationStatus.isOpen ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                        .padding(.top, 8)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(station.address)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(station.municipality)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if station.location != station.municipality {
                            Text(station.location)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Horario
                        Label(stationStatus.message, systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        let price = station.getPrice(for: fuelType)
                        Text(price)
                            .font(.title2)
                            .bold()
                            .foregroundColor(viewModel.getPriceColor(price: price, for: fuelType))
                        
                        if !distanceString.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.caption)
                                Text(distanceString)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
    }
}
