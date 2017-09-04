//  SimpleTransition.swift
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

/**
 Enum to control Animation Types.
 */
public enum TransitionAnimation {
    case custom
    
    /// size of presented view controller
    case dissolve(size: CGSize)
    case leftEdge(size: CGSize)
    case rightEdge(size: CGSize)
    case topEdge(size: CGSize)
    case bottomEdge(size: CGSize)
    
    func getSize() -> CGSize {
        switch self {
        case .custom:
            return SimpleTransition.FlexibleSize
        case .dissolve(let size):
            return size
        case .leftEdge(let size):
            return size
        case .rightEdge(let size):
            return size
        case .topEdge(let size):
            return size
        case .bottomEdge(let size):
            return size
        }
    }
}

/**
 Enum to control Presenting View Size after presentation.
 */
public enum TransitionPresentingViewSizeOptions {
    case equal
    case scale(scale: CGFloat)
}

/**
 Enum to control Presented View Size position relative to its presenting view controller
 */
public enum TransitionPresentedViewAlignment {
    case topLeft
    case topCenter
    case topRight
    case centerLeft
    case centerCenter
    case centerRight
    case bottomLeft
    case bottomCenter
    case bottomRight
}

/**
 Enum to control presentation animated motion
 */
public enum TransitionAnimatedMotionOptions {
    case easeInOut(duration: TimeInterval)
    case spring(duration: TimeInterval, velocity: CGFloat, damping: CGFloat)
}

public final class SimpleTransition: NSObject {
    
    // MARK: - Public Properties
    /// represents flexible width or flexible height to the presenting view controller frame.
    open static let FlexibleDimension: CGFloat = 0.0
    open static let FlexibleSize = CGSize(width: SimpleTransition.FlexibleDimension, height: SimpleTransition.FlexibleDimension)
    
    /// dismiss presenting view controller when user taps on dimmer area
    open var dismissViaChromeView = true
    /// keep presenting view orientation, allow presented view to change orientation only
    open var keepPresentingViewOrientation = false
    /// keep presenting view
    open var keepPresentingViewWhenPresentFullScreen = false
    /// Chrome View background Color
    open var chromeViewBackgroundColor = UIColor(white: 0.0, alpha: 0.3)
    
    /// five parameters to control animations
    open fileprivate(set) var presentingViewSizeOption: TransitionPresentingViewSizeOptions = .equal
    open fileprivate(set) var presentedViewAlignment: TransitionPresentedViewAlignment = .bottomCenter
    open fileprivate(set) var animatedMotionOption: TransitionAnimatedMotionOptions = .easeInOut(duration: 0.4)
    open fileprivate(set) var presentingAnimation: TransitionAnimation = .bottomEdge(size: CGSize(width: FlexibleDimension, height: FlexibleDimension))  {
        willSet {
            switch newValue as TransitionAnimation {
            case .leftEdge:
                presentedViewAlignment = .centerLeft
                break
            case .rightEdge:
                presentedViewAlignment = .centerRight
                break
            case .topEdge:
                presentedViewAlignment = .topCenter
                break
            case .bottomEdge:
                presentedViewAlignment = .bottomCenter
                break
            case .dissolve:
                presentedViewAlignment = .centerCenter
                break
            default:
                presentedViewAlignment = .centerCenter
                break
            }
        }
    }
    open fileprivate(set) var dismissalAnimation: TransitionAnimation?
    open fileprivate(set) var zoomConfig: ZoomConfig?
    
    // MARK: - Private Properties
    
    /// weak reference of presenting view controller
    fileprivate(set) weak var stm_presentingViewController: UIViewController?
    /// weak reference of presented view controller
    fileprivate(set) weak var stm_presentedViewController: UIViewController?
    
    /// reference of transition animator object
    fileprivate(set) var animator: UIViewControllerAnimatedTransitioning?
    /// custom animators
    fileprivate(set) var customPresentedAnimator: UIViewControllerAnimatedTransitioning?
    fileprivate(set) var customDismissalAnimator: UIViewControllerAnimatedTransitioning?
    
    private static var didFinishInitialSetup: Bool?
    
    /**
     Designate Initializer.
     - Parameter presentingViewController:   The Presenting View Controller.
     - Parameter presentedViewController: The Presented View Controller.
     */
    public init(presentingViewController: UIViewController!, presentedViewController: UIViewController!) {
        
        assert(presentingViewController != nil, "no presentingViewController")
        assert(presentedViewController != nil, "no presentedViewController")
        
        if let _ = SimpleTransition.didFinishInitialSetup {} else {
            SimpleTransition.didFinishInitialSetup = true
            SimpleTransition.initialSetup()
        }
        
        stm_presentingViewController = presentingViewController
        stm_presentedViewController = presentedViewController
    }
    
    /**
     Built-in Animator Parameters Setup.
     - Parameter animation:   The animation type.
     - Parameter alignment: The Presented View alignment.
     - Parameter motion: The animate motion of presentation.
     - Parameter presentingViewSize: The Presenting View Controller Size after presentation.
     */
    open func setupTransition(presentingAnimation: TransitionAnimation = .bottomEdge(size: CGSize(width: FlexibleDimension, height: FlexibleDimension)),
                              dismissalAnimation: TransitionAnimation? = nil,
                              alignment: TransitionPresentedViewAlignment = .bottomCenter,
                              motion: TransitionAnimatedMotionOptions = .easeInOut(duration: 0.4),
                              presentingViewSize: TransitionPresentingViewSizeOptions = .equal,
                              zoomConfig: ZoomConfig? = nil) {
        
        self.presentingAnimation = presentingAnimation
        self.dismissalAnimation = dismissalAnimation
        self.presentedViewAlignment = alignment
        self.animatedMotionOption = motion
        self.presentingViewSizeOption = presentingViewSize
        self.zoomConfig = zoomConfig
    }
    
