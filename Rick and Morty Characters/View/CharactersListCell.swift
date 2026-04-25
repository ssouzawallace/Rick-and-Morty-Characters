//
//  CharactersListCell.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

struct CharactersListCell: View {
    
    private struct NoImageView: View {
        
        @Binding var bottomOverlayHeight: CGFloat
        
        var body: some View {
            ZStack {
                Rectangle()
                    .fill(.gray)
                
                Text("No Image")
                    .alignmentGuide(VerticalAlignment.center) { _ in
                        bottomOverlayHeight / 2
                    }
            }
        }
    }
    
    @State private var bottomOverlayHeight: CGFloat = 0
    
    let character: Character
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            ZStack {
                CachedAsyncImage(
                    url: URL(string: character.image),
                    content: { image in
                        image.resizable()
                    },
                    placeholder: {
                        ProgressView()
                    },
                    errorView: {
                        NoImageView(bottomOverlayHeight: $bottomOverlayHeight)
                    }
                )
            }
            .aspectRatio(1, contentMode: .fit)
            
            VStack(alignment: .leading) {
                Text(character.name)
                    .bold()
                Divider()
                CharacterDetailsFormCell(
                    key: "Status",
                    value: character.status.presentationValue
                )
                CharacterDetailsFormCell(
                    key: "Species",
                    value: character.species
                )
            }
            .padding()
            .background(.white.opacity(0.8))
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            bottomOverlayHeight = proxy.size.height
                        }
                }
            }
        }
        .padding()
    }
}


#Preview {
    CharactersListCell(
        character: Character(
            id: 1,
            name: "One True Rick Sanchez",
            status: .alive,
            species: "Human",
            type: "Some Type",
            gender: .male,
            origin: CharacterPlacement(name: "Earth", url: ""),
            location: CharacterPlacement(name: "Somewhere", url: ""),
            image: "Zhttps://rickandmortyapi.com/api/character/avatar/1.jpeg",
            episode: [],
            url: "",
            created: nil
        )
    )
}
