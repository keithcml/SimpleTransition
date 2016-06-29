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
    case Custom
    
    /// size of presented view controller
    case Dissolve(size: CGSize)
    case LeftEdge(size: CGSize)
    case RightEdge(size: CGSize)
    case TopEdge(size: CGSize)
    case BottomEdge(size: CGSize)
    
    func getSize() -> CGSize {
        switch self {
        case .Custom:
            return SimpleTransition.FlexibleSize
        case .Dissolve(let size):
            return size
        case .LeftEdge(let size):
            return size
        case .RightEdge(let size):
            return size
        case .TopEdge(let size):
            return size
        case .BottomEdge(let size):
            return size
        }
    }
}

/**
 Enum to control Presenting View Size after presentation.
 */
public enum TransitionPresentingViewSizeOptions {
    case Equal
    case Scale(scale: CGFloat)
}

/**
 Enum to control Presented View Size position relative to its presenting view controller
 */
public enum TransitionPresentedViewAlignment {
    case TopLeft
    case TopCenter
    case TopRight
    case CenterLeft
    case CenterCenter
    case CenterRight
    case BottomLeft
    case BottomCenter
    case BottomRight
}

/**
 Enum to control presentation animated motion
 */
public enum TransitionAnimatedMotionOptions {
    case EaseInOut(duration: NSTimeInterval)
    case Spring(duration: NSTimeInterval, velocity: CGFloat, damping: CGFloat)
}


public class SimpleTransition: NSObject {
    
    // MARK: - Public Properties
    /// represents flexible width or flexible height to the presenting view controller frame.
    public static let FlexibleDimension: CGFloat = 0.0
    public static let FlexibleSize = CGSize(width: SimpleTransition.FlexibleDimension, height: SimpleTransition.FlexibleDimension)
    
    /// dismiss presenting view controller when user taps on dimmer area
    public var dismissViaChromeView = true
    /// keep presenting view orientation, allow presented view to change orientation only
    public var keepPresentingViewOrientation = false
    /// keep presenting view
    public var keepPresentingViewWhenPresentFullScreen = false
    
    /// four parameters to control animations
    public private(set) var presentingViewSizeOption: TransitionPresentingViewSizeOptions = .Equal
    public private(set) var presentedViewAlignment: TransitionPresentedViewAlignment = .BottomCenter
    public private(set) var animatedMotionOption: TransitionAnimatedMotionOptions = .EaseInOut(duration: 0.4)
    public private(set) var animation: TransitionAnimation = .BottomEdge(size: CGSize(width: FlexibleDimension, height: FlexibleDimension))  {
        willSet {
            switch newValue as TransitionAnimation {
            case .LeftEdge:
                presentedViewAlignment = .CenterLeft
                break
            case .RightEdge:
                presentedViewAlignment = .CenterRight
                break
            case .TopEdge:
                presentedViewAlignment = .TopCenter
                break
            case .BottomEdge:
                presentedViewAlignment = .BottomCenter
                break
            case .Dissolve:
                presentedViewAlignment = .CenterCenter
                //fadingEnabled = true
                break
            default:
                presentedViewAlignment = .CenterCenter
                break
            }
        }
    }
    
    // MARK: - Private Properties
    
    /// weak reference of presenting view controller
    private(set) weak var stm_presentingViewController: UIViewController?
    /// weak reference of presented view controller
    private(set) weak var stm_presentedViewController: UIViewController?
    
    /// reference of transition animator object
    private(set) var animator: UIViewControllerAnimatedTransitioning?
    /// custom animators
    private(set) var customPresentedAnimator: UIViewControllerAnimatedTransitioning?
    private(set) var customDismissalAnimator: UIViewControllerAnimatedTransitioning?
    
