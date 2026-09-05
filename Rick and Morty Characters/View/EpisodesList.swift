//
//  EpisodesList.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

struct EpisodesList: View {

    @ObservedObject var viewModel = EpisodesListViewModel()

    @GalacticBackgroundPreference private var background

    var body: some View {
        NavigationStack {
            ZStack {
                background.color.ignoresSafeArea()

                Group {
                    switch viewModel.status {
                    case .loading:
                        GalacticLoadingView()

                    case .loaded(let episodes):
                        if episodes.isEmpty {
                            GalacticEmptyState(systemImage: "tv.fill")
                        } else {
                            List {
                                ForEach(episodes) { episode in
                                    NavigationLink {
                                        EpisodeDetails(id: episode.id)
                                    } label: {
                                        EpisodesListCell(episode: episode)
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
            .navigationTitle(Text("Episodes"))
            .galacticNavigationBar()
        .galacticSettingsToolbar()
            .searchable(text: $viewModel.searchText, prompt: Text("Search by name"))
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("Retry") {
                    viewModel.retry()
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
