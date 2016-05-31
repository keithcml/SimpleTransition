//  SimplePresentationController.swift
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

class SimplePresentationController: UIPresentationController {
    
    // default value
    var keepPresentingViewOrientation = false
    var presentedViewAlignment: TransitionPresentedViewAlignment = .CenterCenter
    var dismissViaChromeView = false {
        willSet {
            if (newValue) {
                addTapOnChromeView();
            }
            else {
                removeTapOnChromeView();
            }
        }
    }
    var presentedViewSize = SimpleTransition.FlexibleSize
    
    let chromeView = UIView()
    
    private var boundsOfPresentedViewInContainerView = CGRectZero
    
    lazy var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SimplePresentationController.tap(_:)))
    
    override init(presentedViewController: UIViewController, presentingViewController: UIViewController) {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
        chromeView.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
        chromeView.alpha = 0.0
        delegate = self
    }
    
    // MARK: Chrome View
    func addTapOnChromeView() {
        chromeView.addGestureRecognizer(tapGesture)
    }
    
    func removeTapOnChromeView() {
        chromeView.removeGestureRecognizer(tapGesture)
    }
    
    // MARK: Tap Chrome View
    func tap(sender: UITapGestureRecognizer!) {
        if sender.state == .Ended {
            presentedViewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: override func
    override func frameOfPresentedViewInContainerView() -> CGRect {
        
        var frame = boundsOfPresentedViewInContainerView
        
        guard let containerView = containerView else { return frame }
        
        switch presentedViewAlignment {
        case .TopLeft:
            break;
        case .TopCenter:
            frame.origin = CGPoint(x: CGRectGetMidX(containerView.bounds) - CGRectGetWidth(frame)/2, y: CGRectGetMinY(frame))
            break
        case .TopRight:
            frame.origin = CGPoint(x: CGRectGetWidth(containerView.bounds) - CGRectGetWidth(frame), y: CGRectGetMinY(frame))
            break
        case .CenterLeft:
            frame.origin = CGPoint(x: CGRectGetMinX(frame), y: CGRectGetMidY(containerView.bounds) - CGRectGetHeight(frame)/2)
            break
        case .CenterCenter:
            frame.origin = CGPoint(x: CGRectGetMidX(containerView.bounds) - CGRectGetWidth(frame)/2,
                y: CGRectGetMidY(containerView.bounds) - CGRectGetHeight(frame)/2)
            break
        case .CenterRight:
            frame.origin = CGPoint(x: CGRectGetWidth(containerView.bounds) - CGRectGetWidth(frame),
                y: CGRectGetMidY(containerView.bounds) - CGRectGetHeight(frame)/2)
            break
        case .BottomLeft:
            frame.origin = CGPoint(x: CGRectGetMinX(frame),
                y: CGRectGetHeight(containerView.bounds) - CGRectGetHeight(frame))
            break
        case .BottomCenter:
            frame.origin = CGPoint(x: CGRectGetMidX(containerView.bounds) - CGRectGetWidth(frame)/2,
                y: CGRectGetHeight(containerView.bounds) - CGRectGetHeight(frame))
            break
        case .BottomRight:
            frame.origin = CGPoint(x: CGRectGetWidth(containerView.bounds) - CGRectGetWidth(frame),
                y: CGRectGetHeight(containerView.bounds) - CGRectGetHeight(frame))
            break
        }
        
        return frame
    }
    
    override func containerViewWillLayoutSubviews() {
        
        guard let containerView = containerView else { return }
        
        guard let presentedView = presentedView() else { return }
        
        chromeView.frame = containerView.bounds;
        
        if (!CGSizeEqualToSize(SimpleTransition.FlexibleSize, presentedViewSize)) {
            
            let width = presentedViewSize.width == SimpleTransition.FlexibleDimension ? CGRectGetWidth(containerView.bounds) : presentedViewSize.width
            let height = presentedViewSize.height == SimpleTransition.FlexibleDimension ? CGRectGetHeight(containerView.bounds)
                : presentedViewSize.height
            
            boundsOfPresentedViewInContainerView = CGRect(x: 0, y: 0, width: width, height: height)
        }
        else {
            boundsOfPresentedViewInContainerView = containerView.bounds
        }
        
        presentedView.frame = frameOfPresentedViewInContainerView()
    }
    
    override func presentationTransitionWillBegin() {
        
        guard let containerView = containerView else { return }
        guard let coordinator = presentedViewController.transitionCoordinator() else { return }
        
        chromeView.frame = containerView.bounds
        chromeView.alpha = 0.0
        containerView.insertSubview(chromeView, atIndex:0)
        
        coordinator.animateAlongsideTransition({ (context: UIViewControllerTransitionCoordinatorContext) -> Void in
            self.chromeView.alpha = 1.0
            }, completion: { (context: UIViewControllerTransitionCoordinatorContext) -> Void in
                
        })
    }
    
    override func presentationTransitionDidEnd(completed: Bool) {
        if !completed {
            chromeView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {

        guard let coordinator = presentedViewController.transitionCoordinator() else { return }
        coordinator.animateAlongsideTransition({ (context: UIViewControllerTransitionCoordinatorContext) -> Void in
            self.chromeView.alpha = 0.0
            }, completion: { (context: UIViewControllerTransitionCoordinatorContext) -> Void in
                
        })
    }
    
    override func dismissalTransitionDidEnd(completed: Bool) {
        if !completed {
            UIView.animateWithDuration(
                0.2,
                animations: {
                    self.chromeView.alpha = 1.0;
                })
        }
        else {
            chromeView.removeFromSuperview()
        }
    }
    
    override func shouldPresentInFullscreen() -> Bool {
        return false
    }
    
    override func shouldRemovePresentersView() -> Bool {
        if keepPresentingViewOrientation {
            return true
        }
        return false
    }
    
    
    override func adaptivePresentationStyle() -> UIModalPresentationStyle {
        return .FullScreen
    }
    
    override func adaptivePresentationStyleForTraitCollection(traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .FullScreen
    }
    
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension SimplePresentationController: UIAdaptivePresentationControllerDelegate {
    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        // further development...
        return nil
    }
    
}
