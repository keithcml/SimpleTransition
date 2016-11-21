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
    var keepPresentingViewWhenPresentFullScreen = false
    var presentedViewAlignment: TransitionPresentedViewAlignment = .centerCenter
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
    var chromeViewBackgroundColor: UIColor = UIColor(white: 0.0, alpha: 0.3) {
        didSet {
            chromeView.backgroundColor = chromeViewBackgroundColor
        }
    }
    
    let chromeView = UIView()
    
    private var boundsOfPresentedViewInContainerView = CGRect.zero
    
    lazy var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
    
<<<<<<< HEAD
    override init(presentedViewController: UIViewController, presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
=======
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
>>>>>>> 79902a2e71fb5475a2f69cdf0ff361bf325432d2
        chromeView.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
        chromeView.alpha = 0.0
        delegate = self
    }
    
    // MARK: override func
    override func frameOfPresentedViewInContainerView() -> CGRect {
        
        var frame = boundsOfPresentedViewInContainerView
        
        guard let containerView = containerView else { return frame }
        guard let presentedView = presentedView() else { return frame }
        
        switch presentedViewAlignment {
        case .topLeft:
            break;
        case .topCenter:
            frame.origin = CGPoint(x: presentedView.frame.midX - frame.width/2, y: frame.minY)
            break
        case .topRight:
            frame.origin = CGPoint(x: presentedView.frame.width - frame.width, y: frame.minY)
            break
        case .centerLeft:
            frame.origin = CGPoint(x: frame.minX, y: presentedView.frame.midY - frame.height/2)
            break
        case .centerCenter:
            frame.origin = CGPoint(x: presentedView.frame.midX - frame.width/2,
                                   y: presentedView.frame.midY - frame.height/2)
            break
        case .centerRight:
            frame.origin = CGPoint(x: presentedView.frame.width - frame.width,
                                   y: presentedView.frame.midY - frame.height/2)
            break
        case .bottomLeft:
            frame.origin = CGPoint(x: frame.minX,
                                   y: containerView.frame.height - frame.height)
            break
        case .bottomCenter:
            frame.origin = CGPoint(x: containerView.bounds.midX - frame.width/2,
                                   y: containerView.frame.height - frame.height)
            break
        case .bottomRight:
            frame.origin = CGPoint(x: containerView.bounds.width - frame.width,
                                   y: containerView.frame.height - frame.height)
            break
        }
        
        return frame
    }
    
    override func containerViewWillLayoutSubviews() {
        
        guard let containerView = containerView else { return }
        
        guard let presentedView = presentedView() else { return }
        
        chromeView.frame = containerView.bounds;
        
        if (!SimpleTransition.FlexibleSize.equalTo(presentedViewSize)) {
            
            let width = presentedViewSize.width == SimpleTransition.FlexibleDimension ? presentedView.bounds.width : presentedViewSize.width
            let height = presentedViewSize.height == SimpleTransition.FlexibleDimension ? presentedView.bounds.height
                : presentedViewSize.height
            
            boundsOfPresentedViewInContainerView = CGRect(x: 0, y: 0, width: width, height: height)
            presentedView.frame = frameOfPresentedViewInContainerView()
        }
        else {
            boundsOfPresentedViewInContainerView = presentedView.bounds
        }
        
    }
    
    override func presentationTransitionWillBegin() {
        
        guard let containerView = containerView else { return }
        guard let coordinator = presentedViewController.transitionCoordinator() else { return }
        
        chromeView.frame = containerView.bounds
        chromeView.alpha = 0.0
        containerView.insertSubview(chromeView, at:0)
        
        coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext) -> Void in
            self.chromeView.alpha = 1.0
            }, completion: { (context: UIViewControllerTransitionCoordinatorContext) -> Void in
                
        })
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            chromeView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        
        guard let coordinator = presentedViewController.transitionCoordinator() else { return }
        coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext) -> Void in
            self.chromeView.alpha = 0.0
            }, completion: { (context: UIViewControllerTransitionCoordinatorContext) -> Void in
                
        })
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if !completed {
            UIView.animate(
                withDuration: 0.2,
                animations: {
                    self.chromeView.alpha = 1.0;
            })
        }
        else {
            chromeView.removeFromSuperview()
        }
    }
    
    override func shouldPresentInFullscreen() -> Bool {
        if (SimpleTransition.FlexibleSize.equalTo(presentedViewSize) && !keepPresentingViewWhenPresentFullScreen) {
            return true
        }
        return false
    }
    
    override func shouldRemovePresentersView() -> Bool {
        if keepPresentingViewOrientation || shouldPresentInFullscreen() {
            return true
        }
        return false
    }
    
    override func adaptivePresentationStyle() -> UIModalPresentationStyle {
        return .fullScreen
    }
    
    override func adaptivePresentationStyle(for traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .fullScreen
    }
    
    // MARK: Chrome View
    func addTapOnChromeView() {
        chromeView.addGestureRecognizer(tapGesture)
    }
    
    func removeTapOnChromeView() {
        chromeView.removeGestureRecognizer(tapGesture)
    }
    
    // MARK: Tap Chrome View
    func tap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            presentedViewController.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension SimplePresentationController: UIAdaptivePresentationControllerDelegate {
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        // further development...
        return nil
    }
    
}
