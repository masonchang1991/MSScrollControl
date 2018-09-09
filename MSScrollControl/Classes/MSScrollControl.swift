//
//  MSScrollControl.swift
//  LuluVideo
//
//  Created by Mason on 2018/1/30.
//  Copyright © 2018年 appimc.com. All rights reserved.
//

import Foundation
import UIKit

public class MSScrollControl: NSObject {
    
    public enum UpdateType {
        case transform
        case changeFrame
    }
    
    unowned var scrollView: UIScrollView = UIScrollView()
    
    // object
    private weak var viewController: UIViewController?
    private weak var tabbarController: UITabBarController?
    private weak var navController: UINavigationController?
    private(set) var statusBarView: UIView!
    
    // origin value
    private var originVCFrame: CGRect = .zero
    private var originNavBarFrame: CGRect = .zero
    private var originNavCFrame: CGRect = .zero
    private var originTabCFrame: CGRect = .zero
    private var originTabbarFrame: CGRect = .zero
    private var originStatusBarViewFrame: CGRect = .zero
    private var topMaxVariation: CGFloat = 0.0
    private(set) var statusBarHeight: CGFloat = 0.0
    private(set) var tabbarHeight: CGFloat = 0.0
    private(set) var navbarHeight: CGFloat = 0.0
    
    // variation value
    private var lastOffset = CGPoint(x: 0.0, y: 0.0)
    private var topVariation: CGFloat = 0.0
    private var bottomVariation: CGFloat = 0.0
    fileprivate var isFirstScroll: Bool = true
    private var isAnimating: Bool = false
    
    // Parameters
    open var updateType: UpdateType = .changeFrame
    fileprivate var delayDistance: CGFloat = 0.0
    fileprivate var scrollHideSpeed: CGFloat = 1.0
    fileprivate var topFloatingHeight: CGFloat = 0
//    fileprivate var isStatusBarScrollable = true
    fileprivate var isTabBarScrollable = false
    fileprivate var isTopFloatingSpaceScrollable = true
    fileprivate var autoHideAndShowAfterScroll = true
    fileprivate var autoHideAndShowAfterScrollAnimationTime: TimeInterval = 0.3
    
    // observer
    internal var currentState: ((MSScrollControlState) -> (Void))?
    
    // queue
    private let updateQueue = DispatchQueue(label: "MSScrollControll.update",
                                            qos: DispatchQoS.userInteractive)
    
    private(set) var state: MSScrollControlState = .initial {
        didSet {
            if state != oldValue {
                currentState?(state)
            }
        }
    }
    
    private(set) var changeRatio: CGFloat = 0.0 {
        didSet {
            if changeRatio == 0.0 {
                self.tabbarController?.tabBar.isUserInteractionEnabled = isTabBarScrollable ? true: false
                self.state = .collapsed
            } else if changeRatio == 1.0 {
                self.tabbarController?.tabBar.isUserInteractionEnabled = isTabBarScrollable ? false: true
                self.state = .collapsed
            } else {
                // avoid tap tabbar when user is scrolling (and isTabbarScrollable is true)
                self.tabbarController?.tabBar.isUserInteractionEnabled = isTabBarScrollable ? false: true
            }
        }
    }
    
    public init(viewController: UIViewController, tabbarController: UITabBarController?) {
        super.init()
        self.viewController = viewController
        self.tabbarController = tabbarController
        if let tabbarController = tabbarController {
            self.tabbarHeight = tabbarController.tabBar.frame.height
        }
        setupInitData()
    }
    
    public init(viewController: UIViewController, tabbarController: UITabBarController?, parameters: [MSScrollControlParameter]) {
        super.init()
        self.viewController = viewController
        self.tabbarController = tabbarController
        if let tabbarController = tabbarController {
            self.tabbarHeight = tabbarController.tabBar.frame.height
        }
        self.configureMSScrollControl(parameters: parameters)
        setupInitData()
    }
    
