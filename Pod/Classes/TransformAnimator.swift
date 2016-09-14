//  TransformAnimator.swift
//
//  Copyright (c) 2016, Mingloan, Keith Chan.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

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
        
        let presentingViewSizeOption = transitionDelegate.presentingViewSizeOption
        let presentedViewAlignment = transitionDelegate.presentedViewAlignment
        let animation = transitionDelegate.animation
        
        var presentedViewSize = SimpleTransition.FlexibleSize
        switch animation {
        case .LeftEdge(let size):
            presentedViewSize = size
            break
        case .RightEdge(let size):
            presentedViewSize = size
            break
        case .TopEdge(let size):
            presentedViewSize = size
            break
        case .BottomEdge(let size):
            presentedViewSize = size
            break
        default:
            break
        }
        
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)
        
        let containerView = transitionContext.containerView()
        
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
            
            if !CGSizeEqualToSize(presentedViewSize, SimpleTransition.FlexibleSize) {
                
                var width: CGFloat = 0.0
                var height: CGFloat = 0.0
                
                if presentedViewSize.width == SimpleTransition.FlexibleDimension {
                    width = CGRectGetWidth(presentedView.bounds)
                }
                else {
                    width = presentedViewSize.width
                }
                
                if presentedViewSize.height == SimpleTransition.FlexibleDimension {
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
            }
            
            switch animation {
            case .LeftEdge:
                presentedView.transform = CGAffineTransformMakeTranslation(-CGRectGetMaxX(presentedView.bounds), 0)
                break
            case .RightEdge:
                presentedView.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(containerView.bounds) - CGRectGetMinX(presentedView.frame), 0)
                break
            case .TopEdge:
                presentedView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(presentedView.bounds))
                break
            case .BottomEdge:
                presentedView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(containerView.bounds))
                break
            case .Dissolve:
                presentedView.alpha = 0.0
                break
            default:
                break
            }
            
            animationBlock = {
                
                presentedView.transform = CGAffineTransformIdentity
                switch animation {
                case .Dissolve:
                    presentedView.alpha = 1.0
                    break
                default:
                    break
                }
                
                switch presentingViewSizeOption {
                case .Scale(let scale):
                    if let presentingViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) {
                        presentingViewController.view.transform = CGAffineTransformMakeScale(scale, scale)
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
                
                switch animation {
                case .Dissolve:
                    presentedView.alpha = 0.0
                    break
                default:
                    break
                }
                
                switch presentingViewSizeOption {
                case .Scale:
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
        
        switch transitionDelegate.animatedMotionOption {
        case let .Spring(duration, velocity, damping):
            UIView.animateWithDuration(
                duration,
                delay: 0.0,
                usingSpringWithDamping: damping,
                initialSpringVelocity: velocity,
                options: [],
                animations: animationBlock,
                completion: completion)
            break
        case let .EaseInOut(duration):
            UIView.animateWithDuration(
                duration,
                delay: 0.0,
                options: .CurveEaseInOut,
                animations: animationBlock,
                completion: completion)
            break
        }
    }
    
}



