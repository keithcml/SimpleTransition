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
        
        animatedMotionLabel.hidden = true
        animatedMotionSegment.hidden = true
        transitionDirectionLabel.hidden = true
        transitionDirectionSegment.hidden = true
    }
    
    @IBAction func animationChanged(sender: AnyObject) {
        if animationTypeSegment.selectedSegmentIndex == 0 {
            
            animatedMotionSegment.selectedSegmentIndex = 0
            
            animatedMotionLabel.hidden = true
            animatedMotionSegment.hidden = true
            transitionDirectionLabel.hidden = true
            transitionDirectionSegment.hidden = true
            /*
            horizontalAlignmentLabel.hidden = false
            horizontalAlignmentSegment.hidden = false
            verticleAlignmentLabel.hidden = false
            verticleAlignmentSegment.hidden = false
            */
        }
        else {
            animatedMotionLabel.hidden = false
            animatedMotionSegment.hidden = false
            transitionDirectionLabel.hidden = false
            transitionDirectionSegment.hidden = false
            /*
            horizontalAlignmentLabel.hidden = true
            horizontalAlignmentSegment.hidden = true
            verticleAlignmentLabel.hidden = true
            verticleAlignmentSegment.hidden = true
            */
        }
    }
    
    @IBAction func present(sender: AnyObject) {

        let presentedViewCtl: PresentedViewController! = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PresentedViewController") as! PresentedViewController
        
        let simpleTransitionDelegate = SimpleTransition(presentingViewController: self, presentedViewController: presentedViewCtl)
        
        var size = CGSizeZero
        if sizeSegment.selectedSegmentIndex == 0 {
            size = SimpleTransition.FlexibleSize
        }
        else {
            size = CGSize(width: SimpleTransition.FlexibleDimension, height: 300)
        }
        
        var animation: TransitionAnimation = .BottomEdge(size: size)
        //let alignment: TransitionPresentedViewAlignment = .BottomCenter
        var motion: TransitionAnimatedMotionOptions = .EaseInOut(duration: 0.6)
        var presentingViewSize: TransitionPresentingViewSizeOptions
        
        if animationTypeSegment.selectedSegmentIndex == 0 {
            animation = .Dissolve(size: size)
        }
        else {
            switch transitionDirectionSegment.selectedSegmentIndex {
            case 0:
                animation = .LeftEdge(size: size)
                break
            case 1:
                animation = .RightEdge(size: size)
                break
            case 2:
                animation = .TopEdge(size: size)
                break
            case 3:
                animation = .BottomEdge(size: size)
                break
            default:
                break
            }
            
            if animatedMotionSegment.selectedSegmentIndex == 0 {
                motion = .EaseInOut(duration: 0.3)
            }
            else {
                motion = .Spring(duration: 0.6, velocity: 5, damping: 0.8)
            }
        }
        
        if presentingViewSizeSegment.selectedSegmentIndex == 0 {
            presentingViewSize = .Equal
        }
        else {
            presentingViewSize = .Scale(scale: 0.95)
        }
        
        simpleTransitionDelegate.setup(animation, motion: motion, presentingViewSize: presentingViewSize)

        presentedViewCtl.simpleTransitionDelegate = simpleTransitionDelegate
        
        self.presentViewController(presentedViewCtl, animated: true, completion: nil)

    }
}
