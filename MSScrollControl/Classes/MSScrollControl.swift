//
//  MSScrollControl.swift
//  LuluVideo
//
//  Created by Mason on 2018/1/30.
//  Copyright © 2018年 appimc.com. All rights reserved.
//

import Foundation
import UIKit

public class MSScrollControl {
    
    var scrollView: UIScrollView = UIScrollView()
    
    private var lastOffset = CGPoint(x: 0.0, y: 0.0)
    
    private var originVCHeight: CGFloat = 0.0
    
    private var originVCFrame: CGRect = CGRect.zero
    
    private var navbarHeight: CGFloat = 0.0
    
    private var tabbarHeight: CGFloat = 0.0
    
    private var isFirstScroll: Bool = true
    
    private var isAnimating: Bool = false
    
    private weak var viewController: UIViewController?
    
    private weak var tabbarController: UITabBarController? {
        didSet {
            if tabbarController != nil {
                self.isTabBarScrollable = true
            }
        }
    }
    
    private weak var navController: UINavigationController?
    
    private(set) var statusBarWindow: UIWindow!
    
    private(set) var statusBarHeight: CGFloat = 0.0
    
    private(set) var windowHeight: CGFloat = 0.0
    
    private(set) var totalTopFloatingHeight: CGFloat = 0.0
    
    private(set) var vcMaxHeight: CGFloat = 0.0
    
    
    
    // Because if you have navbar, your view does not contain navBar and statusBar
    fileprivate var isVCAddedNavControllerTopSpace: Bool = false
    
    private(set) var changeRatio: CGFloat = 0.0
    
    private(set) var delayDistanceNeedToConsume: CGFloat = 0.0
    
    fileprivate var delayDistance: CGFloat = 0.0 {
        didSet {
            self.delayDistanceNeedToConsume = delayDistance
        }
    }
    
    fileprivate var scrollHideSpeed: CGFloat = 1.0
    
    fileprivate var topFloatingHeight: CGFloat = 0
    
    fileprivate var isStatusBarScrollable = true
    
    fileprivate var isTabBarScrollable = false
    
    fileprivate var isTopFloatingSpaceScrollable = true
    
    private(set) var state: MSScrollControlState = .initial {
        willSet {
            if state != newValue {
                //
            }
        }
        didSet {
            if state != oldValue {
                
            }
        }
    }
    
    public init(viewController: UIViewController, tabbarController: UITabBarController?) {
        self.viewController = viewController
        self.tabbarController = tabbarController
        if tabbarController != nil {
            self.tabbarHeight = tabbarController!.tabBar.frame.height
        }
        setupInitData()
    }
    
    public init(viewController: UIViewController, tabbarController: UITabBarController?, parameters: [MSScrollControlParameter]) {
        self.viewController = viewController
        self.tabbarController = tabbarController
        if tabbarController != nil {
            self.tabbarHeight = tabbarController!.tabBar.frame.height
        }
        self.configureMSScrollControl(parameters: parameters)
        setupInitData()
    }
    
    public init(viewController: UIViewController, tabbarController: UITabBarController?, navController: UINavigationController?, parameters: [MSScrollControlParameter]) {
        self.viewController = viewController
        self.tabbarController = tabbarController
        if tabbarController != nil {
            self.tabbarHeight = tabbarController!.tabBar.frame.height
        }
        self.navController = navController
        if navController != nil {
            self.navbarHeight = navController!.navigationBar.frame.height
        }
        self.configureMSScrollControl(parameters: parameters)
        setupInitData()
    }
    
