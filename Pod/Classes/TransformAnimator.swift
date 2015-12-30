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
    var presenting: Bool = true
    weak var transitionDelegate: SimpleTransitionDelegate?

}

extension TransformAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        assert(transitionDelegate != nil, "fatal error: no transition manager, please file as a bug")
        
        let spring: Bool = transitionDelegate!.animatedMotionOption == .Spring
        
        let fading: Bool = transitionDelegate!.fadingEnabled
        
        let presentingViewSizeOption: TransitionPresentingViewSizeOptions = transitionDelegate!.presentingViewSizeOption
        let presentedViewAlignment: TransitionPresentedViewAlignment = transitionDelegate!.presentedViewAlignment
        let animation: TransitionAnimation = transitionDelegate!.animation
        let initialSpringVelocity: CGFloat = transitionDelegate!.initialSpringVelocity
        let springDamping: CGFloat = transitionDelegate!.springDamping
        
        let presentedViewSize: CGSize = transitionDelegate!.presentedViewSize
        
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)
        let containerView: UIView! = transitionContext.containerView()
        
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
            
            if presentedViewSize.width == SimpleTransitionDelegate.flexibleDimension {
                width = CGRectGetWidth(presentedView.bounds)
            }
            else {
                width = presentedViewSize.width
            }
            
            if presentedViewSize.height == SimpleTransitionDelegate.flexibleDimension {
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
                presentedView.center = CGPointMake(CGRectGetMidX(containerView!.bounds),
                    CGRectGetMidY(presentedView.bounds))
                break
            case .TopRight:
                presentedView.center = CGPointMake(CGRectGetMidX(containerView!.bounds),
                    CGRectGetMidY(presentedView.bounds))
                break
            case .CenterLeft:
                presentedView.center = CGPointMake(CGRectGetMidX(presentedView.bounds),
                    CGRectGetMidY(containerView.bounds))
                break
            case .CenterCenter:
                presentedView.center = CGPointMake(CGRectGetMidX(containerView.bounds),
                    CGRectGetMidY(containerView.bounds))
                break
            case .CenterRight:
                presentedView.center = CGPointMake(CGRectGetWidth(containerView.bounds) - CGRectGetWidth(presentedView.bounds)/2,
                    CGRectGetMidY(containerView.bounds))
                break
            case .BottomLeft:
                presentedView.center = CGPointMake(CGRectGetMidX(presentedView.bounds),
                    CGRectGetHeight(containerView.bounds) - CGRectGetHeight(presentedView.bounds)/2)
                break
            case .BottomCenter:
                presentedView.center = CGPointMake(CGRectGetMidX(containerView.bounds),
                    CGRectGetHeight(containerView.bounds) - CGRectGetHeight(presentedView.bounds)/2)
                break
            case .BottomRight:
                presentedView.center = CGPointMake(CGRectGetWidth(containerView.bounds) - CGRectGetWidth(presentedView.bounds)/2,
                    CGRectGetHeight(containerView.bounds) - CGRectGetHeight(presentedView.bounds)/2)
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
                containerView!.insertSubview(presentingView!, atIndex: 0)
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



