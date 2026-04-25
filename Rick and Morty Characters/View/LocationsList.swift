//
//  LocationsList.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

struct LocationsList: View {

    @ObservedObject var viewModel = LocationsListViewModel()

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.status {
                case .loading:
                    ProgressView()
                case .loaded(let locations):
                    if locations.isEmpty {
                        Text("No Results")
                    } else {
                        List {
                            ForEach(locations) { location in
                                NavigationLink {
                                    LocationDetails(id: location.id)
                                } label: {
                                    VStack(alignment: .leading) {
                                        Text(location.name)
                                            .font(.headline)
                                        Text(location.type)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.vertical, 4)
                                }
                                .buttonStyle(.plain)
                            }
                            if viewModel.hasMoreData {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                                .onAppear {
                                    viewModel.fetchNextPage()
                                }
                            }
                        }
                        .listStyle(.plain)
                        .refreshable {
                            viewModel.fetchInitialData()
                        }
                    }
                }
            }
            .navigationTitle(Text("Locations"))
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