    public func setupInitData() {
        guard let statusBarWindow = UIApplication.shared.value(forKey: "statusBarWindow") as? UIWindow else { return }
        self.statusBarWindow = statusBarWindow
        self.statusBarHeight = UIApplication.shared.statusBarFrame.height
        self.windowHeight = UIScreen.main.bounds.height
        self.totalTopFloatingHeight = (isStatusBarScrollable ? statusBarHeight: 0.0) +
            (isTopFloatingSpaceScrollable ? (topFloatingHeight + navbarHeight): 0.0)
    }
    
    
    public func barUpdate() {
        
        if isAnimating { return }
        
        if isFirstScroll {
            self.originVCHeight = viewController?.view.frame.height ?? UIScreen.main.bounds.height
            self.originVCFrame = viewController?.view.frame ?? UIScreen.main.bounds
            self.vcMaxHeight = originVCHeight +
                totalTopFloatingHeight +
                (isTabBarScrollable ? tabbarHeight: 0.0)
            self.isFirstScroll = false
        }
        
        // Calculate scroll distance
        let currentOffset = scrollView.contentOffset
        let distance =  currentOffset.y - lastOffset.y
        self.lastOffset = currentOffset
        
        // if there is a delay distance
        if distance > 0 && self.delayDistanceNeedToConsume > 0 {
            self.delayDistanceNeedToConsume -= distance
            return
        } else if self.changeRatio == 0 && distance < 0{
            self.delayDistanceNeedToConsume = self.delayDistance
        }
        
        let scrollViewHeight = scrollView.frame.height
        let scrollViewContentSize = scrollView.contentSize
        
        let currentOffsetBottom = currentOffset.y +
        scrollViewHeight
        
        // avoid tap tabbar when user is scrolling
        self.tabbarController?.tabBar.isUserInteractionEnabled = changeRatio == 0.0 ? true: false
        
        // if scroll direction is down && statusbar doesn't reach to top(y == -totalTopFloatingHeight) && bottom doesn't reach to scrollViewBottom && if currentOffSet.y - distance < 0 mean you are out of origin top, don't change frame
        if distance > 0 && (statusBarWindow.frame.minY > -totalTopFloatingHeight || viewController?.view.frame.height != vcMaxHeight) && currentOffsetBottom + distance < scrollViewContentSize.height && currentOffset.y - distance >= 0 {
            
            DispatchQueue.main.async {
                self.state = .scrolling(.scrollDown)
                self.updateStatusBarWith(distance: distance)
                
                if self.tabbarController != nil && self.isTabBarScrollable {
                    self.updateTabbar()
                }
                
                if self.navController != nil && self.isTopFloatingSpaceScrollable {
                    self.updateNavBar()
                }
                
                self.updateVCFrameWith(distance: distance)
            }
            
            // distance < 0 means scroll up
            // currentOffsetBottom - distance < scrollViewContentSize.height is to prevent scroll out of bottom and rebound back
            // currentOffset.y + distance >= 0 is to prevent scroll out of top
        } else if distance < 0 && currentOffsetBottom - distance < scrollViewContentSize.height && currentOffset.y + distance >= 0 {
            
            DispatchQueue.main.async {
                self.state = .scrolling(.scrollUp)
                self.updateStatusBarWith(distance: distance)
                
                if self.tabbarController != nil && self.isTabBarScrollable {
                    self.updateTabbar()
                }
                
                if self.navController != nil && self.isTopFloatingSpaceScrollable {
                    self.updateNavBar()
                }
                self.updateVCFrameWith(distance: distance)
            }
        }
    }
    
    public func barEndUpdate() {
        
        if isAnimating { return }
        
        if self.changeRatio < 0.5 && self.changeRatio > 0.0 {
            
            self.changeRatio = 0.0
            
            UIView.animate(withDuration: 0.15, animations: {
                self.isAnimating = true
                
                self.statusBarWindow.transform = CGAffineTransform.identity
                self.statusBarWindow.layoutIfNeeded()
                
                if self.tabbarController != nil && self.isTabBarScrollable {
                    self.updateTabbar()
                }
                
                if self.navController != nil && self.isTopFloatingSpaceScrollable {
                    self.updateNavBar()
                }
                
                self.viewController?.view.frame = CGRect(x: 0.0,
                                                         y: self.originVCFrame.minY + self.statusBarWindow.frame.minY,
                                                         width: self.originVCFrame.width,
                                                         height: self.originVCHeight)
                self.viewController?.view.layoutIfNeeded()
                
            }, completion: { (_) in
                self.isAnimating = false
                self.tabbarController?.tabBar.isUserInteractionEnabled = true
            })
            
        } else if self.changeRatio >= 0.5 && self.changeRatio != 1.0 && self.scrollView.contentOffset.y > totalTopFloatingHeight {
            
            self.changeRatio = 1.0
            
            UIView.animate(withDuration: 0.15, animations: {
                self.isAnimating = true
                
                self.statusBarWindow.transform = CGAffineTransform(translationX: 0, y: -self.totalTopFloatingHeight)
                self.statusBarWindow.layoutIfNeeded()
                
                if self.tabbarController != nil && self.isTabBarScrollable {
                    self.updateTabbar()
                }
                
                if self.navController != nil && self.isTopFloatingSpaceScrollable {
                    self.updateNavBar()
                }
                
                self.viewController?.view.frame = CGRect(x: 0.0,
                                                         y: self.originVCFrame.minY + self.statusBarWindow.frame.minY,
                                                         width: self.originVCFrame.width,
                                                         height: self.vcMaxHeight)
                
                self.viewController?.view.layoutIfNeeded()
            }, completion: { (_) in
                self.isAnimating = false
                self.tabbarController?.tabBar.isUserInteractionEnabled = true
            })
            
        } else if self.scrollView.contentOffset.y <= totalTopFloatingHeight {
            
            self.changeRatio = 0.0
            
            UIView.animate(withDuration: 0.15, animations: {
                self.isAnimating = true
                
                self.statusBarWindow.transform = CGAffineTransform.identity
                self.statusBarWindow.layoutIfNeeded()
                
                if self.tabbarController != nil && self.isTabBarScrollable {
                    self.updateTabbar()
                }
                
                if self.navController != nil && self.isTopFloatingSpaceScrollable {
                    self.updateNavBar()
                }
                
                self.viewController?.view.frame = CGRect(x: 0.0,
                                                         y: self.originVCFrame.minY + self.statusBarWindow.frame.minY,
                                                         width: self.originVCFrame.width,
                                                         height: self.originVCHeight)
                self.viewController?.view.layoutIfNeeded()
                
            }, completion: { (_) in
                self.isAnimating = false
                self.tabbarController?.tabBar.isUserInteractionEnabled = true
            })
        } else if self.changeRatio == 0.0 {
            self.tabbarController?.tabBar.isUserInteractionEnabled = true
            return
        }
    }
    
