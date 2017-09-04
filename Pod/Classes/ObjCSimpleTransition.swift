//
//  ObjCSimpleTransition.swift
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

@objc public enum TransitionAnimationEmumuration: Int {
    case none = 0
    case dissolve
    case leftEdge
    case rightEdge
    case topEdge
    case bottomEdge
}

/**
 Enum to control Presented View Size position relative to its presenting view controller
 */
@objc public enum TransitionPresentedViewAlignmentEnumeration: Int {
    case topLeft = 0
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
@objc public enum TransitionAnimatedMotionEnumeration: Int {
    case easeInOut = 0
    case spring
}

@objc public final class ObjCSimpleTransition: NSObject {
    
    @objc public static let FlexibleDimension: CGFloat = 0.0
    @objc public static let FlexibleSize = CGSize(width: SimpleTransition.FlexibleDimension, height: SimpleTransition.FlexibleDimension)
    
    @objc public var presentedViewSize = ObjCSimpleTransition.FlexibleSize
    @objc public var presentingViewScale: CGFloat = 1.0
    
    /// dismiss presenting view controller when user taps on dimmer area
    @objc open var dismissViaChromeView = true {
        didSet {
            simpleTransitionDelegate?.dismissViaChromeView = dismissViaChromeView
        }
    }
    /// keep presenting view orientation, allow presented view to change orientation only
    @objc open var keepPresentingViewOrientation = false {
        didSet {
            simpleTransitionDelegate?.keepPresentingViewOrientation = keepPresentingViewOrientation
        }
    }
    /// keep presenting view
    @objc open var keepPresentingViewWhenPresentFullScreen = false {
        didSet {
            simpleTransitionDelegate?.keepPresentingViewWhenPresentFullScreen = keepPresentingViewWhenPresentFullScreen
        }
    }
    /// Chrome View background Color
    @objc open var chromeViewBackgroundColor = UIColor(white: 0.0, alpha: 0.3) {
        didSet {
            simpleTransitionDelegate?.chromeViewBackgroundColor = chromeViewBackgroundColor
        }
    }
    
    private var simpleTransitionDelegate: SimpleTransition?
    private weak var presentedViewController: UIViewController?
    
    /**
     Designate Initializer.
     - Parameter presentingViewController:   The Presenting View Controller.
     - Parameter presentedViewController: The Presented View Controller.
     */
    @objc public init(presentingViewController: UIViewController!, presentedViewController: UIViewController!) {
        simpleTransitionDelegate = SimpleTransition(presentingViewController: presentingViewController, presentedViewController: presentedViewController)
        self.presentedViewController = presentedViewController
    }
    
    @objc public func setupTransition(presentingAnimation: TransitionAnimationEmumuration,
                                      dismissalAnimation: TransitionAnimationEmumuration,
                                      alignment: TransitionPresentedViewAlignmentEnumeration,
                                      motion: TransitionAnimatedMotionEnumeration,
                                      animationDuration: TimeInterval = 0.4,
                                      animationVelocity: CGFloat = 5.0,
                                      animationDamping: CGFloat = 0.8,
                                      presentingViewScale: CGFloat,
                                      presentedViewSize: CGSize,
                                      zoomConfig: ZoomConfig?) {
   
        self.presentedViewSize = presentedViewSize
        self.presentingViewScale = presentingViewScale
        
        var presenting = TransitionAnimation.dissolve(size: SimpleTransition.FlexibleSize)
        var dismissal = TransitionAnimation.dissolve(size: SimpleTransition.FlexibleSize)
        var alignmentOption = TransitionPresentedViewAlignment.bottomCenter
        var motionOption = TransitionAnimatedMotionOptions.easeInOut(duration: animationDuration)
        var presentingViewSize = TransitionPresentingViewSizeOptions.equal
        
        switch presentingAnimation {
        case .none:
            break
        case .dissolve:
            presenting = TransitionAnimation.dissolve(size: presentedViewSize)
            break
        case .leftEdge:
            presenting = TransitionAnimation.leftEdge(size: presentedViewSize)
            break
        case .rightEdge:
            presenting = TransitionAnimation.rightEdge(size: presentedViewSize)
            break
        case .topEdge:
            presenting = TransitionAnimation.topEdge(size: presentedViewSize)
            break
        case .bottomEdge:
            presenting = TransitionAnimation.bottomEdge(size: presentedViewSize)
            break
        }
        
        switch dismissalAnimation {
        case .none:
            break
        case .dissolve:
            dismissal = TransitionAnimation.dissolve(size: presentedViewSize)
            break
        case .leftEdge:
            dismissal = TransitionAnimation.leftEdge(size: presentedViewSize)
            break
        case .rightEdge:
            dismissal = TransitionAnimation.rightEdge(size: presentedViewSize)
            break
        case .topEdge:
            dismissal = TransitionAnimation.topEdge(size: presentedViewSize)
            break
        case .bottomEdge:
            dismissal = TransitionAnimation.bottomEdge(size: presentedViewSize)
            break
        }
        
        switch alignment {
        case .topLeft:
            alignmentOption = .topLeft
            break
        case .topCenter:
            alignmentOption = .topCenter
            break
        case .topRight:
            alignmentOption = .topRight
            break
        case .centerLeft:
            alignmentOption = .centerLeft
            break
        case .centerCenter:
            alignmentOption = .centerCenter
            break
        case .centerRight:
            alignmentOption = .centerRight
            break
        case .bottomLeft:
            alignmentOption = .bottomLeft
            break
        case .bottomCenter:
            alignmentOption = .bottomCenter
            break
        case .bottomRight:
            alignmentOption = .bottomRight
            break
        }
        
        switch motion {
        case .easeInOut:
            motionOption = .easeInOut(duration: animationDuration)
            break
        case .spring:
            motionOption = .spring(duration: animationDuration, velocity: animationVelocity, damping: animationDamping)
            break
        }
        
        if presentingViewScale == 1.0 {
            presentingViewSize = TransitionPresentingViewSizeOptions.equal
        }
        else {
            presentingViewSize = TransitionPresentingViewSizeOptions.scale(scale: presentingViewScale)

        }

        simpleTransitionDelegate?.setupTransition(
            presentingAnimation: presenting,
            dismissalAnimation: dismissal,
            alignment: alignmentOption,
            motion: motionOption,
            presentingViewSize: presentingViewSize,
            zoomConfig: zoomConfig)
    }

    
    @objc public func setTransitionDelegate() {
        presentedViewController?.simpleTransitionDelegate = simpleTransitionDelegate
    }
}
