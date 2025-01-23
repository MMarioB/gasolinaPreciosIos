import SwiftUI
import CoreLocation

struct MainView: View {
    @StateObject private var viewModel: MainViewModel
    @State private var showingFuelTypeSelector = false
    
    init(locationManager: LocationManager) {
        _viewModel = StateObject(wrappedValue: MainViewModel(locationManager: locationManager))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    loadingView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.filteredStations) { station in
                                StationRowView(
                                    station: station,
                                    fuelType: viewModel.selectedFuelType,
                                    userLocation: viewModel.locationManager.location,
                                    viewModel: viewModel
                                )
                            }
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        await viewModel.fetchStations()
                    }
                }
            }
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Buscar por dirección, municipio..."
            )
            .navigationTitle("Gasolineras")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Text("Combustible actual")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Button {
                            showingFuelTypeSelector = true
                        } label: {
                            Label(viewModel.selectedFuelType.rawValue, systemImage: "fuelpump.fill")
                        }
                    } label: {
                        Label("Combustible", systemImage: "fuelpump.circle.fill")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.fetchStations()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingFuelTypeSelector) {
                FuelTypeSelectorView(
                    selectedFuelType: $viewModel.selectedFuelType,
                    viewModel: viewModel
                )
            }
            .overlay {
                if !viewModel.isLoading && viewModel.filteredStations.isEmpty {
                    if viewModel.searchText.isEmpty {
                        ContentUnavailableView(
                            "No hay gasolineras",
                            systemImage: "fuelpump.slash",
                            description: Text("Intenta actualizar la lista")
                        )
                    } else {
                        ContentUnavailableView.search
                    }
                }
            }
        }
        .task {
            await viewModel.fetchStations()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Buscando gasolineras cercanas...")
                .foregroundColor(.secondary)
        }
    }
}
