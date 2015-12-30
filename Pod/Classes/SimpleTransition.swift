//
//  TransitionManager.swift
//  Example
//
//  Created by Mingloan Chan on 28/12/2015.
//
//

import Foundation
import UIKit

extension UIViewController {
    private struct AssociatedKeys {
        static var simpleTransitionDelegate: SimpleTransitionDelegate?
    }
    
    var simpleTransitionDelegate: SimpleTransitionDelegate? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.simpleTransitionDelegate) as? SimpleTransitionDelegate
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.simpleTransitionDelegate,
                    newValue as SimpleTransitionDelegate?,
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
            } else {
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
        
        if self.simpleTransitionDelegate != nil && self.simpleTransitionDelegate!.isKindOfClass(SimpleTransitionDelegate) {
            // things to do ...
            self.stm_dismissViewControllerAnimated(flag, completion: completion)
        }
        else {
            self.stm_dismissViewControllerAnimated(flag, completion: completion)
        }
    }
}

enum TransitionPresentingViewSizeOptions {
    case KeepSize
    case Shrink
}

enum TransitionPresentedViewAlignment {
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

enum TransitionAnimatedMotionOptions {
    case EaseInOut
    case Spring
}

enum TransitionAnimation {
    case Custom
    case Dissolve
    
    case LeftEdge
    case RightEdge
    case TopEdge
    case BottomEdge
}


class SimpleTransitionDelegate: NSObject {
    
    static let flexibleDimension: CGFloat = 0.0

    private(set) weak var stm_presentingViewController: UIViewController!
    private(set) weak var stm_presentedViewController: UIViewController!
    private(set) var fadingEnabled: Bool = false
    
    var animationDuration: CGFloat = 0.4
    var dismissViaChromeView: Bool = true
    
    var keepPresentingViewOrientation = false
    
    var presentingViewSizeOption: TransitionPresentingViewSizeOptions = .KeepSize
    var presentedViewAlignment: TransitionPresentedViewAlignment = .BottomCenter
    var animatedMotionOption: TransitionAnimatedMotionOptions = .EaseInOut
    
    var animation: TransitionAnimation = .BottomEdge  {
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
    var presentedViewSize: CGSize = CGSizeMake(flexibleDimension, flexibleDimension)
    
    // animated motion attributes
    var initialSpringVelocity: CGFloat = 5
    var springDamping: CGFloat = 0.8
    
    // animators
    var customPresentedAnimator: NSObject? {
        willSet {
            if newValue != nil {
                if !newValue!.conformsToProtocol(UIViewControllerAnimatedTransitioning) {
                    assert(!newValue!.conformsToProtocol(UIViewControllerAnimatedTransitioning), "customPresentedAnimator does not conform to UIViewControllerAnimatedTransitioning")
                }
            }
        }
    }
    var customDismissalAnimator: NSObject? {
        willSet {
            if newValue != nil {
                if !newValue!.conformsToProtocol(UIViewControllerAnimatedTransitioning) {
                    assert(!newValue!.conformsToProtocol(UIViewControllerAnimatedTransitioning), "customDismissalAnimator does not conform to UIViewControllerAnimatedTransitioning")
                }
            }
        }
    }
    private(set) var animator: NSObject?
    
    
    init(presentingViewController: UIViewController!, presentedViewController: UIViewController!) {
        
        assert(presentingViewController != nil, "no presentingViewController")
        assert(presentedViewController != nil, "no presentedViewController")
        
        stm_presentingViewController = presentingViewController
        stm_presentedViewController = presentedViewController
    }
    
    func prepareToPresent() {
        stm_presentedViewController.transitioningDelegate = self;
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension SimpleTransitionDelegate: UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController,
        presentingController presenting: UIViewController,
        sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            switch animation {
            case .Custom:
                if customPresentedAnimator != nil {
                    if customPresentedAnimator!.conformsToProtocol(UIViewControllerAnimatedTransitioning) {
                        return customPresentedAnimator as? UIViewControllerAnimatedTransitioning
                    }
                }
                return nil
            case .Dissolve, .LeftEdge, .RightEdge, .TopEdge, .BottomEdge:
                let t_animator: TransformAnimator! = TransformAnimator()
                t_animator.presenting = true
                t_animator.transitionDelegate = self
                animator = t_animator
                return t_animator
            }
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch animation {
        case .Custom:
            if customDismissalAnimator != nil {
                if customDismissalAnimator!.conformsToProtocol(UIViewControllerAnimatedTransitioning) {
                    return customDismissalAnimator as? UIViewControllerAnimatedTransitioning
                }
            }
            return nil
        case .Dissolve, .LeftEdge, .RightEdge, .TopEdge, .BottomEdge:
            let t_animator: TransformAnimator! = animator as! TransformAnimator
            t_animator.presenting = false
            return t_animator
        }
    }
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        let presentationController: SimplePresentationController = SimplePresentationController(presentedViewController: presented, presentingViewController:presenting)
        presentationController.presentedViewAlignment = presentedViewAlignment
        presentationController.dismissViaChromeView = dismissViaChromeView
        presentationController.presentedViewSize = presentedViewSize
        presentationController.keepPresentingViewOrientation = keepPresentingViewOrientation
        return presentationController
    }
}




