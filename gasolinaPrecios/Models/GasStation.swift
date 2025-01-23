import Foundation
import CoreLocation

struct GasStationsResponse: Codable {
    let fecha: String
    let listaEESSPrecio: [GasStation]
    
    enum CodingKeys: String, CodingKey {
        case fecha = "Fecha"
        case listaEESSPrecio = "ListaEESSPrecio"
    }
}

struct GasStation: Codable, Identifiable {
    let id = UUID()
    let postalCode: String
    let address: String
    let schedule: String
    let latitude: String
    let location: String
    let longitude: String
    let margin: String
    let municipality: String
    
    // Precios
    let biodieselPrice: String?
    let bioethanolPrice: String?
    let cngPrice: String?
    let lngPrice: String?
    let lpgPrice: String?
    let dieselAPrice: String?
    let dieselBPrice: String?
    let dieselPremiumPrice: String?
    let gasoline95E5Price: String?
    let gasoline95E5PremiumPrice: String?
    let gasoline98E5Price: String?
    
    enum CodingKeys: String, CodingKey {
        case postalCode = "C.P."
        case address = "Dirección"
        case schedule = "Horario"
        case latitude = "Latitud"
        case location = "Localidad"
        case longitude = "Longitud (WGS84)"
        case margin = "Margen"
        case municipality = "Municipio"
        case biodieselPrice = "Precio Biodiesel"
        case bioethanolPrice = "Precio Bioetanol"
        case cngPrice = "Precio Gas Natural Comprimido"
        case lngPrice = "Precio Gas Natural Licuado"
        case lpgPrice = "Precio Gases licuados del petróleo"
        case dieselAPrice = "Precio Gasoleo A"
        case dieselBPrice = "Precio Gasoleo B"
        case dieselPremiumPrice = "Precio Gasoleo Premium"
        case gasoline95E5Price = "Precio Gasolina 95 E5"
        case gasoline95E5PremiumPrice = "Precio Gasolina 95 E5 Premium"
        case gasoline98E5Price = "Precio Gasolina 98 E5"
    }
    
    // MARK: - Computed Properties
    var coordinates: CLLocationCoordinate2D? {
        guard let lat = Double(latitude.replacingOccurrences(of: ",", with: ".")),
              let lon = Double(longitude.replacingOccurrences(of: ",", with: ".")) else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    var fullAddress: String {
        "\(address), \(location), \(municipality) \(postalCode)"
    }
    
    // MARK: - Price Formatting Methods
    private func formatPrice(_ price: String?) -> String {
        guard let price = price, !price.isEmpty else { return "N/A" }
        return price.replacingOccurrences(of: ",", with: ".") + "€"
    }
    
    var formattedDieselAPrice: String { formatPrice(dieselAPrice) }
    var formattedDieselPremiumPrice: String { formatPrice(dieselPremiumPrice) }
    var formattedGasoline95E5Price: String { formatPrice(gasoline95E5Price) }
    var formattedGasoline95E5PremiumPrice: String { formatPrice(gasoline95E5PremiumPrice) }
    var formattedGasoline98E5Price: String { formatPrice(gasoline98E5Price) }
    var formattedLPGPrice: String { formatPrice(lpgPrice) }
    var formattedCNGPrice: String { formatPrice(cngPrice) }
    var formattedLNGPrice: String { formatPrice(lngPrice) }
    
    func getPrice(for fuelType: FuelType) -> String {
        switch fuelType {
        case .dieselA:
            return formattedDieselAPrice
        case .dieselPremium:
            return formattedDieselPremiumPrice
        case .gasoline95E5:
            return formattedGasoline95E5Price
        case .gasoline95E5Premium:
            return formattedGasoline95E5PremiumPrice
        case .gasoline98E5:
            return formattedGasoline98E5Price
        case .lpg:
            return formattedLPGPrice
        case .cng:
            return formattedCNGPrice
        case .lng:
            return formattedLNGPrice
        }
    }
}

enum FuelType: String, CaseIterable {
    case dieselA = "Gasóleo A"
    case dieselPremium = "Gasóleo Premium"
    case gasoline95E5 = "Gasolina 95 E5"
    case gasoline95E5Premium = "Gasolina 95 E5 Premium"
    case gasoline98E5 = "Gasolina 98 E5"
    case lpg = "GLP"
    case cng = "GNC"
    case lng = "GNL"
}
