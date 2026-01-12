//
//  CharacterDetails.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

struct CharacterDetails: View {
    
    @ObservedObject private var viewModel: CharactersDetailsViewModel
    
    init(id: Int) {
        viewModel = CharactersDetailsViewModel(id: id)
    }
    
    var body: some View {
        Group {
            switch viewModel.status {
            case .loading:
                ProgressView()
            case .loaded(character: let character):
                List {
                    Section {
                        AsyncImage(url: URL(string: character.image)) { image in
                            image.frame(maxWidth: .infinity, alignment: .center)
                        } placeholder: {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        }
                    }
                    
                    Section {
                        CharacterDetailsFormCell(key: "Name", value: character.name)
                        CharacterDetailsFormCell(key: "Status", value: character.status.presentationValue)
                        CharacterDetailsFormCell(key: "Species", value: character.species)
                        CharacterDetailsFormCell(key: "Type", value: character.type)
                        CharacterDetailsFormCell(key: "Gender", value: character.gender.presentationValue)
                        CharacterDetailsFormCell(key: "Origin", value: character.origin.name)
                        CharacterDetailsFormCell(key: "Location", value: character.location.name)
                    }
                    
                    Section {
                        CharacterDetailsFormCell(key: "Episodes", value: character.episode.count.description)
                        ForEach(character.episode, id: \.self) { episode in
                            Text(episode)
                        }
                    }
                }
            }
        }
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
    CharacterDetails(id: 1)
}
