//
//  ViewController.swift
//  SimpleTransition
//
//  Created by Keith on 12/30/2015.
//  Copyright (c) 2015 Keith. All rights reserved.
//


import UIKit
import SimpleTransition

class ViewController: UIViewController {
    
    @IBOutlet weak var animationTypeSegment: UISegmentedControl!
    @IBOutlet weak var presentingViewSizeSegment: UISegmentedControl!
    @IBOutlet weak var animatedMotionSegment: UISegmentedControl!
    @IBOutlet weak var horizontalAlignmentSegment: UISegmentedControl!
    @IBOutlet weak var verticleAlignmentSegment: UISegmentedControl!
    @IBOutlet weak var transitionDirectionSegment: UISegmentedControl!
    @IBOutlet weak var sizeSegment: UISegmentedControl!
    
    @IBOutlet weak var animationTypeLabel: UILabel!
    @IBOutlet weak var presentingViewSizeLabel: UILabel!
    @IBOutlet weak var animatedMotionLabel: UILabel!
    @IBOutlet weak var horizontalAlignmentLabel: UILabel!
    @IBOutlet weak var verticleAlignmentLabel: UILabel!
    @IBOutlet weak var transitionDirectionLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animatedMotionLabel.isHidden = true
        animatedMotionSegment.isHidden = true
        transitionDirectionLabel.isHidden = true
        transitionDirectionSegment.isHidden = true
        
