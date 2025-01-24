//
//  StationsListView.swift
//  gasolinaPrecios
//
//  Created by Mario Bravo on 24/1/25.
//

import SwiftUI

struct StationListView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var showingFuelTypeSelector = false
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
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
            FuelSelectorView(selectedFuelType: $viewModel.selectedFuelType, viewModel: viewModel)
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
}