    public init(viewController: UIViewController, tabbarController: UITabBarController?, navController: UINavigationController?, parameters: [MSScrollControlParameter]) {
        super.init()
        self.viewController = viewController
        self.tabbarController = tabbarController
        if let tabbarController = tabbarController {
            self.tabbarHeight = tabbarController.tabBar.frame.height
        }
        self.navController = navController
        if let navController = navController {
            self.navbarHeight = navController.navigationBar.frame.height
        }
        self.configureMSScrollControl(parameters: parameters)
        setupInitData()
    }
    
    private func setupInitData() {
        guard
            let statusBarWindow = UIApplication.shared.value(forKey: "statusBarWindow") as? UIWindow,
            let statusBarView = statusBarWindow.value(forKey: "statusBar") as? UIView else { return }
        self.statusBarView = statusBarView
        self.originStatusBarViewFrame = statusBarView.frame
        self.statusBarHeight = statusBarView.bounds.height
        self.topMaxVariation = statusBarHeight +
            (isTopFloatingSpaceScrollable ? (topFloatingHeight + navbarHeight): 0.0)
    }
    
    private func storeOriginData() {
        if let vc = viewController {
            self.originVCFrame = vc.view.frame
        }
        if let nav = navController {
            self.originNavCFrame = nav.view.frame
            self.originNavBarFrame = nav.navigationBar.frame
        }
        if let tabbar = tabbarController {
            self.originTabCFrame = tabbar.view.frame
            self.originTabbarFrame = tabbar.tabBar.frame
        }
    }
    
    private func isOnDelayRange(scrollView: UIScrollView) -> Bool {
        let contentOffset = scrollView.contentOffset
        if contentOffset.y <= delayDistance {
            return true
        } else {
            return false
        }
    }
    
    private func isOutOfBound(scrollView: UIScrollView) -> Bool {
        let contentOffset = scrollView.contentOffset
        let contentSize = scrollView.contentSize
        let scrollViewHeight = scrollView.bounds.height
        let scrollViewWidth = scrollView.bounds.width
        
        if contentOffset.x < 0 || contentOffset.y < 0 {
            return true
        } else if contentOffset.x + scrollViewWidth > contentSize.width {
            return true
        } else if contentOffset.y + scrollViewHeight > contentSize.height {
            return true
        } else {
            return false
        }
    }
    
    private func adjustVCByUpdateType() {
        switch updateType {
        case .transform: break
        case .changeFrame: break
        }
    }
    
