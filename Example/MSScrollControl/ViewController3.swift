//
//  ViewController.swift
//  MSScrollControl
//
//  Created by masonchang1991 on 03/15/2018.
//  Copyright (c) 2018 masonchang1991. All rights reserved.
//

import UIKit
import MSScrollControl

class ViewController3: UIViewController {
    
    @IBOutlet weak var demoCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        demoCollectionView.delegate = self
        demoCollectionView.dataSource = self
        demoCollectionView.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
        self.title = "MS-Demo3"
        
        self.view.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        configScrollView()
        
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func configScrollView() {
        
        let parameters: [MSScrollControlParameter] = [
            .isStatusBarScrollable(true),
            .scrollHideSpeed(0.7),
            .isTabBarScrollable(true),
            .isTopFloatingSpaceScrollable(true),
            .delayDistance(0.0)
        ]
        
        self.demoCollectionView.msScrollControl = MSScrollControl(viewController: self,
                                                                  tabbarController: self.tabBarController,
                                                                  parameters: parameters)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.msScrollControl?.barUpdate()
    }
}

extension ViewController3: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
        
        cell.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width
        let height: CGFloat = 40.0
        
        return CGSize(width: width, height: height)
    }
    
    
}



