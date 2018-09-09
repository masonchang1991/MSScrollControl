//
//  ViewController4.swift
//  MSScrollControl_Example
//
//  Created by Mason on 2018/9/8.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import MSScrollControl

class ViewController4: UIViewController {

    @IBOutlet weak var demoCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "MS-Demo4"
        
        setupView()
        setupCollectionView()
        configScrollView()
    }
    
    func setupView() {
        view.backgroundColor = UIColor.blue
    }
    
    func setupCollectionView() {
        demoCollectionView.delegate = self
        demoCollectionView.dataSource = self
    }
    
    
    func configScrollView() {
        
        let parameters: [MSScrollControlParameter] = [
            .isStatusBarScrollable(true),
            .scrollHideSpeed(0.7),
            .isTabBarScrollable(true),
            .isTopFloatingSpaceScrollable(true),
            .delayDistance(50.0)
        ]
        
        let scrollControl = MSScrollControl(viewController: self,
                                            tabbarController: tabBarController,
                                            navController: navigationController,
                                            parameters: parameters)
        demoCollectionView.msScrollControl = scrollControl
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.msScrollControl?.barUpdate()
    }
}

extension ViewController4: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? UICollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if indexPath.row <= 3 {
            cell.backgroundColor = UIColor.red
        } else {
            cell.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width
        let height: CGFloat = 40.0
        
        return CGSize(width: width, height: height)
    }
}
