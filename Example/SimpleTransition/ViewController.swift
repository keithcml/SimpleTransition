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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animatedMotionLabel.isHidden = true
        animatedMotionSegment.isHidden = true
        transitionDirectionLabel.isHidden = true
        transitionDirectionSegment.isHidden = true
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

        let presentedViewCtl: PresentedViewController! = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PresentedViewController") as! PresentedViewController
        
        let simpleTransitionDelegate = SimpleTransition(presentingViewController: self, presentedViewController: presentedViewCtl)
        
        var size = CGSize.zero
        if sizeSegment.selectedSegmentIndex == 0 {
            size = SimpleTransition.FlexibleSize
        }
        else {
            size = CGSize(width: 300, height: 300)
        }
        
        var animation: TransitionAnimation = .bottomEdge(size: size)
        var alignment: TransitionPresentedViewAlignment = .bottomCenter
        var motion: TransitionAnimatedMotionOptions = .easeInOut(duration: 0.6)
        var presentingViewSize: TransitionPresentingViewSizeOptions
        
        if animationTypeSegment.selectedSegmentIndex == 0 {
            animation = .dissolve(size: size)
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
                motion = .spring(duration: 0.6, velocity: 5, damping: 0.8)
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
        
        simpleTransitionDelegate.setup(
            animation,
            alignment: alignment,
            motion: motion,
            presentingViewSize: presentingViewSize)

        presentedViewCtl.simpleTransitionDelegate = simpleTransitionDelegate
        
        present(presentedViewCtl, animated: true, completion: nil)

    }
    
}
