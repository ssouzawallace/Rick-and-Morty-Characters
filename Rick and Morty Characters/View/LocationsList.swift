//
//  LocationsList.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

struct LocationsList: View {

    @ObservedObject var viewModel = LocationsListViewModel()

    @GalacticBackgroundPreference private var background

    var body: some View {
        NavigationStack {
            ZStack {
                background.color.ignoresSafeArea()

                Group {
                    switch viewModel.status {
                    case .loading:
                        GalacticLoadingView()

                    case .loaded(let locations):
                        if locations.isEmpty {
                            GalacticEmptyState(systemImage: "globe.americas.fill")
                        } else {
                            List {
                                ForEach(locations) { location in
                                    NavigationLink {
                                        LocationDetails(id: location.id)
                                    } label: {
                                        LocationsListCell(location: location)
                                    }
                                    .buttonStyle(.plain)
                                    .galacticListRow()
                                }

                                if viewModel.hasMoreData {
                                    GalacticPagingFooter {
                                        viewModel.fetchNextPage()
                                    }
                                }
                            }
                            .galacticList()
                            .listStyle(.plain)
                            .navigationLinkIndicatorVisibility(.hidden)
                            .refreshable {
                                viewModel.fetchInitialData()
                            }
                        }
                    }
                }
            }
            .navigationTitle(Text("Locations"))
            .galacticNavigationBar()
        .galacticSettingsToolbar()
            .searchable(text: $viewModel.searchText, prompt: Text("Search by name"))
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("Retry") {
                    viewModel.errorMessage = nil
                    viewModel.fetchInitialData()
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

#Preview {
    LocationsList()
}
