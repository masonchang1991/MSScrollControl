//
//  ViewController2.swift
//  MSScrollControl_Example
//
//  Created by Mason on 2018/3/15.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import MSScrollControl

class ViewController2: UIViewController {
    
    @IBOutlet weak var demoCollectionView: UICollectionView!
    
    override func loadView() {
        super.loadView()
//        self.edgesForExtendedLayout = []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blue
        demoCollectionView.delegate = self
        demoCollectionView.dataSource = self
        //        demoCollectionView.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
        
        //        self.view.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        self.title = "MS-Demo2"
        
        configScrollView()
        

    }
    
    
    func configScrollView() {
        
        
        let parameters: [MSScrollControlParameter] = [
            .isStatusBarScrollable(true),
            .scrollHideSpeed(0.7),
            .isTabBarScrollable(true),
            .isTopFloatingSpaceScrollable(true),
            .delayDistance(50.0)
        ]
        
        self.demoCollectionView.msScrollControl = MSScrollControl(viewController: self,
                                                                  tabbarController: self.tabBarController,
                                                                  navController: self.navigationController,
                                                                  parameters: parameters)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.msScrollControl?.barUpdate()
    }
}

extension ViewController2: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
        
//        cell.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width
        let height: CGFloat = 40.0
        
        return CGSize(width: width, height: height)
    }
    
    
}
