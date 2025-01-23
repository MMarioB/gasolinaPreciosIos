import Foundation
import CoreLocation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .noData:
            return "No se recibieron datos"
        case .decodingError:
            return "Error al procesar los datos"
        case .serverError(let error):
            return "Error del servidor: \(error.localizedDescription)"
        }
    }
}

class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes"
    
    private init() {}
    
    func fetchAllStations() async throws -> [GasStation] {
        let endpoint = "\(baseURL)/EstacionesTerrestres"
        print("📍 Trying to fetch from URL: \(endpoint)")
        
        guard let url = URL(string: endpoint) else {
            print("❌ Invalid URL: \(endpoint)")
            throw NetworkError.invalidURL
        }
        
        do {
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Not an HTTP response")
                throw NetworkError.serverError(NSError(domain: "", code: -1, userInfo: nil))
            }
            
            print("📥 Response status code: \(httpResponse.statusCode)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📦 Raw response data: \(responseString.prefix(500))...")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("❌ Bad HTTP response: \(httpResponse.statusCode)")
                throw NetworkError.serverError(NSError(domain: "", code: httpResponse.statusCode, userInfo: nil))
            }
            
            let decoder = JSONDecoder()
            let gasStationsResponse = try decoder.decode(GasStationsResponse.self, from: data)
            print("✅ Successfully decoded response")
            
            print("✅ Found \(gasStationsResponse.listaEESSPrecio.count) stations")
            return gasStationsResponse.listaEESSPrecio
            
        } catch let error as DecodingError {
            print("❌ Decoding error: \(error)")
            switch error {
            case .keyNotFound(let key, _):
                print("Missing key: \(key)")
            case .valueNotFound(let type, _):
                print("Missing value of type: \(type)")
            case .typeMismatch(let type, _):
                print("Type mismatch, expected: \(type)")
            default:
                print("Other decoding error: \(error)")
            }
            throw NetworkError.decodingError
        } catch {
            print("❌ Network request failed: \(error)")
            throw NetworkError.serverError(error)
        }
    }
}
