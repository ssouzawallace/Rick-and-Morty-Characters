//
//  CachedAsyncImage.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI
import UIKit

/// A cache-first replacement for `AsyncImage` that retries transient failures
/// before falling back to an error view.
struct CachedAsyncImage<Content: View, Placeholder: View, ErrorView: View>: View {

    private enum LoadState {
        case loading
        case loaded(Image)
        case failed
    }

    /// Identifies a single load attempt. A change to either field restarts the
    /// loading task, so a recycled cell pointed at a new URL reloads.
    private struct Attempt: Equatable {
        let url: URL?
        let retryCount: Int
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
            case .loaded(let image):
                content(image)
            case .failed:
                errorView()
            }
        }
        .onChange(of: url) { _, _ in
            retryCount = 0
            loadState = .loading
        }
        .task(id: Attempt(url: url, retryCount: retryCount)) {
            await loadImage()
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

        loadState = .loading

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                throw NetworkingError.request(response.statusCode)
            }

            guard let uiImage = UIImage(data: data) else {
                await handleFailure()
                return
            }

            ImageCache.shared.store(uiImage, for: url)
            loadState = .loaded(Image(uiImage: uiImage))
        } catch is CancellationError {
            // The view was reused or went away; the next attempt starts fresh.
        } catch let error as URLError where error.code == .cancelled {
            // URLSession surfaces cancellation as URLError.cancelled.
        } catch {
            await handleFailure()
        }
    }

    /// Schedules another attempt, or gives up once `maxRetries` is reached.
    @MainActor
    private func handleFailure() async {
        guard retryCount < maxRetries else {
            loadState = .failed
            return
        }

        do {
            try await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
        } catch {
            return
        }

        guard !Task.isCancelled else { return }

        retryCount += 1
    }
}