    public func restoreToOrigin() {
        
        if statusBarWindow.frame.minY == 0.0 {
            return
        }
        
        self.statusBarWindow.transform = CGAffineTransform(translationX: 0, y: 0)
        self.statusBarWindow.layoutIfNeeded()
        
        self.changeRatio = 0.0
        if self.tabbarController != nil && self.isTabBarScrollable {
            self.updateTabbar()
        }
        
        if self.navController != nil && self.isTopFloatingSpaceScrollable {
            self.updateNavBar()
        }
        
        self.viewController?.view.frame = CGRect(x: 0.0,
                                                 y: self.originVCFrame.minY + self.statusBarWindow.frame.minY,
                                                 width: self.originVCFrame.width,
                                                 height: self.originVCHeight)
        self.viewController?.view.layoutIfNeeded()
    }
    
    func updateStatusBarWith(distance: CGFloat) {
        
        let statusBarNextYPosition = statusBarWindow.frame.minY - distance * scrollHideSpeed
        
        
        var statusBarNewYPosition: CGFloat = 0.0
        if state == .scrolling(.scrollDown) {
            // if statusBarNextYPosition less than -floatingViewHeight, set statusBarNewYPosition to -floatingViewHeight
            statusBarNewYPosition = statusBarNextYPosition <= -totalTopFloatingHeight ? -totalTopFloatingHeight: statusBarNextYPosition
        } else {
            // if statusBar.frame.y > 0, adjust it to zero
            statusBarNewYPosition = statusBarNextYPosition >= 0 ? 0: statusBarNextYPosition
        }
        // change statusBar y position
        self.statusBarWindow.transform = CGAffineTransform(translationX: 0, y: statusBarNewYPosition)
        self.statusBarWindow.layoutIfNeeded()
        self.changeRatio = statusBarWindow.frame.minY / -(totalTopFloatingHeight)
    }
    
    func updateTabbar() {
        
        guard let tabbarController = self.tabbarController else { return }
        
        let tabbarNewHeight = windowHeight + self.tabbarHeight * self.changeRatio
        var tabbarFrame = tabbarController.view.frame
        tabbarFrame.size = CGSize(width: tabbarFrame.size.width,
                                  height: tabbarNewHeight)
        tabbarController.view.frame = tabbarFrame
        tabbarController.view.layoutIfNeeded()
    }
    
    func updateNavBar() {
        
        guard let navController = self.navController else { return }
        
        var navFrame = navController.navigationBar.frame

        navFrame.origin = CGPoint(x: navFrame.origin.x ,
                                  y: self.statusBarWindow.frame.minY + self.statusBarHeight)
        navController.navigationBar.frame = navFrame
        navController.navigationBar.layoutIfNeeded()
    }
    
    func updateVCFrameWith(distance: CGFloat) {
        
        guard let viewController = self.viewController else { return }
        
        let vcNextHeight = viewController.view.frame.height +
            distance * scrollHideSpeed
        
        var vcNewHeight: CGFloat = 0.0
        
        if state == .scrolling(.scrollDown) {
            vcNewHeight = vcNextHeight >= vcMaxHeight ? vcMaxHeight: vcNextHeight
        } else {
            vcNewHeight = vcNextHeight <= self.originVCHeight ? self.originVCHeight: vcNextHeight
        }
        
        viewController.view.frame = CGRect(x: 0.0,
                                           y: self.originVCFrame.minY + statusBarWindow.frame.minY,
                                           width: viewController.view.frame.width,
                                           height: vcNewHeight)
        viewController.view.layoutIfNeeded()
    }
    
    deinit {
        print("MSScrollControll gone")
    }
    
}

extension MSScrollControl {
    
    func configureMSScrollControl(parameters: [MSScrollControlParameter]) {
        
        for parameter in parameters {
            switch (parameter) {
            case .delayDistance(let value):
                self.delayDistance = value
            case .isStatusBarScrollable(let value):
                self.isStatusBarScrollable = value
            case .isTabBarScrollable(let value):
                self.isTabBarScrollable = value
            case .isTopFloatingSpaceScrollable(let value):
                self.isTopFloatingSpaceScrollable = value
            case .scrollHideSpeed(let value):
                self.scrollHideSpeed = value
            case .topFloatingHeight(let value):
                self.topFloatingHeight = value
            }
        }
    }
    
    private func transformFormFrame(_ origin: CGRect, to next: CGRect) -> CGAffineTransform {
        var transform = CGAffineTransform(translationX: next.midX - origin.midX,
                                          y: next.minY - origin.minY)
        transform = transform.scaledBy(x: next.width/origin.width,
                                       y: next.height/origin.height)
        return transform
    }
}
