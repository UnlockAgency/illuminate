//
//  CustomTransitionManager.swift
//  Illuminate
//
//  Created by Bas van Kuijck on 15/08/2025.
//

import Foundation
import UIKit

nonisolated(unsafe) private var customTransitionManagerKey: UInt8 = 0

extension UINavigationController {
    var customTransitionManager: CustomTransitionManager {
        if let value = objc_getAssociatedObject(self, &customTransitionManagerKey) as? CustomTransitionManager {
            return value
        }
        let newValue = CustomTransitionManager()
        objc_setAssociatedObject(self, &customTransitionManagerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return newValue
    }
}


class CustomTransitionManager: NSObject, UINavigationControllerDelegate {
    private var animators = NSMapTable<UIViewController, UIViewControllerAnimatedTransitioning>(keyOptions: .weakMemory, valueOptions: .strongMemory)
    
    func add(_ value: CustomTransitionAnimator & UIViewControllerAnimatedTransitioning, viewController: UIViewController) {
        animators.setObject(value, forKey: viewController)
    }
    
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push, var animator = animators.object(forKey: toVC) as? UIViewControllerAnimatedTransitioning & CustomTransitionAnimator {
            animator.isPushing = true
            return animator
            
        } else if operation == .pop, var animator = animators.object(forKey: fromVC) as? UIViewControllerAnimatedTransitioning & CustomTransitionAnimator {
            animator.isPushing = false
            return animator
        }
        
        return nil
    }
}
