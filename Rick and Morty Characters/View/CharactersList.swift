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
                            VStack(spacing: 16) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 44))
                                    .foregroundStyle(GalacticTheme.portalGreen)
                                Text("No Results")
                                    .font(.title3)
                                    .foregroundStyle(GalacticTheme.textSecondary)
                            }
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
                                    }
                                    if viewModel.hasMoreData {
                                        HStack {
                                            Spacer()
                                            GalacticLoadingView()
                                                .frame(height: 80)
                                            Spacer()
                                        }
                                        .listRowBackground(GalacticTheme.spaceBackground)
                                        .listRowSeparator(.hidden)
                                        .onAppear {
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
                            .scrollContentBackground(.hidden)
                            .background(GalacticTheme.spaceBackground)
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
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(GalacticTheme.sectionHeader, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
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
