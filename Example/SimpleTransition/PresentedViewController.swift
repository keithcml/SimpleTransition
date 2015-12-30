//
//  PresentedViewController.swift
//  Example
//
//  Created by Mingloan Chan on 28/12/2015.
//
//

import Foundation
import UIKit

class PresentedViewController: UIViewController {
    
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}