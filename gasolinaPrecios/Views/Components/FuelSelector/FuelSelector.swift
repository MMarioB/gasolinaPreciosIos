//
//  FuelSelector.swift
//  gasolinaPrecios
//
//  Created by Mario Bravo on 23/1/25.
//

import SwiftUI

// MARK: - Fuel Type Group
struct FuelGroup {
    let title: String
    let fuelTypes: [FuelType]
}

// MARK: - Main Selector View
struct FuelSelectorView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedFuelType: FuelType
    @ObservedObject var viewModel: MainViewModel
    
    private let fuelGroups = [
        FuelGroup(title: "Gasóleo", fuelTypes: [.dieselA, .dieselPremium]),
        FuelGroup(title: "Gasolina", fuelTypes: [.gasoline95E5, .gasoline95E5Premium, .gasoline98E5]),
        FuelGroup(title: "Gas", fuelTypes: [.lpg, .cng, .lng])
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(fuelGroups, id: \.title) { group in
                    Section(header: Text(group.title)) {
                        ForEach(group.fuelTypes, id: \.self) { fuelType in
                            FuelTypeRow(
                                fuelType: fuelType,
                                isSelected: selectedFuelType == fuelType,
                                averagePrice: viewModel.averagePrices[fuelType]
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    selectedFuelType = fuelType
                                    dismiss()
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Tipo de Combustible")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Row Component
struct FuelTypeRow: View {
    let fuelType: FuelType
    let isSelected: Bool
    let averagePrice: Double?
    
    var body: some View {
        HStack {
            // Icono y nombre
            HStack(spacing: 12) {
                FuelIconView(fuelType: fuelType)
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(fuelType.rawValue)
                        .font(.body)
                    
                    if let price = averagePrice {
                        Text("Precio medio: \(String(format: "%.3f€", price))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Checkmark si está seleccionado
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
    }
}

// MARK: - Icon Component
struct FuelIconView: View {
    let fuelType: FuelType
    
    var body: some View {
        ZStack {
            Circle()
                .fill(iconBackgroundColor)
            
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    private var iconName: String {
        switch fuelType {
        case .dieselA, .dieselPremium:
            return "d.circle.fill"
        case .gasoline95E5, .gasoline95E5Premium, .gasoline98E5:
            return "g.circle.fill"
        case .lpg:
            return "l.circle.fill"
        case .cng, .lng:
            return "n.circle.fill"
        }
    }
    
    private var iconBackgroundColor: Color {
        switch fuelType {
        case .dieselA:
            return .black
        case .dieselPremium:
            return .purple
        case .gasoline95E5:
            return .green
        case .gasoline95E5Premium:
            return .blue
        case .gasoline98E5:
            return .red
        case .lpg, .cng, .lng:
            return .orange
        }
    }
}
