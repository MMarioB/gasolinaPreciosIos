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
    
    let locationManager: LocationManager
    
    // Cache para el filtrado
    private var lastSearchText = ""
    private var lastFilteredStations: [GasStation] = []
    
    init(locationManager: LocationManager) {
        self.locationManager = locationManager
    }
    
    var filteredStations: [GasStation] {
        if searchText == lastSearchText {
            return lastFilteredStations
        }
        
        lastSearchText = searchText
        
        guard !searchText.isEmpty else {
            lastFilteredStations = stations
            return stations
        }
        
        let searchTerms = searchText.lowercased().split(separator: " ")
        lastFilteredStations = stations.filter { station in
            let searchableText = "\(station.address) \(station.municipality) \(station.location)".lowercased()
            return searchTerms.allSatisfy { term in
                searchableText.contains(term)
            }
        }
        
        return lastFilteredStations
    }
    
    func fetchStations() async {
        isLoading = true
        error = nil
        
        do {
            let allStations = try await NetworkService.shared.fetchAllStations()
            
            // Calcular precios medios para cada tipo de combustible
            calculateAveragePrices(for: allStations)
            
            // Ordenar por distancia si tenemos ubicación
            if let userLocation = locationManager.location {
                self.stations = allStations.sorted { station1, station2 in
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
            } else {
                self.stations = allStations
            }
        } catch {
            self.error = error.localizedDescription
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
        let threshold = averagePrice * 0.02 // 2% de diferencia
        
        if difference <= -threshold {
            return .green // Más barato que la media
        } else if difference >= threshold {
            return .red // Más caro que la media
        } else {
            return .primary // Precio cercano a la media
        }
    }
    
    func getStationStatus(schedule: String) -> (isOpen: Bool, message: String) {
        if schedule.contains("24H") {
            return (true, "Abierto 24h")
        }
        
        // Aquí podríamos añadir más lógica para parsear otros formatos de horario
        return (true, schedule)
    }
}