    /**
     Designate Initializer.
     - Parameter presentingViewController:   The Presenting View Controller.
     - Parameter presentedViewController: The Presented View Controller.
     */
    public init(presentingViewController: UIViewController!, presentedViewController: UIViewController!) {
        
        assert(presentingViewController != nil, "no presentingViewController")
        assert(presentedViewController != nil, "no presentedViewController")
        
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
    public func setup(
        animation: TransitionAnimation = .BottomEdge(size: CGSize(width: FlexibleDimension, height: FlexibleDimension)),
        alignment: TransitionPresentedViewAlignment = .BottomCenter,
        motion: TransitionAnimatedMotionOptions = .EaseInOut(duration: 0.4),
        presentingViewSize: TransitionPresentingViewSizeOptions = .Equal) {
        
        self.animation = animation
        self.presentedViewAlignment = alignment
        self.animatedMotionOption = motion
        self.presentingViewSizeOption = presentingViewSize
    }
    
    /**
     Custom Animator Parameters Setup.
     - Parameter customPresentedAnimator: The object for presenting animation which must conform to UIViewControllerAnimatedTransitioning.
     - Parameter customDismissalAnimator: The object for dismissal animation which must conform to UIViewControllerAnimatedTransitioning.
     */
    public func setCustomAnimators(
        customPresentedAnimator: UIViewControllerAnimatedTransitioning?,
        customDismissalAnimator: UIViewControllerAnimatedTransitioning?) {
        
        self.animation = .Custom
        self.customPresentedAnimator = customPresentedAnimator
        self.customDismissalAnimator = customDismissalAnimator
        
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension SimpleTransition: UIViewControllerTransitioningDelegate {
    
    public func animationControllerForPresentedController(presented: UIViewController,
                                                          presentingController presenting: UIViewController,
                                                                               sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch animation {
        case .Custom:
            if let customPresentedAnimator = customPresentedAnimator {
                return customPresentedAnimator
            }
            return nil
        case .Dissolve, .LeftEdge, .RightEdge, .TopEdge, .BottomEdge:
            let t_animator = TransformAnimator()
            t_animator.presenting = true
            t_animator.transitionDelegate = self
            animator = t_animator
            return t_animator
        }
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch animation {
        case .Custom:
            if let customDismissalAnimator = customDismissalAnimator {
                return customDismissalAnimator
            }
            return nil
        case .Dissolve, .LeftEdge, .RightEdge, .TopEdge, .BottomEdge:
            guard let t_animator = animator else { return nil }
            guard let unwrappedAnimator = t_animator as? TransformAnimator else { return nil }
            
            unwrappedAnimator.presenting = false
            return unwrappedAnimator
        }
    }
    
    public func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        let presentationController = SimplePresentationController(presentedViewController: presented, presentingViewController:presenting)
        presentationController.presentedViewAlignment = presentedViewAlignment
        presentationController.dismissViaChromeView = dismissViaChromeView
        presentationController.presentedViewSize = animation.getSize()
        presentationController.keepPresentingViewOrientation = keepPresentingViewOrientation
        presentationController.keepPresentingViewWhenPresentFullScreen = keepPresentingViewWhenPresentFullScreen
        return presentationController
    }
}

public extension UIViewController {
    private struct AssociatedKeys {
        static var simpleTransitionDelegate: SimpleTransition?
    }
    
    var simpleTransitionDelegate: SimpleTransition? {
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
    
    public override class func initialize() {
        struct Static {
            static var token_present: dispatch_once_t = 0
            static var token_dismiss: dispatch_once_t = 0
        }
        
        // make sure this isn't a subclass
        if self !== UIViewController.self {
            return
        }
        
        dispatch_once(&Static.token_present) {
            let originalSelector = #selector(UIViewController.presentViewController(_:animated:completion:))
            let swizzledSelector = #selector(UIViewController.stm_presentViewController(_:animated:completion:))
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        }
        
        dispatch_once(&Static.token_dismiss) {
            let originalSelector = #selector(UIViewController.dismissViewControllerAnimated(_:completion:))
            let swizzledSelector = #selector(UIViewController.stm_dismissViewControllerAnimated(_:completion:))
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            }
            else {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        }
    }
    
    // MARK: - Method Swizzling
    func stm_presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        
        if viewControllerToPresent.isKindOfClass(UIAlertController) {
            self.stm_presentViewController(viewControllerToPresent, animated: flag, completion: completion)
            return
        }
        
        if let transitionDelegate = viewControllerToPresent.simpleTransitionDelegate {
            
            if CGSizeEqualToSize(CGSizeZero, transitionDelegate.animation.getSize()) {
                viewControllerToPresent.modalPresentationStyle = transitionDelegate.keepPresentingViewWhenPresentFullScreen ? .OverFullScreen : .FullScreen
            }
            else {
                viewControllerToPresent.modalPresentationStyle = .Custom
            }
            viewControllerToPresent.modalPresentationCapturesStatusBarAppearance = true
            viewControllerToPresent.transitioningDelegate = viewControllerToPresent.simpleTransitionDelegate
            
            // things to do ...
            // ...
            // ...
            
            self.stm_presentViewController(viewControllerToPresent, animated: flag, completion: completion)
        }
        else {
            self.stm_presentViewController(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
    
    func stm_dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
        
        if self.presentedViewController != nil && self.presentedViewController!.isKindOfClass(UIAlertController) {
            self.stm_dismissViewControllerAnimated(flag, completion: completion)
            return
        }
        
        if self.simpleTransitionDelegate != nil && self.simpleTransitionDelegate!.isKindOfClass(SimpleTransition) {
            // things to do ...
            self.stm_dismissViewControllerAnimated(flag, completion: completion)
        }
        else {
            self.stm_dismissViewControllerAnimated(flag, completion: completion)
        }
    }
}



