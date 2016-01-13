//
//  TransformAnimator.swift
//  Example
//
//  Created by Mingloan Chan on 28/12/2015.
//
//

import Foundation
import UIKit

class TransformAnimator: NSObject {
    
    var duration: NSTimeInterval = 0.4
    var presenting = true
    weak var transitionDelegate: SimpleTransition?

}

extension TransformAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        guard let transitionDelegate = transitionDelegate else {
            assert(1 != 1, "fatal error: no transition manager, please file as a bug")
            return
        }
        
        let spring = transitionDelegate.animatedMotionOption == .Spring
        
        let fading = transitionDelegate.fadingEnabled
        
        let presentingViewSizeOption = transitionDelegate.presentingViewSizeOption
        let presentedViewAlignment = transitionDelegate.presentedViewAlignment
        let animation = transitionDelegate.animation
        let initialSpringVelocity = transitionDelegate.initialSpringVelocity
        let springDamping = transitionDelegate.springDamping
        
        let presentedViewSize = transitionDelegate.presentedViewSize
        
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)
        
        guard let containerView = transitionContext.containerView() else {
            return
        }

        var presentingView: UIView?
        var presentedView: UIView!
        
        if presenting {
            presentingView = fromView
            presentedView = toView
        }
        else {
            presentingView = toView
            presentedView = fromView
        }
        
        var animationBlock: (() -> ())
        var completion: ((Bool) -> ())
        
        if presenting {
            
            if presentingView != nil {
                containerView.insertSubview(presentingView!, atIndex:0)
            }
            
            containerView.addSubview(presentedView)
            
            var width: CGFloat = 0.0
            var height: CGFloat = 0.0
            
            if presentedViewSize.width == SimpleTransition.flexibleDimension {
                width = CGRectGetWidth(presentedView.bounds)
            }
            else {
                width = presentedViewSize.width
            }
            
            if presentedViewSize.height == SimpleTransition.flexibleDimension {
                height = CGRectGetHeight(presentedView.bounds)
            }
            else {
                height = presentedViewSize.height
            }
            
            presentedView.bounds = CGRectMake(0, 0, width, height)
            
            switch presentedViewAlignment {
            case .TopLeft:
                break
            case .TopCenter:
                presentedView.center = CGPoint(x: CGRectGetMidX(containerView.bounds),
                                               y: CGRectGetMidY(presentedView.bounds))
                break
            case .TopRight:
                presentedView.center = CGPoint(x: CGRectGetMidX(containerView.bounds),
                                               y: CGRectGetMidY(presentedView.bounds))
                break
            case .CenterLeft:
                presentedView.center = CGPoint(x: CGRectGetMidX(presentedView.bounds),
                                               y: CGRectGetMidY(containerView.bounds))
                break
            case .CenterCenter:
                presentedView.center = CGPoint(x: CGRectGetMidX(containerView.bounds),
                                               y: CGRectGetMidY(containerView.bounds))
                break
            case .CenterRight:
                presentedView.center = CGPoint(x: CGRectGetWidth(containerView.bounds) - CGRectGetWidth(presentedView.bounds)/2,
                                               y: CGRectGetMidY(containerView.bounds))
                break
            case .BottomLeft:
                presentedView.center = CGPoint(x: CGRectGetMidX(presentedView.bounds),
                                               y: CGRectGetHeight(containerView.bounds) - CGRectGetHeight(presentedView.bounds)/2)
                break
            case .BottomCenter:
                presentedView.center = CGPoint(x: CGRectGetMidX(containerView.bounds),
                                               y: CGRectGetHeight(containerView.bounds) - CGRectGetHeight(presentedView.bounds)/2)
                break
            case .BottomRight:
                presentedView.center = CGPoint(x: CGRectGetWidth(containerView.bounds) - CGRectGetWidth(presentedView.bounds)/2,
                                               y: CGRectGetHeight(containerView.bounds) - CGRectGetHeight(presentedView.bounds)/2)
                break
            }
            
            switch animation {
            case .LeftEdge:
                presentedView.transform = CGAffineTransformMakeTranslation(-CGRectGetMaxX(presentedView.bounds), 0)
                break
            case .RightEdge:
                presentedView.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(containerView.bounds) - CGRectGetMinX(presentedView.bounds), 0)
                break
            case .TopEdge:
                presentedView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(presentedView.bounds))
                break
            case .BottomEdge:
                presentedView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(containerView.bounds) - CGRectGetMinY(presentedView.bounds))
                break
            default:
                break
            }
            
            if fading {
                presentedView.alpha = 0.0
            }
            
            animationBlock = {
                
                presentedView.transform = CGAffineTransformIdentity
                if fading {
                    presentedView.alpha = 1.0
                }
                
                switch presentingViewSizeOption {
                case .Shrink:
                    if let presentingViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) {
                        presentingViewController.view.transform = CGAffineTransformMakeScale(0.95, 0.95)
                    }
                    break
                default:
                    break
                }
            }
        }
        else {
            
            if presentingView != nil {
                containerView.insertSubview(presentingView!, atIndex: 0)
            }
            
            var dismissTransform: CGAffineTransform = CGAffineTransformIdentity
            
            switch animation {
            case .LeftEdge:
                dismissTransform = CGAffineTransformMakeTranslation(-CGRectGetMaxX(presentedView.bounds), 0)
                break
            case .RightEdge:
                dismissTransform = CGAffineTransformMakeTranslation(CGRectGetWidth(containerView.bounds) - CGRectGetMinX(presentedView.bounds), 0)
                break
            case .TopEdge:
                dismissTransform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(presentedView.bounds))
                break
            case .BottomEdge:
                dismissTransform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(containerView.bounds) - CGRectGetMinY(presentedView.bounds))
                break
            default:
                break
            }
            
            animationBlock = {
                
                presentedView.transform = dismissTransform
                
                if fading {
                    presentedView.alpha = 0.0
                }
                
                switch presentingViewSizeOption {
                case .Shrink:
                    if let presentingViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) {
                        presentingViewController.view.transform = CGAffineTransformIdentity
                        presentingViewController.view.frame = containerView.frame
                    }
                    break
                default:
                    break
                }
            }
        }
        
        completion = { (finished: Bool) -> () in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
        
        if spring {
            UIView.animateWithDuration(
                duration * 1.5,
                delay: 0.0,
                usingSpringWithDamping: springDamping,
                initialSpringVelocity: initialSpringVelocity,
                options: [],
                animations: animationBlock,
                completion: completion)
        }
        else {
            UIView.animateWithDuration(
                duration,
                delay: 0.0,
                options: .CurveEaseInOut,
                animations: animationBlock,
                completion: completion)
        }
    }
    
}



