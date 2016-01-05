//
//  TransitionManager.swift
//  Example
//
//  Created by Mingloan Chan on 28/12/2015.
//
//

import Foundation
import UIKit

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
            let originalSelector = Selector("presentViewController:animated:completion:")
            let swizzledSelector = Selector("stm_presentViewController:animated:completion:")
            
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
            let originalSelector = Selector("dismissViewControllerAnimated:completion:")
            let swizzledSelector = Selector("stm_dismissViewControllerAnimated:completion:")
            
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
        
        if viewControllerToPresent.simpleTransitionDelegate != nil {
            
            viewControllerToPresent.modalPresentationStyle = .Custom
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

public enum TransitionPresentingViewSizeOptions {
    case KeepSize
    case Shrink
}

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

public enum TransitionAnimatedMotionOptions {
    case EaseInOut
    case Spring
}

public enum TransitionAnimation {
    case Custom
    case Dissolve
    
    case LeftEdge
    case RightEdge
    case TopEdge
    case BottomEdge
}


public class SimpleTransition: NSObject {
    
    public static let flexibleDimension: CGFloat = 0.0

    private(set) weak var stm_presentingViewController: UIViewController!
    private(set) weak var stm_presentedViewController: UIViewController!
    private(set) var fadingEnabled = false
    
    public var animationDuration: CGFloat = 0.4
    public var dismissViaChromeView = true
    
    public var keepPresentingViewOrientation = false
    
    public var presentingViewSizeOption: TransitionPresentingViewSizeOptions = .KeepSize
    public var presentedViewAlignment: TransitionPresentedViewAlignment = .BottomCenter
    public var animatedMotionOption: TransitionAnimatedMotionOptions = .EaseInOut
    
    public var animation: TransitionAnimation = .BottomEdge  {
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
                fadingEnabled = true
                break
            default:
                presentedViewAlignment = .CenterCenter
                break
            }
        }
    }
    
    // custom presented view size
    public var presentedViewSize = CGSize(width: flexibleDimension, height: flexibleDimension)
    
    // animated motion attributes
    public var initialSpringVelocity: CGFloat = 5
    public var springDamping: CGFloat = 0.8
    
    // animators
    public var customPresentedAnimator: NSObject? {
        willSet {
            if let newValue = newValue
                where newValue is UIViewControllerAnimatedTransitioning {
                assert(!(newValue is UIViewControllerAnimatedTransitioning), "customPresentedAnimator does not conform to UIViewControllerAnimatedTransitioning")
            }
        }
    }
    public var customDismissalAnimator: NSObject? {
        willSet {
            if let newValue = newValue
                where newValue is UIViewControllerAnimatedTransitioning {
                    assert(!(newValue is UIViewControllerAnimatedTransitioning), "customDismissalAnimator does not conform to UIViewControllerAnimatedTransitioning")
            }
        }
    }

    private(set) var animator: NSObject?
    
    
    public init(presentingViewController: UIViewController!, presentedViewController: UIViewController!) {
        
        assert(presentingViewController != nil, "no presentingViewController")
        assert(presentedViewController != nil, "no presentedViewController")
        
        stm_presentingViewController = presentingViewController
        stm_presentedViewController = presentedViewController
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension SimpleTransition: UIViewControllerTransitioningDelegate {
    public func animationControllerForPresentedController(presented: UIViewController,
        presentingController presenting: UIViewController,
        sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            switch animation {
            case .Custom:
                if let customPresentedAnimator = customPresentedAnimator
                    where customPresentedAnimator is UIViewControllerAnimatedTransitioning {
                    return customPresentedAnimator as? UIViewControllerAnimatedTransitioning
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
            if let customDismissalAnimator = customDismissalAnimator
                where customDismissalAnimator is UIViewControllerAnimatedTransitioning {
                return customDismissalAnimator as? UIViewControllerAnimatedTransitioning
            }
            return nil
        case .Dissolve, .LeftEdge, .RightEdge, .TopEdge, .BottomEdge:
            guard let t_animator = animator else {
                return nil
            }
            
            guard let unwrappedAnimator = t_animator as? TransformAnimator else {
                return nil
            }
            
            unwrappedAnimator.presenting = false
            return unwrappedAnimator
        }
    }
    
    public func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        let presentationController = SimplePresentationController(presentedViewController: presented, presentingViewController:presenting)
        presentationController.presentedViewAlignment = presentedViewAlignment
        presentationController.dismissViaChromeView = dismissViaChromeView
        presentationController.presentedViewSize = presentedViewSize
        presentationController.keepPresentingViewOrientation = keepPresentingViewOrientation
        return presentationController
    }
}




