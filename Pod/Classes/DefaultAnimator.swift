//  DefaultAnimator.swift
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

final class DefaultAnimator: NSObject {
    
    var duration: TimeInterval = 0.4
    var presenting = true
    weak var transitionDelegate: SimpleTransition?
    
    fileprivate var snapshotView: UIView?
    fileprivate weak var destView: UIView?

}

extension DefaultAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let transitionDelegate = transitionDelegate else {
            assert(1 != 1, "fatal error: no transition manager, please file as a bug")
            return
        }
        
        let presentingViewSizeOption = transitionDelegate.presentingViewSizeOption
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
        
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        
        let containerView = transitionContext.containerView
        let containerViewFrame = containerView.frame
        
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
            
            var startFrame = CGRect.zero
            var finalFrame = CGRect.zero
            if let toViewController = transitionContext.viewController(forKey: .to) {
                // fix for rotation bug in iOS 9
                startFrame = transitionContext.initialFrame(for: toViewController)
                finalFrame = transitionContext.finalFrame(for: toViewController)
            }
            
            var width: CGFloat = 0.0
            var height: CGFloat = 0.0
            
            if presentedViewSize.width == SimpleTransition.FlexibleDimension {
                width = containerViewFrame.width
            }
            else {
                width = presentedViewSize.width
            }
            
            if presentedViewSize.height == SimpleTransition.FlexibleDimension {
                height = containerViewFrame.height
            }
            else {
                height = presentedViewSize.height
            }
            
            startFrame.size = CGSize(width: width, height: height)

            var origin = CGPoint(x: 0, y: 0)
            switch animation {
            case .leftEdge:
                origin = CGPoint(x: -containerView.bounds.width, y: finalFrame.minY)
                break
            case .rightEdge:
                origin = CGPoint(x: containerView.bounds.width, y: finalFrame.minY)
                break
            case .topEdge:
                origin = CGPoint(x: finalFrame.minX, y: -containerView.bounds.maxY)
                break
            case .bottomEdge:
                origin = CGPoint(x: finalFrame.minX, y: containerView.bounds.height)
                break
            case .dissolve:
                origin = finalFrame.origin
                presentedView.alpha = 0.0
                break
            default:
                break
            }
            startFrame.origin = origin
            
            // configure zoom effect
            if let zoomEffectInfo = transitionDelegate.zoomEffectInfo {
                
                zoomEffectInfo.zoomingView.isHidden = true
                snapshotView = zoomEffectInfo.zoomingView.snapshotView(afterScreenUpdates: false)
                if let sourceRect = zoomEffectInfo.explicitSourceRect {
                    snapshotView?.frame = sourceRect
                }
                else {
                    snapshotView?.frame = containerView.convert(zoomEffectInfo.zoomingView.frame, from: presentingView)
                }
                destView = zoomEffectInfo.destinationView()
                destView?.isHidden = true
            }

            // add subviews
            containerView.addSubview(presentedView)
            presentedView.frame = startFrame
            presentedView.layoutIfNeeded()
            
            if let _snapshotView = snapshotView {
                containerView.addSubview(_snapshotView)
            }
            
            //print("startFrame : \(startFrame)")
            //print("finalFrame : \(finalFrame)")
            
            animationBlock = {
                
                presentedView.frame = finalFrame
                
                if case .dissolve = animation {
                    presentedView.alpha = 1.0
                }
                
                if case .scale(let scale) = presentingViewSizeOption, let presentingViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) {
                    presentingViewController.view.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
                
                if let _snapshotView = self.snapshotView {
                    _snapshotView.isHidden = false
                    if let _destView = self.destView {
                        _snapshotView.frame = containerView.convert(_destView.frame, from: presentedView)
                    }
                }
            }
            
            completion = { (finished) -> () in
                if let _snapshotView = self.snapshotView {
                    
                    _snapshotView.isHidden = true
                    _snapshotView.removeFromSuperview()
                }
                self.destView?.isHidden = false
                if let zoomEffectInfo = transitionDelegate.zoomEffectInfo,
                    let removeZoomingViewAfterPresentation = transitionDelegate.zoomEffectInfo?.removeZoomingViewAfterPresentation {
                    zoomEffectInfo.zoomingView.isHidden = removeZoomingViewAfterPresentation
                }
                
                let success = !transitionContext.transitionWasCancelled
                if !success {
                    presentedView.removeFromSuperview()
                }
                
                transitionContext.completeTransition(success)
            }
        }
        else {
            // no presenting view if shouldRemovePresentersView in SimplePresentationController return false
            if presentingView != nil {
                containerView.insertSubview(presentingView!, at: 0)
            }
            
            var dismissTransform: CGAffineTransform = CGAffineTransform.identity
            
            let _dismissalAnimation = transitionDelegate.dismissalAnimation ?? animation
            switch _dismissalAnimation {
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
            
            // snapshotView
            if let _snapshotView = self.snapshotView, let _destView = self.destView {
                containerView.addSubview(_snapshotView)
                _snapshotView.isHidden = false
                _snapshotView.frame = containerView.convert(_destView.frame, from: presentedView)
                destView?.isHidden = true
            }
            
            transitionDelegate.zoomEffectInfo?.zoomingView.isHidden = true

            animationBlock = {
                
                presentedView.transform = dismissTransform
                
                if case .dissolve = _dismissalAnimation {
                    presentedView.alpha = 0.0
                }
                
                if case .scale = presentingViewSizeOption, let presentingViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) {
                    presentingViewController.view.transform = CGAffineTransform.identity
                    presentingViewController.view.frame = containerView.frame
                }
                
                if let _snapshotView = self.snapshotView,
                    let zoomingView = transitionDelegate.zoomEffectInfo?.zoomingView,
                    let presentingViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) {
                    _snapshotView.frame = presentingViewController.view.convert(zoomingView.frame, to: containerView)
                    
                }
            }
            
            completion = { (finished: Bool) -> () in
                
                self.snapshotView?.isHidden = true
                
                transitionDelegate.zoomEffectInfo?.zoomingView.isHidden = false
                
                let success = !transitionContext.transitionWasCancelled
                if success {
                    presentedView.removeFromSuperview()
                }
                
                transitionContext.completeTransition(success)
            }
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
