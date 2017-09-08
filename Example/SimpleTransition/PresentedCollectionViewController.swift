//
//  PresentedCollectionViewController.swift
//  SimpleTransition
//
//  Created by Keith Chan on 8/9/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    var tap: (UIView) -> () = { _ in }
    let testImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        commonInit()
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

class PresentedCollectionViewController: UICollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        collectionView?.backgroundColor = .white
        collectionView?.register(CollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
    }
    
    deinit {
        print("PresentedCollectionViewController dealloc successfully")
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        cell.tap = { [weak self] fromView in
            self?.dismiss(from: fromView)
        }
        return cell
    }
    
    func dismiss(from fromView: UIView) {
        dismiss(animated: true, completion: nil)
    }
}
