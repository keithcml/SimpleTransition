//
//  ExampleTableViewController.swift
//  SimpleTransition
//
//  Created by Keith Chan on 8/9/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class ExampleTableViewController: UITableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let vc: ViewController! = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
            navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let vc = PresentingTBViewController(nibName: nil, bundle: nil)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
