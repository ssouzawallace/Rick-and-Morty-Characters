//
//  CharactersList.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

struct CharactersList: View {
    
    @ObservedObject var viewModel = CharactersListViewModel()

    @GalacticBackgroundPreference private var background
    
    var body: some View {
        NavigationStack {
            ZStack {
                background.color.ignoresSafeArea()

                Group {
                    switch viewModel.status {
                    case .loading:
                        GalacticLoadingView()

                    case .loaded(let characters):
                        if characters.isEmpty {
                            GalacticEmptyState()
                        } else {
                            List {
                                Section {
                                    ForEach(characters) { character in
                                        NavigationLink {
                                            CharacterDetails(id: character.id)
                                        } label: {
                                            CharactersListCell(character: character)
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
                                .listRowBackground(background.color)
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
            .navigationTitle(Text("Characters"))
            .galacticNavigationBar()
            .galacticSettingsToolbar()
            .searchable(text: $viewModel.searchText, prompt: Text("Search by name"))
            // A real search scope bar rather than a Picker in the list: the system
            // puts it under the search field, inside the navigation bar, and moves
            // it with the field as it activates.
            // .onSearchPresentation rather than the default: the scopes appear as
            // soon as the field is focused, so the status filter is reachable
            // without first typing a name.
            .searchScopes($viewModel.searchScope, activation: .onSearchPresentation) {
                ForEach(CharacterStatus.allCases, id: \.self) { status in
                    Text(status == .undefined ? "All" : status.presentationValue)
                        .tag(status)
                }
            }
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
    CharactersList()
}
