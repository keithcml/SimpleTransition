//
//  SwiftPresentationController.swift
//  Example
//
//  Created by Mingloan Chan on 28/12/2015.
//
//

import Foundation
import UIKit

class SimplePresentationController: UIPresentationController {
    
    // default value
    var keepPresentingViewOrientation = false
    var presentedViewAlignment: TransitionPresentedViewAlignment = .CenterCenter
    var dismissViaChromeView: Bool = false {
        willSet {
            if (newValue) {
                addTapOnChromeView();
            }
            else {
                removeTapOnChromeView();
            }
        }
    }
    var presentedViewSize: CGSize = CGSizeMake(SimpleTransitionDelegate.flexibleDimension, SimpleTransitionDelegate.flexibleDimension)
    
    let chromeView: UIView! = UIView()
    
    private var boundsOfPresentedViewInContainerView: CGRect! = CGRectMake(0, 0, 0, 0)
    
    lazy var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("tap:"))
    
    override init(presentedViewController: UIViewController, presentingViewController: UIViewController) {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
        chromeView.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
        chromeView.alpha = 0.0
        self.delegate = self
    }
    
    // MARK: Chrome View
    func addTapOnChromeView() {
        chromeView.addGestureRecognizer(tapGesture)
    }
    
    func removeTapOnChromeView() {
        chromeView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: Tap Chrome View
    func tap(sender: UITapGestureRecognizer!) {
        if sender.state == .Ended {
            self.presentedViewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: override func
    override func frameOfPresentedViewInContainerView() -> CGRect {
        
        var frame: CGRect! = boundsOfPresentedViewInContainerView
        
        switch presentedViewAlignment {
        case .TopLeft:
            break;
        case .TopCenter:
            frame.origin = CGPointMake(CGRectGetMidX(containerView!.bounds) - CGRectGetWidth(boundsOfPresentedViewInContainerView!)/2,
                CGRectGetMinY(boundsOfPresentedViewInContainerView!))
            break
        case .TopRight:
            frame.origin = CGPointMake(CGRectGetWidth(containerView!.bounds) - CGRectGetWidth(boundsOfPresentedViewInContainerView!),
                CGRectGetMinY(boundsOfPresentedViewInContainerView!))
            break
        case .CenterLeft:
            frame.origin = CGPointMake(CGRectGetMinX(boundsOfPresentedViewInContainerView!),
                CGRectGetMidY(containerView!.bounds) - CGRectGetHeight(boundsOfPresentedViewInContainerView!)/2)
            break
        case .CenterCenter:
            frame.origin = CGPointMake(CGRectGetMidX(containerView!.bounds) - CGRectGetWidth(boundsOfPresentedViewInContainerView!)/2,
                CGRectGetMidY(containerView!.bounds) - CGRectGetHeight(boundsOfPresentedViewInContainerView!)/2)
            break
        case .CenterRight:
            frame.origin = CGPointMake(CGRectGetWidth(containerView!.bounds) - CGRectGetWidth(boundsOfPresentedViewInContainerView!),
                CGRectGetMidY(containerView!.bounds) - CGRectGetHeight(boundsOfPresentedViewInContainerView!)/2)
            break
        case .BottomLeft:
            frame.origin = CGPointMake(CGRectGetMinX(boundsOfPresentedViewInContainerView!),
                CGRectGetHeight(containerView!.bounds) - CGRectGetHeight(boundsOfPresentedViewInContainerView!))
            break
        case .BottomCenter:
            frame.origin = CGPointMake(CGRectGetMidX(containerView!.bounds) - CGRectGetWidth(boundsOfPresentedViewInContainerView!)/2,
                CGRectGetHeight(containerView!.bounds) - CGRectGetHeight(boundsOfPresentedViewInContainerView!))
            break
        case .BottomRight:
            frame.origin = CGPointMake(CGRectGetWidth(containerView!.bounds) - CGRectGetWidth(boundsOfPresentedViewInContainerView!),
                CGRectGetHeight(containerView!.bounds) - CGRectGetHeight(boundsOfPresentedViewInContainerView!))
            break
        }
        
        return frame
    }
    
    override func containerViewWillLayoutSubviews() {
        chromeView.frame = containerView!.bounds;
        
        if (!CGSizeEqualToSize(CGSizeMake(SimpleTransitionDelegate.flexibleDimension, SimpleTransitionDelegate.flexibleDimension), self.presentedViewSize)) {
            
            let width: CGFloat = presentedViewSize.width == SimpleTransitionDelegate.flexibleDimension ? CGRectGetWidth(containerView!.bounds) : presentedViewSize.width
            let height: CGFloat = presentedViewSize.height == SimpleTransitionDelegate.flexibleDimension ? CGRectGetHeight(containerView!.bounds)
                : presentedViewSize.height
            
            boundsOfPresentedViewInContainerView! = CGRectMake(0, 0, width, height)
        }
        else {
            boundsOfPresentedViewInContainerView = containerView!.bounds
        }
        
        self.presentedView()!.frame = self.frameOfPresentedViewInContainerView()
    }
    
    override func presentationTransitionWillBegin() {
        
        chromeView.frame = containerView!.bounds;
        chromeView.alpha = 0.0;
        containerView!.insertSubview(chromeView, atIndex:0);
        
        let coordinator = presentedViewController.transitionCoordinator()
        
        if (coordinator != nil) {
            coordinator!.animateAlongsideTransition({ (context: UIViewControllerTransitionCoordinatorContext) -> Void in
                self.chromeView.alpha = 1.0
                }, completion: { (context: UIViewControllerTransitionCoordinatorContext) -> Void in
                    
            })
        }
    }
    
    override func presentationTransitionDidEnd(completed: Bool) {
        if !completed {
            chromeView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {

        let coordinator = presentedViewController.transitionCoordinator()
        
        if (coordinator != nil) {
            coordinator!.animateAlongsideTransition({ (context: UIViewControllerTransitionCoordinatorContext) -> Void in
                self.chromeView.alpha = 0.0
                }, completion: { (context: UIViewControllerTransitionCoordinatorContext) -> Void in
                    
            })
        }
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
