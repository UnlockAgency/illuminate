//
//  UIViewController+combine.swift
//  Plein
//
//  Created by Thomas Roovers on 23/06/2022.
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation
import UIKit
import Combine
import CombineExt
import IlluminateFoundation

private var publisherKey: UInt8 = 0

extension UIViewController {
    public var publishers: UIViewController.Publishers {
        memoize(self, key: &publisherKey) {
            UIViewController.Publishers.swizzle()
            return UIViewController.Publishers()
        }
    }
    
    public class Publishers {
        private static var swizzled = false
        
        fileprivate init() {
            
        }
        
        public lazy var viewDidAppear = viewDidAppearRelay.eraseToAnyPublisher()
        fileprivate let viewDidAppearRelay = PassthroughRelay<Bool>()
        
        public lazy var viewWillAppear = viewWillAppearRelay.eraseToAnyPublisher()
        fileprivate let viewWillAppearRelay = PassthroughRelay<Bool>()
        
        public lazy var viewDidDisappear = viewDidDisappearRelay.eraseToAnyPublisher()
        fileprivate let viewDidDisappearRelay = PassthroughRelay<Bool>()
        
        public lazy var viewWillDisappear = viewWillDisappearRelay.eraseToAnyPublisher()
        fileprivate let viewWillDisappearRelay = PassthroughRelay<Bool>()
        
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
        publishers.viewDidAppearRelay.accept(animated)
    }
    
    @objc
    fileprivate func swizzledViewWillAppear(_ animated: Bool) {
        swizzledViewWillAppear(animated)
        publishers.viewWillAppearRelay.accept(animated)
    }
    
    @objc
    fileprivate func swizzledViewDidDisappear(_ animated: Bool) {
        swizzledViewDidDisappear(animated)
        publishers.viewDidDisappearRelay.accept(animated)
    }
    
    @objc
    fileprivate func swizzledViewWillDisappear(_ animated: Bool) {
        swizzledViewWillDisappear(animated)
        publishers.viewWillDisappearRelay.accept(animated)
    }
}
