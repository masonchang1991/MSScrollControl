//
//  MSScrollControlOption.swift
//  LuluVideo
//
//  Created by Mason on 2018/1/30.
//  Copyright © 2018年 appimc.com. All rights reserved.
//

import Foundation

public enum MSScrollControlParameter {
    case scrollType(MSScrollControl.UpdateType)
    case scrollHideSpeed(CGFloat)
    case topFloatingHeight(CGFloat)
    //MARK: - this version isStatusBarScrollable is useless
    case isStatusBarScrollable(Bool)
    case isTabBarScrollable(Bool)
    case isTopFloatingSpaceScrollable(Bool)
    case delayDistance(CGFloat)
    case autoHideAndShowAfterScroll(Bool)
    case autoHideAndShowAfterScrollAnimationTime(TimeInterval)
}