    /**
     Custom Animator Parameters Setup.
     - Parameter customPresentedAnimator: The object for presenting animation which must conform to UIViewControllerAnimatedTransitioning.
     - Parameter customDismissalAnimator: The object for dismissal animation which must conform to UIViewControllerAnimatedTransitioning.
     */
    open func setCustomAnimators(
        _ customPresentedAnimator: UIViewControllerAnimatedTransitioning?,
        customDismissalAnimator: UIViewControllerAnimatedTransitioning?) {
        
        self.presentingAnimation = .custom
        self.customPresentedAnimator = customPresentedAnimator
        self.customDismissalAnimator = customDismissalAnimator
        
    }
}

extension SimpleTransition {
    
    // You must call this in app delegate
    public static func initialSetup() {
        // make sure this isn't a subclass
        // if self != UIViewController.self { return }
        
        let presentSwizzlingClosure: () = {
            let originalSelector = #selector(UIViewController.present(_:animated:completion:))
            let swizzledSelector = #selector(UIViewController.stm_present(_:animated:completion:))
            
            let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector)
            
            let didAddMethod = class_addMethod(UIViewController.self,
                                               originalSelector,
                                               method_getImplementation(swizzledMethod),
                                               method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod {
                class_replaceMethod(UIViewController.self,
                                    swizzledSelector,
                                    method_getImplementation(originalMethod),
                                    method_getTypeEncoding(originalMethod))
            }
            else {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        }()
        presentSwizzlingClosure
        
        let dismissSwizzlingClosure: () = {
            let originalSelector = #selector(UIViewController.dismiss(animated:completion:))
            let swizzledSelector = #selector(UIViewController.stm_dismiss(animated:completion:))
            
            let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector)
            
            let didAddMethod = class_addMethod(UIViewController.self,
                                               originalSelector,
                                               method_getImplementation(swizzledMethod),
                                               method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod {
                class_replaceMethod(UIViewController.self,
                                    swizzledSelector,
                                    method_getImplementation(originalMethod),
                                    method_getTypeEncoding(originalMethod))
            }
            else {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        }()
        dismissSwizzlingClosure
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension SimpleTransition: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController,
                                    presenting: UIViewController,
                                    source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch presentingAnimation {
        case .custom:
            if let customPresentedAnimator = customPresentedAnimator {
                return customPresentedAnimator
            }
            return nil
        case .dissolve, .leftEdge, .rightEdge, .topEdge, .bottomEdge:
            let defaultAnimator = DefaultAnimator()
            defaultAnimator.presenting = true
            defaultAnimator.transitionDelegate = self
            animator = defaultAnimator
            return defaultAnimator
        }
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch presentingAnimation {
        case .custom:
            if let customDismissalAnimator = customDismissalAnimator {
                return customDismissalAnimator
            }
            return nil
        case .dissolve, .leftEdge, .rightEdge, .topEdge, .bottomEdge:
            guard let defaultAnimator = animator as? DefaultAnimator else { return nil }
            defaultAnimator.presenting = false
            return defaultAnimator
        }
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = SimplePresentationController(presentedViewController: presented, presenting:presenting)
        presentationController.presentedViewAlignment = presentedViewAlignment
        presentationController.dismissViaChromeView = dismissViaChromeView
        presentationController.presentedViewSize = presentingAnimation.getSize()
        presentationController.keepPresentingViewOrientation = keepPresentingViewOrientation
        presentationController.keepPresentingViewWhenPresentFullScreen = keepPresentingViewWhenPresentFullScreen
        presentationController.chromeViewBackgroundColor = chromeViewBackgroundColor
        return presentationController
    }
}

extension UIViewController {
    fileprivate struct AssociatedKeys {
        static var simpleTransitionDelegate: SimpleTransition?
    }
    
    public var simpleTransitionDelegate: SimpleTransition? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.simpleTransitionDelegate) as? SimpleTransition
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.simpleTransitionDelegate,
                    newValue as SimpleTransition?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    // MARK: - Method Swizzling
    @objc fileprivate func stm_present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> ())? = nil) {

        if let vc = viewControllerToPresent as? UIAlertController {
            self.stm_present(vc, animated: flag, completion: completion)
            return
        }
        
        if let transitionDelegate = viewControllerToPresent.simpleTransitionDelegate {
            
            if CGSize.zero.equalTo(transitionDelegate.presentingAnimation.getSize()) {
                viewControllerToPresent.modalPresentationStyle = transitionDelegate.keepPresentingViewWhenPresentFullScreen ? .overFullScreen : .fullScreen
            }
            else {
                viewControllerToPresent.modalPresentationStyle = .custom
            }
            viewControllerToPresent.modalPresentationCapturesStatusBarAppearance = true
            viewControllerToPresent.transitioningDelegate = viewControllerToPresent.simpleTransitionDelegate
            
            // things to do ...
            // ...
            // ...
            
            self.stm_present(viewControllerToPresent, animated: flag, completion: completion)
        }
        else {
            self.stm_present(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
    
    @objc fileprivate func stm_dismiss(animated flag: Bool, completion: (() -> ())? = nil) {
        
        if (presentedViewController as? UIAlertController) != nil {
            self.stm_dismiss(animated: flag, completion: completion)
            return
        }
        
        if simpleTransitionDelegate != nil {
            // things to do ...
            self.stm_dismiss(animated: flag, completion: completion)
        }
        else {
            self.stm_dismiss(animated: flag, completion: completion)
        }
    }
}



