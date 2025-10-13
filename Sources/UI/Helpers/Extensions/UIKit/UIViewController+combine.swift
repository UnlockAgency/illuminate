//
//  UIViewController+combine.swift
//
//  Created by Thomas Roovers on 23/06/2022.
//  Copyright © 2022 Unlock Agency. All rights reserved.
//

import Foundation
import UIKit
import Combine
import IlluminateFoundation

nonisolated(unsafe) private var publisherKey: UInt8 = 0

extension UIViewController {
    public var publishers: UIViewController.Publishers {
        memoize(self, key: &publisherKey) {
            UIViewController.Publishers.swizzle()
            return UIViewController.Publishers()
        }
    }
    
    public class Publishers {
        nonisolated(unsafe) private static var swizzled = false
        
        fileprivate init() {
            
        }
        
        public lazy var viewDidAppear = viewDidAppearSubject.eraseToAnyPublisher()
        fileprivate let viewDidAppearSubject = PassthroughSubject<Bool, Never>()
        
        public lazy var viewWillAppear = viewWillAppearSubject.eraseToAnyPublisher()
        fileprivate let viewWillAppearSubject = PassthroughSubject<Bool, Never>()
        
        public lazy var viewDidDisappear = viewDidDisappearSubject.eraseToAnyPublisher()
        fileprivate let viewDidDisappearSubject = PassthroughSubject<Bool, Never>()
        
        public lazy var viewWillDisappear = viewWillDisappearSubject.eraseToAnyPublisher()
        fileprivate let viewWillDisappearSubject = PassthroughSubject<Bool, Never>()
        
        fileprivate static func swizzle() {
            if swizzled {
                return
            }
            swizzling(for: UIViewController.self, original: #selector(viewDidAppear(_:)), swizzled: #selector(swizzledViewDidAppear(_:)))
            swizzling(for: UIViewController.self, original: #selector(viewWillAppear(_:)), swizzled: #selector(swizzledViewWillAppear(_:)))
            swizzling(for: UIViewController.self, original: #selector(viewDidDisappear(_:)), swizzled: #selector(swizzledViewDidDisappear(_:)))
            swizzling(for: UIViewController.self, original: #selector(viewWillDisappear(_:)), swizzled: #selector(swizzledViewWillDisappear(_:)))
            swizzled = true
        }
    }
    
    @objc
    fileprivate func swizzledViewDidAppear(_ animated: Bool) {
        swizzledViewDidAppear(animated)
        publishers.viewDidAppearSubject.send(animated)
    }
    
    @objc
    fileprivate func swizzledViewWillAppear(_ animated: Bool) {
        swizzledViewWillAppear(animated)
        publishers.viewWillAppearSubject.send(animated)
    }
    
    @objc
    fileprivate func swizzledViewDidDisappear(_ animated: Bool) {
        swizzledViewDidDisappear(animated)
        publishers.viewDidDisappearSubject.send(animated)
    }
    
    @objc
    fileprivate func swizzledViewWillDisappear(_ animated: Bool) {
        swizzledViewWillDisappear(animated)
        publishers.viewWillDisappearSubject.send(animated)
    }
}
