import SwiftUI

struct FuelTypeSelectorView: View {
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
