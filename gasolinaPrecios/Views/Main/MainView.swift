import SwiftUI
import CoreLocation

struct MainView: View {
    @StateObject private var viewModel: MainViewModel
    @State private var showingFuelTypeSelector = false
    
    init(locationManager: LocationManager) {
        _viewModel = StateObject(wrappedValue: MainViewModel(locationManager: locationManager))
    }
    
    var body: some View {
        TabView {
            NavigationView {
                ZStack {
                    Color(UIColor.systemGroupedBackground)
                        .ignoresSafeArea()
                    
                    if viewModel.isLoading {
                        loadingView
                    } else if viewModel.locationManager.location == nil {
                        locationUnavailableView
                    } else if viewModel.filteredStations.isEmpty {
                        if viewModel.isFirstLoad {
                            loadingView
                        } else if viewModel.searchText.isEmpty {
                            noNearbyStationsView
                        } else {
                            ContentUnavailableView.search
                        }
                    } else {
                        stationListView
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
                            viewModel.showAllStations.toggle()
                        } label: {
                            Image(systemName: viewModel.showAllStations ? "location.circle.fill" : "map")
                                .font(.title3)
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
                    FuelSelectorView(
                        selectedFuelType: $viewModel.selectedFuelType,
                        viewModel: viewModel
                    )
                }
            }
            .tabItem {
                Label("Lista", systemImage: "list.bullet")
            }
            
            NavigationView {
                StationMapView(viewModel: viewModel)
            }
            .tabItem {
                Label("Mapa", systemImage: "map")
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
    
    private var locationUnavailableView: some View {
        ContentUnavailableView(
            "Ubicación no disponible",
            systemImage: "location.slash",
            description: Text("Permite el acceso a tu ubicación para ver las gasolineras cercanas")
        )
        .overlay(alignment: .bottom) {
            Button {
                viewModel.locationManager.requestLocationPermission()
            } label: {
                Text("Permitir acceso a ubicación")
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.bottom, 50)
        }
    }
    
    private var noNearbyStationsView: some View {
        ContentUnavailableView(
            "No hay gasolineras cercanas",
            systemImage: "fuelpump.slash",
            description: Text("No se encontraron gasolineras en \(Int(viewModel.searchRadius))km")
        )
        .overlay(alignment: .bottom) {
            VStack(spacing: 16) {
                Button {
                    viewModel.searchRadius += 5
                    Task {
                        await viewModel.fetchStations()
                    }
                } label: {
                    Label("Ampliar radio (\(Int(viewModel.searchRadius + 5))km)", systemImage: "plus.circle")
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button {
                    viewModel.showAllStations = true
                } label: {
                    Label("Ver todas las gasolineras", systemImage: "map")
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button {
                    Task {
                        await viewModel.fetchStations()
                    }
                } label: {
                    Label("Actualizar", systemImage: "arrow.clockwise")
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.bottom, 50)
        }
    }
    
    private var stationListView: some View {
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
