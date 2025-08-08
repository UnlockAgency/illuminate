//
//  VerticalCustomPushAnimator.swift
//  Illuminate
//
//  Created by Bas van Kuijck on 08/08/2025.
//

import UIKit
import Foundation

open class VerticalCustomPushAnimator: NSObject, UIViewControllerAnimatedTransitioning, CustomTransitionAnimator {
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPushing {
            guard let toVC = transitionContext.viewController(forKey: .to) else { return }
            let containerView = transitionContext.containerView
            
            let finalFrame = transitionContext.finalFrame(for: toVC)
            var startFrame = finalFrame
            startFrame.origin.y = containerView.bounds.height // start below screen
            toVC.view.frame = startFrame
            
            containerView.addSubview(toVC.view)
            
            UIView.animate(
                withDuration: transitionDuration(using: transitionContext),
                delay: 0,
                options: [.curveEaseOut],
                animations: {
                    toVC.view.frame = finalFrame
                }, completion: { finished in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled && finished)
                }
            )
        } else {
            guard let fromVC = transitionContext.viewController(forKey: .from), let toVC = transitionContext.viewController(forKey: .to) else { return }
            
            let containerView = transitionContext.containerView
            containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
            
            let initialFrame = transitionContext.initialFrame(for: fromVC)
            var finalFrame = initialFrame
            finalFrame.origin.y = containerView.bounds.height
            
            UIView.animate(
                withDuration: transitionDuration(using: transitionContext),
                delay: 0,
                options: [.curveEaseIn],
                animations: {
                    fromVC.view.frame = finalFrame
                }, completion: { finished in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled && finished)
                }
            )
        }
    }
}
