//
//  VerticalCustomPushAnimator.swift
//  Illuminate
//
//  Created by Bas van Kuijck on 08/08/2025.
//

import UIKit
import Foundation

open class VerticalCustomPushAnimator: NSObject, UIViewControllerAnimatedTransitioning, CustomTransitionAnimator {
    private lazy var overlayView: UIView = {
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        return overlayView
    }()
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPushing {
            guard let fromVC = transitionContext.viewController(forKey: .from), let toVC = transitionContext.viewController(forKey: .to) else { return }
            let containerView = transitionContext.containerView
            
            let finalFrame = transitionContext.finalFrame(for: toVC)
            var startFrame = finalFrame
            startFrame.origin.y = containerView.bounds.height // start below screen
            toVC.view.frame = startFrame
            
            overlayView.frame = fromVC.view.bounds
            fromVC.view.addSubview(overlayView)
            overlayView.alpha = 0
            
            toVC.view.layer.shadowColor = UIColor.black.cgColor
            toVC.view.layer.shadowOffset = CGSize(width: 0, height: -8)
            toVC.view.layer.shadowOpacity = 0.025
            toVC.view.layer.shadowRadius = 5
            
            containerView.addSubview(toVC.view)
            
            UIView.animate(
                withDuration: transitionDuration(using: transitionContext),
                delay: 0,
                options: [.curveEaseOut],
                animations: { [overlayView] in
                    overlayView.alpha = 1
                    toVC.view.frame = finalFrame
                    toVC.view.layer.shadowOpacity = 0.05
                }, completion: { [overlayView] finished in
                    overlayView.removeFromSuperview()
                    toVC.view.layer.shadowOpacity = 0
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
            
            overlayView.frame = toVC.view.bounds
            toVC.view.addSubview(overlayView)
            
            toVC.view.layer.shadowColor = UIColor.black.cgColor
            toVC.view.layer.shadowOffset = CGSize(width: 0, height: -8)
            toVC.view.layer.shadowOpacity = 0.05
            toVC.view.layer.shadowRadius = 5
            
            UIView.animate(
                withDuration: transitionDuration(using: transitionContext),
                delay: 0,
                options: [.curveEaseIn],
                animations: { [overlayView] in
                    toVC.view.layer.shadowOpacity = 0.025
                    overlayView.alpha = 0
                    fromVC.view.frame = finalFrame
                }, completion: { [overlayView] finished in
                    toVC.view.layer.shadowOpacity = 0
                    overlayView.removeFromSuperview()
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled && finished)
                }
            )
        }
    }
}
