//
//  CachedAsyncImage.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View, ErrorView: View>: View {

    private enum LoadState {
        case loading
        case loaded(Image)
        case failed
    }

    private let url: URL?
    private let maxRetries: Int
    private let retryDelay: TimeInterval
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    private let errorView: () -> ErrorView

    @State private var loadState: LoadState = .loading
    @State private var retryCount: Int = 0

    init(
        url: URL?,
        maxRetries: Int = 3,
        retryDelay: TimeInterval = 1.0,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder,
        @ViewBuilder errorView: @escaping () -> ErrorView
    ) {
        self.url = url
        self.maxRetries = maxRetries
        self.retryDelay = retryDelay
        self.content = content
        self.placeholder = placeholder
        self.errorView = errorView
    }

    var body: some View {
        Group {
            switch loadState {
            case .loading:
                placeholder()
                    .task(id: retryCount) {
                        await loadImage()
                    }
            case .loaded(let image):
                content(image)
            case .failed:
                errorView()
            }
        }
    }

    @MainActor
    private func loadImage() async {
        guard let url else {
            loadState = .failed
            return
        }

        if let cached = ImageCache.shared.image(for: url) {
            loadState = .loaded(Image(uiImage: cached))
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let uiImage = UIImage(data: data) else {
                await handleFailure()
                return
            }
            ImageCache.shared.store(uiImage, for: url)
            loadState = .loaded(Image(uiImage: uiImage))
        } catch {
            await handleFailure()
        }
    }

    @MainActor
    private func handleFailure() async {
        if retryCount < maxRetries {
            try? await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
            retryCount += 1
        } else {
            loadState = .failed
        }
    }
}