    open func barUpdate() {
        
        if isAnimating { return }
        if isOutOfBound(scrollView: scrollView) {
//            restoreToOrigin()
            return
        }
        
        if isFirstScroll {
            storeOriginData()
            isFirstScroll = false
            adjustVCByUpdateType()
        }
        
        // Calculate scroll distance
        let currentOffset = scrollView.contentOffset
        let distance =  currentOffset.y - lastOffset.y
        self.lastOffset = currentOffset

        let isScrollDown = distance > 0
        if isOnDelayRange(scrollView: scrollView) && isScrollDown { return }
        
        if isScrollDown {
            self.state = .scrolling(.scrollDown)
        } else {
            self.state = .scrolling(.scrollUp)
        }
        
        if Thread.isMainThread {
            self.updateStatusBarWith(distance: distance)
            
            if self.isTabBarScrollable {
                self.updateTabbar()
            }
            
            if self.isTopFloatingSpaceScrollable {
                self.updateNavBar()
            }
            
            self.updateVCFrameWith()
        } else {
            DispatchQueue.main.async {
                self.updateStatusBarWith(distance: distance)
                
                if self.isTabBarScrollable {
                    self.updateTabbar()
                }
                
                if self.isTopFloatingSpaceScrollable {
                    self.updateNavBar()
                }
                
                self.updateVCFrameWith()
            }
        }

        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(barEndUpdate),
                     with: self,
                     afterDelay: 0.1)
    }
    
    @objc private func barEndUpdate() {

        if isAnimating || !autoHideAndShowAfterScroll {
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            return
        }
        
        if changeRatio < 0.5 {
            //MARK: - make changeRatio to 0.0
            UIView.transition(with: scrollView, duration: autoHideAndShowAfterScrollAnimationTime, options: [.curveEaseIn], animations: {
                self.isAnimating = true
                self.updateStatusBarWith(changeRatio: 0.0)
                if self.isTabBarScrollable {
                    self.updateTabbar()
                }
                
                if self.isTopFloatingSpaceScrollable {
                    self.updateNavBar()
                }
                self.updateVCFrameWith()
            }) { (_) in
                self.isAnimating = false
                self.tabbarController?.tabBar.isUserInteractionEnabled = true
                self.state = .collapsed
                NSObject.cancelPreviousPerformRequests(withTarget: self)
            }
            
        } else if changeRatio >= 0.5 {
            //MARK: - make changeRatio to 1.0
            UIView.transition(with: scrollView, duration: autoHideAndShowAfterScrollAnimationTime, options: [.curveEaseIn], animations: {
                self.isAnimating = true
                self.updateStatusBarWith(changeRatio: 1.0)
                
                if self.isTabBarScrollable {
                    self.updateTabbar()
                }
                
                if self.isTopFloatingSpaceScrollable {
                    self.updateNavBar()
                }
                self.updateVCFrameWith()
            }) { (_) in
                self.isAnimating = false
                self.tabbarController?.tabBar.isUserInteractionEnabled = false
                self.state = .expanded
                NSObject.cancelPreviousPerformRequests(withTarget: self)
            }
        } else {
            NSObject.cancelPreviousPerformRequests(withTarget: self)
        }
    }
    
    open func restoreToOrigin() {
    
        if topVariation == 0.0 { return }
        
        updateStatusBarWith(changeRatio: 0.0)
        if isTabBarScrollable {
            updateTabbar()
        }
        if isTopFloatingSpaceScrollable {
            updateNavBar()
        }
        updateVCFrameWith()
    }
    
    private func updateStatusBarWith(changeRatio: CGFloat) {
        topVariation = -topMaxVariation * changeRatio
        self.changeRatio = changeRatio
        if changeRatio != 0.0 {
            switch updateType {
            case .transform:
                statusBarView.transform = CGAffineTransform(translationX: 0, y: topVariation)
            case .changeFrame:
                var updateSBFrame = originStatusBarViewFrame
                updateSBFrame.origin = CGPoint(x: originStatusBarViewFrame.minX,
                                               y: topVariation)
                statusBarView.frame = updateSBFrame
            }
        } else {
            switch updateType {
            case .transform:
                statusBarView.transform = CGAffineTransform.identity
            case .changeFrame:
                statusBarView.frame = originStatusBarViewFrame
            }
        }
    }
    
    private func updateStatusBarWith(distance: CGFloat) {
        topVariation = topVariation - distance * scrollHideSpeed
        if state == .scrolling(.scrollDown) {
            // if statusBarNextYPosition less than -floatingViewHeight, set statusBarNewYPosition to -floatingViewHeight
            topVariation = topVariation <= -topMaxVariation ? -topMaxVariation: topVariation
        } else {
            // if statusBar.frame.y > 0, adjust it to zero
            topVariation = topVariation >= 0 ? 0: topVariation
        }
        // change statusBar y position
        changeRatio = topVariation / -(topMaxVariation)
        switch updateType {
        case .transform:
            statusBarView.transform = CGAffineTransform(translationX: 0, y: topVariation)
        case .changeFrame:
            var updateSBFrame = originStatusBarViewFrame
            updateSBFrame.origin = CGPoint(x: originStatusBarViewFrame.minX,
                                           y: topVariation)
            statusBarView.frame = updateSBFrame
        }
    }
    
    private func updateTabbar() {
        if let tabbarController = self.tabbarController {
            bottomVariation = tabbarHeight * changeRatio
            if changeRatio != 0.0 {
                switch updateType {
                case .transform:
                    tabbarController.tabBar.transform = CGAffineTransform(translationX: 0.0,
                                                                          y: bottomVariation)
                case .changeFrame:
                    //MARK: - You should never attempt to manipulate the UITabBar object itself stored in this property.
//                    let tabbarCNewHeight = originTabCFrame.height + bottomVariation
//                    let tabbarFrame = CGRect(origin: CGPoint(x: originTabCFrame.minX,
//                                                             y: originTabCFrame.minY),
//                                             size: CGSize(width: originTabCFrame.width,
//                                                          height: tabbarCNewHeight))
//                    tabbarController.view.frame = tabbarFrame
                    let updateTabbarFrame = CGRect(origin: CGPoint(x: originTabbarFrame.minX,
                                                                   y: originTabbarFrame.minY + bottomVariation),
                                                   size: originTabbarFrame.size)
                    tabbarController.tabBar.frame = updateTabbarFrame
                }
            } else {
                switch updateType {
                case .transform:
                    tabbarController.tabBar.transform = CGAffineTransform.identity
                case .changeFrame:
                    tabbarController.tabBar.frame = originTabbarFrame
                }
            }
        }
    }
    
    private func updateNavBar() {
        if let navController = self.navController {
            if changeRatio != 0.0 {
                switch updateType {
                case .transform:
                    navController.navigationBar.transform = CGAffineTransform(translationX: 0.0,
                                                                              y: topVariation)
                case .changeFrame:
                    //MARK: - can't directly change navigationBar frame, so change navigationController frame
                    let updateNavBarFrame = CGRect(x: originNavBarFrame.minX,
                                                   y: originNavBarFrame.minY + topVariation,
                                                   width: originNavBarFrame.width,
                                                   height: originNavBarFrame.height)
                    navController.navigationBar.frame = updateNavBarFrame
                    
                }
            } else {
                switch updateType {
                case .transform:
                    navController.navigationBar.transform = CGAffineTransform.identity
                    
                case .changeFrame:
                    //MARK: - can't directly change navigationBar frame, so change navigationController frame
                    navController.navigationBar.frame = originNavBarFrame
//                    navController.view.frame = originNavCFrame
                }
            }
        }
    }
    
    func updateVCFrameWith(distance: CGFloat = 0.0) {
        if let vc = self.viewController {
            if changeRatio != 0.0 {
                let vcNextHeight = originVCFrame.height + (-topVariation) + bottomVariation
                
                let vcNextMinY = originVCFrame.minY + topVariation
                let vcNewFrame = CGRect(x: originVCFrame.minX,
                                        y: vcNextMinY,
                                        width: originVCFrame.width,
                                        height: vcNextHeight)
                switch updateType {
                case .transform:
                    let newTransform = transformFormFrame(originVCFrame, to: vcNewFrame)
                    vc.view.transform = newTransform
                case .changeFrame:
                    vc.view.frame = vcNewFrame
                }
            } else {
                switch updateType {
                case .transform:
                    vc.view.transform = CGAffineTransform.identity
                case.changeFrame:
                    vc.view.frame = originVCFrame
                }
            }
        }
    }
    
    deinit {
        print(classForCoder, "dealloc")
    }
}

