// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RickAndMortyCharacters",
    platforms: [
        .iOS(.v17)
    ],
    targets: [
        .target(
            name: "RickAndMortyCharacters",
            path: "Rick and Morty Characters"
        ),
        .testTarget(
            name: "RickAndMortyCharactersTests",
            dependencies: ["RickAndMortyCharacters"],
            path: "Rick and Morty CharactersTests"
        ),
    ]
)
