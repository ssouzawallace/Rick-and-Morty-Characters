//
//  EpisodesList.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

struct EpisodesList: View {

    @ObservedObject var viewModel = EpisodesListViewModel()

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.status {
                case .loading:
                    ProgressView()
                case .loaded(let episodes):
                    if episodes.isEmpty {
                        Text("No Results")
                    } else {
                        List {
                            ForEach(episodes) { episode in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(episode.name)
                                        .font(.headline)
                                    Text(episode.episode)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Text(episode.airDate)
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(.vertical, 4)
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
            .navigationTitle(Text("Episodes"))
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
    EpisodesList()
}
