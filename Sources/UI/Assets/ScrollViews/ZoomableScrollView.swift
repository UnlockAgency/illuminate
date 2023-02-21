//
//  ZoomableScrollView.swift
//  
//
//  Created by Bas van Kuijck on 20/02/2023.
//

import Foundation
import SwiftUI
import UIKit

extension Notification.Name {
    public static var onResetZoomableScrollViewZoom = Notification.Name("onResetZoomableScrollViewZoom")
}

public struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    private var content: Content
    private let onZoom: ((CGFloat) -> Void)?
    
    public init(@ViewBuilder content: () -> Content, onZoom: ((CGFloat) -> Void)? = nil) {
        self.content = content()
        self.onZoom = onZoom
    }
    
    public func makeUIView(context: Context) -> UIScrollView {
        // set up the UIScrollView
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 10
        scrollView.minimumZoomScale = 1
        scrollView.bouncesZoom = true
        
        // create a UIHostingController to hold our SwiftUI content
        if let hostedView = context.coordinator.hostingController.view {
            hostedView.translatesAutoresizingMaskIntoConstraints = true
            hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            hostedView.frame = scrollView.bounds
            scrollView.addSubview(hostedView)
        }
        
        return scrollView
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: content), onZoom: onZoom)
    }
    
    public func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.onZoom = onZoom
        context.coordinator.hostingController.rootView = content
    }
    
    public class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>
        var onZoom: ((CGFloat) -> Void)?
        private var scrollView: UIScrollView?
        
        init(hostingController: UIHostingController<Content>, onZoom: ((CGFloat) -> Void)?) {
            self.hostingController = hostingController
            self.onZoom = onZoom
            hostingController.edgesForExtendedLayout = .all
            super.init()
            
            NotificationCenter.default.addObserver(self, selector: #selector(onResetZoomableScrollViewZoom), name: .onResetZoomableScrollViewZoom, object: nil)
        }
        
        @objc
        private func onResetZoomableScrollViewZoom() {
            scrollView?.zoomScale = 1.0
        }
        
        public func scrollViewDidZoom(_ scrollView: UIScrollView) {
            self.scrollView = scrollView
            onZoom?(scrollView.zoomScale)
        }
        
        public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
    }
}
