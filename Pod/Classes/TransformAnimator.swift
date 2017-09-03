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

final class TransformAnimator: NSObject {
    
    var duration: TimeInterval = 0.4
    var presenting = true
    weak var transitionDelegate: SimpleTransition?
    
}

extension TransformAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let transitionDelegate = transitionDelegate else {
            assert(1 != 1, "fatal error: no transition manager, please file as a bug")
            return
        }
        
        let presentingViewSizeOption = transitionDelegate.presentingViewSizeOption
        let presentedViewAlignment = transitionDelegate.presentedViewAlignment
        let animation = transitionDelegate.animation
        
        var presentedViewSize = SimpleTransition.FlexibleSize
        switch animation {
        case .leftEdge(let size):
            presentedViewSize = size
            break
        case .rightEdge(let size):
            presentedViewSize = size
            break
        case .topEdge(let size):
            presentedViewSize = size
            break
        case .bottomEdge(let size):
            presentedViewSize = size
            break
        case .dissolve(let size):
            presentedViewSize = size
            break
        default:
            break
        }
        
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)
        
        let containerView = transitionContext.containerView
        
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
                containerView.insertSubview(presentingView!, at:0)
            }
            
            containerView.addSubview(presentedView)
            
            // configure view dimemsions
            if !presentedViewSize.equalTo(SimpleTransition.FlexibleSize) {
                
                var width: CGFloat = 0.0
                var height: CGFloat = 0.0
                
                if presentedViewSize.width == SimpleTransition.FlexibleDimension {
                    width = presentedView.bounds.width
                }
                else {
                    width = presentedViewSize.width
                }
                
                if presentedViewSize.height == SimpleTransition.FlexibleDimension {
                    height = presentedView.bounds.height
                }
                else {
                    height = presentedViewSize.height
                }
                
                presentedView.bounds = CGRect(x: 0, y: 0, width: width, height: height)
                
                switch presentedViewAlignment {
                case .topLeft:
                    break
                case .topCenter:
                    presentedView.center = CGPoint(x: containerView.bounds.midX,
                                                   y: presentedView.bounds.midY)
                    break
                case .topRight:
                    presentedView.center = CGPoint(x: containerView.bounds.midX,
                                                   y: presentedView.bounds.midY)
                    break
                case .centerLeft:
                    presentedView.center = CGPoint(x: presentedView.bounds.midX,
                                                   y: containerView.bounds.midY)
                    break
                case .centerCenter:
                    presentedView.center = CGPoint(x: containerView.bounds.midX,
                                                   y: containerView.bounds.midY)
                    break
                case .centerRight:
                    presentedView.center = CGPoint(x: containerView.bounds.width - presentedView.bounds.width/2,
                                                   y: containerView.bounds.midY)
                    break
                case .bottomLeft:
                    presentedView.center = CGPoint(x: presentedView.bounds.midX,
                                                   y: containerView.bounds.height - presentedView.bounds.height/2)
                    break
                case .bottomCenter:
                    presentedView.center = CGPoint(x: containerView.bounds.midX,
                                                   y: containerView.bounds.height - presentedView.bounds.height/2)
                    break
                case .bottomRight:
                    presentedView.center = CGPoint(x: containerView.bounds.width - presentedView.bounds.width/2,
                                                   y: containerView.bounds.height - presentedView.bounds.height/2)
                    break
                    
                }
            }
            
            //configure view opacity
            switch animation {
            case .leftEdge:
                presentedView.transform = CGAffineTransform(translationX: -containerView.bounds.width, y: 0)
                break
            case .rightEdge:
                presentedView.transform = CGAffineTransform(translationX: containerView.bounds.width, y: 0)
                break
            case .topEdge:
                presentedView.transform = CGAffineTransform(translationX: 0, y: -containerView.bounds.maxY)
                break
            case .bottomEdge:
                presentedView.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)
                break
            case .dissolve:
                presentedView.alpha = 0.0
                break
            default:
                break
            }
            
            animationBlock = {
                
                presentedView.transform = CGAffineTransform.identity
                switch animation {
                case .dissolve:
                    presentedView.alpha = 1.0
                    break
                default:
                    break
                }
                
                switch presentingViewSizeOption {
                case .scale(let scale):
                    if let presentingViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) {
                        presentingViewController.view.transform = CGAffineTransform(scaleX: scale, y: scale)
                    }
                    break
                default:
                    break
                }
            }
        }
        else {
            
            if presentingView != nil {
                containerView.insertSubview(presentingView!, at: 0)
            }
            
            var dismissTransform: CGAffineTransform = CGAffineTransform.identity
            
            // configure view dimemsions
            switch animation {
            case .leftEdge:
                dismissTransform = CGAffineTransform(translationX: -containerView.bounds.width, y: 0)
                break
            case .rightEdge:
                dismissTransform = CGAffineTransform(translationX: containerView.bounds.width, y: 0)
                break
            case .topEdge:
                dismissTransform = CGAffineTransform(translationX: 0, y: -containerView.bounds.maxY)
                break
            case .bottomEdge:
                dismissTransform = CGAffineTransform(translationX: 0, y: containerView.bounds.height - presentedView.bounds.minY)
                break
            default:
                break
            }
            
            animationBlock = {
                
                presentedView.transform = dismissTransform
                
                switch animation {
                case .dissolve:
                    presentedView.alpha = 0.0
                    break
                default:
                    break
                }
                
                switch presentingViewSizeOption {
                case .scale:
                    if let presentingViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) {
                        presentingViewController.view.transform = CGAffineTransform.identity
                        presentingViewController.view.frame = containerView.frame
                    }
                    break
                default:
                    break
                }
            }
        }
        
        completion = { (finished: Bool) -> () in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        switch transitionDelegate.animatedMotionOption {
        case let .spring(duration, velocity, damping):
            UIView.animate(
                withDuration: duration,
                delay: 0.0,
                usingSpringWithDamping: damping,
                initialSpringVelocity: velocity,
                options: [],
                animations: animationBlock,
                completion: completion)
            break
        case let .easeInOut(duration):
            UIView.animate(
                withDuration: duration,
                delay: 0.0,
                options: .curveEaseInOut,
                animations: animationBlock,
                completion: completion)
            break
        }
    }
    
}



