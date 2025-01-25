import SwiftUI
import CoreLocation

@MainActor
class MainViewModel: ObservableObject {
    @Published var stations: [GasStation] = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var error: String?
    @Published var selectedFuelType: FuelType = .dieselA
    @Published var averagePrices: [FuelType: Double] = [:]
    @Published var isFirstLoad = true
    @Published var searchRadius: Double = 5.0  // Empezamos con 5km
    @Published var showAllStations = false     // Empezamos mostrando solo cercanas
    
    let locationManager: LocationManager
    
    private var lastSearchText = ""
    private var lastFilteredStations: [GasStation] = []
    
    init(locationManager: LocationManager) {
        self.locationManager = locationManager
    }
    
    var filteredStations: [GasStation] {
            print("🔍 Filtering stations:")
            print("- Total stations: \(stations.count)")
            print("- Search text: \(searchText)")
            print("- Is first load: \(isFirstLoad)")
            print("- Has location: \(locationManager.location != nil)")
            print("- Show all stations: \(showAllStations)")
            print("- Search radius: \(searchRadius)km")
            
            // Si hay búsqueda, filtrar por texto
            if !searchText.isEmpty {
                let filtered = stations.filter { station in
                    let searchableText = "\(station.address) \(station.municipality) \(station.location)".lowercased()
                    return searchText.lowercased().split(separator: " ").allSatisfy { term in
                        searchableText.contains(term)
                    }
                }
                print("- Filtered by search: \(filtered.count) stations")
                return filtered
            }
            
            // Al inicio, mostrar todas las estaciones ordenadas por distancia
            if let userLocation = locationManager.location {
                let sortedStations = stations.sorted { station1, station2 in
                    guard let location1 = station1.coordinates,
                          let location2 = station2.coordinates else {
                        return false
                    }
                    
                    let distance1 = userLocation.distance(from: CLLocation(
                        latitude: location1.latitude,
                        longitude: location1.longitude
                    ))
                    
                    let distance2 = userLocation.distance(from: CLLocation(
                        latitude: location2.latitude,
                        longitude: location2.longitude
                    ))
                    
                    return distance1 < distance2
                }
                
                // Si no estamos mostrando todas, filtrar por radio
                if !showAllStations {
                    let filtered = sortedStations.filter { station in
                        guard let coordinates = station.coordinates else { return false }
                        let distance = userLocation.distance(from: CLLocation(
                            latitude: coordinates.latitude,
                            longitude: coordinates.longitude
                        )) / 1000
                        return distance <= searchRadius
                    }
                    
                    print("- Filtered by distance (\(searchRadius)km): \(filtered.count) stations")
                    return filtered.isEmpty ? sortedStations : filtered
                }
                
                print("- Showing all stations sorted by distance: \(sortedStations.count)")
                return sortedStations
            }
            
            print("- Showing all stations unsorted: \(stations.count)")
            return stations
        }
        
        func fetchStations() async {
            print("📡 Fetching stations...")
            isLoading = true
            error = nil
            
            do {
                let allStations = try await NetworkService.shared.fetchAllStations()
                print("✅ Fetched \(allStations.count) stations")
                self.stations = allStations
                calculateAveragePrices(for: allStations)
                isFirstLoad = false
            } catch {
                self.error = error.localizedDescription
                print("❌ Error fetching stations: \(error.localizedDescription)")
            }
            
            isLoading = false
        }
    
    private func calculateAveragePrices(for stations: [GasStation]) {
        for fuelType in FuelType.allCases {
            let prices = stations.compactMap { station -> Double? in
                let price = station.getPrice(for: fuelType)
                guard price != "N/A",
                      let priceValue = Double(price.replacingOccurrences(of: "€", with: "")) else {
                    return nil
                }
                return priceValue
            }
            
            if !prices.isEmpty {
                averagePrices[fuelType] = prices.reduce(0, +) / Double(prices.count)
            }
        }
    }
    
    func getPriceColor(price: String, for fuelType: FuelType) -> Color {
        guard let averagePrice = averagePrices[fuelType],
              let priceValue = Double(price.replacingOccurrences(of: "€", with: "")) else {
            return .primary
        }
        
        let difference = priceValue - averagePrice
        let threshold = averagePrice * 0.02
        
        if difference <= -threshold {
            return .green
        } else if difference >= threshold {
            return .red
        } else {
            return .primary
        }
    }
    
    func getStationStatus(schedule: String) -> (isOpen: Bool, message: String) {
        if schedule.contains("24H") {
            return (true, "Abierto 24h")
        }
        return (true, schedule)
    }
}
