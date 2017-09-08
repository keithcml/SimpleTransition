//
//  PresentingTBViewController.swift
//  SimpleTransition
//
//  Created by Keith Chan on 8/9/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import SimpleTransition

class TableViewCell: UITableViewCell {
    
    var tap: (UIView) -> () = { _ in }
    let testImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        testImageView.image = UIImage(named: "test")
        testImageView.contentMode = .scaleAspectFill
        testImageView.isUserInteractionEnabled = true
        contentView.addSubview(testImageView)
        
        testImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        tap(sender.view!)
    }
}

class PresentingTBViewController: UIViewController {
    
    var tableView = UITableView(frame: CGRect.zero, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.frame = view.bounds
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }
    
    func present(from fromView: UIView) {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 320, height: 120)
        let presentedViewCtl: PresentedCollectionViewController! = PresentedCollectionViewController(collectionViewLayout: layout)
        
        //let presentedViewCtl: PresentedViewController! = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PresentedViewController") as! PresentedViewController
        
        let config = ZoomConfig(zoomingView: fromView,
                                explicitSourceRect: nil,
                                destinationView: { () -> UIView? in
                                    let indexPath = IndexPath(item: 10, section: 0)
                                    if let cell = presentedViewCtl.collectionView?.cellForItem(at: indexPath) as? CollectionViewCell {
                                        return cell.testImageView
                                    }
                                    return nil
                                })
        
        let simpleTransitionDelegate = SimpleTransition(presentingViewController: self, presentedViewController: presentedViewCtl)
        
        //simpleTransitionDelegate.autoDefinesPresentationContext = true
        simpleTransitionDelegate.isPresentedFullScreen = false
        
        simpleTransitionDelegate.setupTransition(
            presentingAnimation: .dissolve(size: SimpleTransition.FlexibleSize),
            dismissalAnimation: .dissolve(size: SimpleTransition.FlexibleSize),
            alignment: .bottomCenter,
            motion: .spring(duration: 0.3, velocity: 5, damping: 0.8),
            presentingViewSize: .equal,
            zoomConfig: config)
        
        presentedViewCtl.simpleTransitionDelegate = simpleTransitionDelegate
        
        present(presentedViewCtl, animated: true, completion: nil)
    }
}

extension PresentingTBViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        cell.tap = { [weak self] fromView in
            self?.present(from: fromView)
        }
        return cell
    }
}
