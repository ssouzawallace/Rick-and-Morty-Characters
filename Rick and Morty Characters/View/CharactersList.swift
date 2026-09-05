//
//  CharactersList.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

struct CharactersList: View {
    
    @ObservedObject var viewModel = CharactersListViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                GalacticTheme.spaceBackground.ignoresSafeArea()

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
                                } header: {
                                    Picker("Search by Status", selection: $viewModel.searchScope) {
                                        ForEach(CharacterStatus.allCases, id: \.self) { status in
                                            Text(status == .undefined ? "All" : status.presentationValue)
                                                .tag(status)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                    .padding(.vertical, 6)
                                }
                                .listRowBackground(GalacticTheme.spaceBackground)
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
    CharactersList()
}