extension MSScrollControl {
    
    open func configureMSScrollControl(parameters: [MSScrollControlParameter]) {
        
        if !isFirstScroll {
            restoreToOrigin()
        }
        self.isFirstScroll = true
        
        for parameter in parameters {
            switch (parameter) {
            case .scrollType(let value):
                self.updateType = value
            case .isStatusBarScrollable(let value):
//                self.isStatusBarScrollable = value
                //TODO: - add this func
                break
            case .isTabBarScrollable(let value):
                self.isTabBarScrollable = value
            case .isTopFloatingSpaceScrollable(let value):
                self.isTopFloatingSpaceScrollable = value
            case .scrollHideSpeed(let value):
                self.scrollHideSpeed = value
            case .topFloatingHeight(let value):
                self.topFloatingHeight = value
            case .delayDistance(let value):
                self.delayDistance = value
            case .autoHideAndShowAfterScroll(let value):
                self.autoHideAndShowAfterScroll = value
            case .autoHideAndShowAfterScrollAnimationTime(let value):
                self.autoHideAndShowAfterScrollAnimationTime = value
            }
        }
    }
    
    func transformFormFrame(_ origin: CGRect, to next: CGRect) -> CGAffineTransform {
        var transform = CGAffineTransform(translationX: next.midX - origin.midX,
                                          y: next.minY - origin.minY)
        transform = transform.scaledBy(x: next.width/origin.width,
                                       y: next.height/origin.height)
        return transform
    }
}

