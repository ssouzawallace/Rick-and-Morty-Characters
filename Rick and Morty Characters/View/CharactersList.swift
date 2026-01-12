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
            Group {
                switch viewModel.status {
                case .loading:
                    ProgressView()
                case .loaded(let characters):
                    if characters.isEmpty {
                        Text("No Results")
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
                                        ProgressView()
                                        Spacer()
                                    }
                                    .onAppear {
                                        viewModel.fetchNextPage()
                                    }
                                }
                            } header: {
                                Picker("Search by Status", selection: $viewModel.searchScope) {
                                    ForEach(CharacterStatus.allCases, id: \.self) { status in
                                        Text(status == .undefined ? "All" : status.presentationValue).tag(status)
                                    }
                                }
                            }

                        }
                        .navigationLinkIndicatorVisibility(.hidden)
                        .listStyle(.plain)
                        .refreshable {
                            viewModel.fetchInitialData()
                        }
                    }
                }
            }
            .navigationTitle(Text("Characters"))
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
