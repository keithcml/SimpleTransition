//
//  PresentedViewController.swift
//  Example
//
//  Created by Mingloan Chan on 28/12/2015.
//
//

import Foundation
import UIKit
import SimpleTransition

class PresentedViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func dismiss(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("deinit")
    }
    
    @IBAction func present(_ sender: Any) {
        
        let innerViewCtl: InnerViewController! = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InnerViewController") as! InnerViewController
        
        let simpleTransitionDelegate = SimpleTransition(presentingViewController: self, presentedViewController: innerViewCtl)
        simpleTransitionDelegate.autoDefinesPresentationContext = true
        simpleTransitionDelegate.isPresentedFullScreen = false
        simpleTransitionDelegate.keepPresentingViewAfterPresentation = true
        simpleTransitionDelegate.setupTransition(
            presentingAnimation: .leftEdge(size: SimpleTransition.FlexibleSize),
            alignment: .bottomCenter,
            motion: .easeInOut(duration: 0.3),
            presentingViewSize: .equal)
        
        innerViewCtl.simpleTransitionDelegate = simpleTransitionDelegate
        
        present(innerViewCtl, animated: true, completion: nil)
        
    }
    
}
