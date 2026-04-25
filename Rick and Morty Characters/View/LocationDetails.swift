//
//  LocationDetails.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

struct LocationDetails: View {

    @ObservedObject private var viewModel: LocationDetailsViewModel

    init(id: Int) {
        viewModel = LocationDetailsViewModel(id: id)
    }

    var body: some View {
        Group {
            switch viewModel.status {
            case .loading:
                ProgressView()
            case .loaded(location: let location):
                List {
                    Section {
                        CharacterDetailsFormCell(key: "Name", value: location.name)
                        CharacterDetailsFormCell(key: "Type", value: location.type)
                        CharacterDetailsFormCell(key: "Dimension", value: location.dimension)
                    }

                    Section {
                        CharacterDetailsFormCell(key: "Residents", value: location.residents.count.description)
                        switch viewModel.residentsStatus {
                        case .idle:
                            if !location.residents.isEmpty {
                                Button("Load Residents") {
                                    viewModel.fetchResidents(urls: location.residents)
                                }
                            }
                        case .loading:
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        case .loaded(let characters):
                            ForEach(characters) { character in
                                NavigationLink {
                                    CharacterDetails(id: character.id)
                                } label: {
                                    CharactersListCell(character: character)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .onAppear {
                    if !location.residents.isEmpty {
                        viewModel.fetchResidents(urls: location.residents)
                    }
                }
            }
        }
        .navigationTitle("Location")
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("Retry") {
                viewModel.errorMessage = nil
                viewModel.retry()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

#Preview {
    NavigationStack {
        LocationDetails(id: 1)
    }
}