        self.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTap(_:))))
    }
    
    @IBAction func imageTap(_ sender: Any) {
        
        present(isImageTap: true)
        //presentWithObjectiveCAPI(isImageTap: true)
    }
    
    @IBAction func animationChanged(_ sender: AnyObject) {
        if animationTypeSegment.selectedSegmentIndex == 0 {
            
            animatedMotionSegment.selectedSegmentIndex = 0
            
            animatedMotionLabel.isHidden = true
            animatedMotionSegment.isHidden = true
            transitionDirectionLabel.isHidden = true
            transitionDirectionSegment.isHidden = true
        }
        else {
            animatedMotionLabel.isHidden = false
            animatedMotionSegment.isHidden = false
            transitionDirectionLabel.isHidden = false
            transitionDirectionSegment.isHidden = false
        }
    }
    
    @IBAction func horizontalAlignChanged(_ sender: UISegmentedControl) {
    }
    
    @IBAction func verticalAlignChanged(_ sender: UISegmentedControl) {
    }
    
    @IBAction func present(_ sender: AnyObject) {
        present(isImageTap: false)
        //presentWithObjectiveCAPI(isImageTap: false)
    }
    
    private func presentWithObjectiveCAPI(isImageTap: Bool) {
        
        let presentedViewCtl: PresentedViewController! = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PresentedViewController") as! PresentedViewController
        
        let simpleTransitionObject = ObjCSimpleTransition(presentingViewController: self, presentedViewController: presentedViewCtl)
        
        var size = CGSize.zero
        if sizeSegment.selectedSegmentIndex == 0 {
            size = ObjCSimpleTransition.FlexibleSize
        }
        else {
            size = CGSize(width: view.frame.width, height: 300)
        }
        
        var animation: TransitionAnimationEmumuration = .bottomEdge
        var alignment: TransitionPresentedViewAlignmentEnumeration = .bottomCenter
        var motion: TransitionAnimatedMotionEnumeration = .easeInOut
        var animationDuration: TimeInterval = 0.6
        var animationVelocity: CGFloat = 5
        var animationDamping: CGFloat = 0.8
        var presentingViewScale: CGFloat = 0.8

        if animationTypeSegment.selectedSegmentIndex == 0 {
            animation = .dissolve
            motion = .easeInOut
            animationDuration = 0.2
        }
        else {
            switch transitionDirectionSegment.selectedSegmentIndex {
            case 0:
                animation = .leftEdge
                break
            case 1:
                animation = .rightEdge
                break
            case 2:
                animation = .topEdge
                break
            case 3:
                animation = .bottomEdge
                break
            default:
                break
            }
            
            if animatedMotionSegment.selectedSegmentIndex == 0 {
                motion = .easeInOut
                animationDuration = 0.3
            }
            else {
                motion = .spring
                animationVelocity = 5
                animationDamping = 0.8
            }
        }
        
        if presentingViewSizeSegment.selectedSegmentIndex == 0 {
            presentingViewScale = 1.0
        }
        else {
            presentingViewScale = 0.8
        }
        
        switch (horizontalAlignmentSegment.selectedSegmentIndex, verticleAlignmentSegment.selectedSegmentIndex) {
        case (0, 0):
            alignment = .topLeft
            break
        case (0, 1):
            alignment = .centerLeft
            break
        case (0, 2):
            alignment = .bottomLeft
            break
        case (1, 0):
            alignment = .topCenter
            break
        case (1, 1):
            alignment = .centerCenter
            break
        case (1, 2):
            alignment = .bottomCenter
            break
        case (2, 0):
            alignment = .topRight
            break
        case (2, 1):
            alignment = .centerRight
            break
        case (2, 2):
            alignment = .bottomRight
            break
        default:
            break
        }
        
        if isImageTap {
            
            let config = ZoomConfig(zoomingView: self.imageView,
                                              explicitSourceRect: nil,
                                              destinationView: { () -> UIView in
                                                return presentedViewCtl.imageView
                                            })
            config.disableZoomOutEffect = true
            
            simpleTransitionObject.setupTransition(
                presentingAnimation: animation,
                dismissalAnimation: .bottomEdge,
                alignment: alignment,
                motion: motion,
                animationDuration: animationDuration,
                animationVelocity: animationVelocity,
                animationDamping: animationDamping,
                presentingViewScale: presentingViewScale,
                presentedViewSize: size,
                zoomConfig: config)
        }
        else {
            simpleTransitionObject.setupTransition(
                presentingAnimation: animation,
                dismissalAnimation: animation,
                alignment: alignment,
                motion: motion,
                animationDuration: animationDuration,
                animationVelocity: animationVelocity,
                animationDamping: animationDamping,
                presentingViewScale: presentingViewScale,
                presentedViewSize: size,
                zoomConfig: nil)
        }
        
        
        simpleTransitionObject.setTransitionDelegate()
        
        present(presentedViewCtl, animated: true, completion: nil)
    }
    
    private func present(isImageTap: Bool) {
        
        let presentedViewCtl: PresentedViewController! = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PresentedViewController") as! PresentedViewController
        
        let simpleTransitionDelegate = SimpleTransition(presentingViewController: self, presentedViewController: presentedViewCtl)
        
        var size = CGSize.zero
        if sizeSegment.selectedSegmentIndex == 0 {
            size = SimpleTransition.FlexibleSize
        }
        else {
            size = CGSize(width: view.frame.width, height: 300)
        }
        
        var animation: TransitionAnimation = .bottomEdge(size: size)
        var alignment: TransitionPresentedViewAlignment = .bottomCenter
        var motion: TransitionAnimatedMotionOptions = .easeInOut(duration: 0.6)
        var presentingViewSize: TransitionPresentingViewSizeOptions
        
        if animationTypeSegment.selectedSegmentIndex == 0 {
            animation = .dissolve(size: size)
            motion = .easeInOut(duration: 0.2)
        }
        else {
            switch transitionDirectionSegment.selectedSegmentIndex {
            case 0:
                animation = .leftEdge(size: size)
                break
            case 1:
                animation = .rightEdge(size: size)
                break
            case 2:
                animation = .topEdge(size: size)
                break
            case 3:
                animation = .bottomEdge(size: size)
                break
            default:
                break
            }
            
            if animatedMotionSegment.selectedSegmentIndex == 0 {
                motion = .easeInOut(duration: 0.3)
            }
            else {
                motion = .spring(duration: 0.4, velocity: 5, damping: 0.8)
            }
        }
        
        if presentingViewSizeSegment.selectedSegmentIndex == 0 {
            presentingViewSize = .equal
        }
        else {
            presentingViewSize = .scale(scale: 0.95)
        }
        
        switch (horizontalAlignmentSegment.selectedSegmentIndex, verticleAlignmentSegment.selectedSegmentIndex) {
        case (0, 0):
            alignment = .topLeft
            break
        case (0, 1):
            alignment = .centerLeft
            break
        case (0, 2):
            alignment = .bottomLeft
            break
        case (1, 0):
            alignment = .topCenter
            break
        case (1, 1):
            alignment = .centerCenter
            break
        case (1, 2):
            alignment = .bottomCenter
            break
        case (2, 0):
            alignment = .topRight
            break
        case (2, 1):
            alignment = .centerRight
            break
        case (2, 2):
            alignment = .bottomRight
            break
        default:
            break
        }
        
        if isImageTap {
            
            let config = ZoomConfig(zoomingView: self.imageView,
                                        explicitSourceRect: nil,
                                        destinationView: { () -> UIView in
                                            return presentedViewCtl.imageView
                                        })
            config.disableZoomOutEffect = true
            
            simpleTransitionDelegate.setupTransition(
                presentingAnimation: .dissolve(size: size),
                dismissalAnimation: animation,
                alignment: alignment,
                motion: motion,
                presentingViewSize: presentingViewSize,
                zoomConfig: config)
        }
        else {
            simpleTransitionDelegate.setupTransition(
                presentingAnimation: animation,
                alignment: alignment,
                motion: motion,
                presentingViewSize: presentingViewSize)
        }
        
        
        
        presentedViewCtl.simpleTransitionDelegate = simpleTransitionDelegate
        
        present(presentedViewCtl, animated: true, completion: nil)

    }
    
}
