// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RickAndMortyCharacters",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "RickAndMortyCharacters",
            targets: ["RickAndMortyCharacters"]
        )
    ],
    targets: [
        .target(
            name: "RickAndMortyCharacters",
            path: "Rick and Morty Characters",
            exclude: ["App/Rick_and_Morty_CharactersApp.swift", "Assets"]
        ),
        .testTarget(
            name: "RickAndMortyCharactersTests",
            dependencies: ["RickAndMortyCharacters"],
            path: "Rick and Morty CharactersTests"
        )
    ]
)
