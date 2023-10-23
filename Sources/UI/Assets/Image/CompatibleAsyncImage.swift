//
//  CompatibleAsyncImage.swift
//
//
//  Created by Bas van Kuijck on 26/10/2022.

import SwiftUI
import Combine
import IlluminateFoundation

public protocol AsyncImagePhaseable {
    static var empty: Self { get }
    static func success(_ image: Image) -> Self
    static func failure(_ error: Error) -> Self
    
    var image: Image? { get }
    var error: Error? { get }
}

@available(iOS 15.0, *)
extension AsyncImagePhase: AsyncImagePhaseable { }

public enum CompatibleAsyncImagePhase: AsyncImagePhaseable {
    case empty
    case success(Image)
    case failure(Error)
    
    public var image: Image? {
        if case let .success(image) = self {
            return image
        }
        return nil
    }
    
    public var error: Error? {
        if case let .failure(error) = self {
            return error
        }
        return nil
    }
}

@available(iOS, deprecated: 15.0, obsoleted: 17.0, message: "Please use `AsyncImage` when deployment target >= 15.0")
public struct CompatibleAsyncImage: View {
    private var phaseBuilder: (any AsyncImagePhaseable) -> any View
    private let url: URL
    
    @ObservedObject private var imageLoader: RemoteImageLoader
    
    public init(url: URL) {
        self.init(url: url) {
            $0
        } placeholder: {
            Rectangle().fill(Color.gray)
        }
    }
    
    public init<I: View>(
        url: URL,
        @ViewBuilder phase: @escaping (any AsyncImagePhaseable) -> I
    ) {
        self.url = url
        self.phaseBuilder = phase
        self.imageLoader = .init(url: url)
    }
    
    public init<I: View, P: View>(
        url: URL,
        @ViewBuilder content: @escaping (Image) -> I,
        @ViewBuilder placeholder: @escaping () -> P
    ) {
        self.init(url: url) { phase in
            if let image = phase.image {
                return AnyView(content(image))
                
            } else if phase.error != nil {
                return AnyView(EmptyView())
            }
            
            return AnyView(placeholder())
        }
    }
    
    public var body: some View {
        if #available(iOS 15.0, *) {
            AsyncImage(url: url) { phase in
                AnyView(phaseBuilder(phase))
            }
        } else if let image = imageLoader.image {
            AnyView(phaseBuilder(CompatibleAsyncImagePhase.success(Image(uiImage: image))))
        } else {
            AnyView(phaseBuilder(CompatibleAsyncImagePhase.empty))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private class RemoteImageLoader: ObservableObject {
    private let url: URL?
    @Published var loadingState = LoadingState.notLoading
    @Published var image: UIImage?
    private var cancellables = Set<AnyCancellable>()
    @State private(set) var isLoading: Bool = false
    
    init(url: URL?) {
        self.url = url
        $loadingState
            .map { $0 != .notLoading }
            .sink { [weak self] isLoading in
                self?.isLoading = isLoading
            }
            .store(in: &cancellables)
        
        load()
    }
    
    private func load() {
        guard let url else {
            return
        }
        
        loadingState = .loading
        
        URLSession(configuration: .default)
            .dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .catch { error -> Just<UIImage?> in
                print("[CompatibleAsyncImage] Error loading remote image \(url): \(error)")
                return Just(nil)
            }
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, image in
                owner.image = image
                owner.loadingState = .notLoading
            }
            .store(in: &cancellables)
    }
}

// MARK: - Previews
// --------------------------------------------------------
#if DEBUG
struct LegacyAsyncImage_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CompatibleAsyncImage(url: URL(string: "https://picsum.photos/200/300")!)
                .frame(width: 200, height: 300)
            
            CompatibleAsyncImage(url: URL(string: "https://picsum.photos/300/101")!) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Spinner()
                        .frame(width: 24, height: 24)
                }
            }.frame(width: 300, height: 100)
            
            CompatibleAsyncImage(url: URL(string: "https://picsum.photos/200/200")!) {
                $0
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Text("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }.frame(width: 200, height: 200)
            
            Spacer()
        }
    }
}
#endif


