//
//  MSScrollControlState.swift
//  MSScrollControlDemo
//
//  Created by Mason on 2018/3/15.
//  Copyright © 2018年 Mason. All rights reserved.
//

import Foundation

enum MSScrollControlState {
    
    enum ScrollDirection: Equatable {
        case scrollUp
        case scrollDown
    }
    
    case initial
    case collapsed
    case expanded
    case scrolling(ScrollDirection)
    case animating
    
    public static func ==(lhs: MSScrollControlState, rhs: MSScrollControlState) -> Bool {
        switch (lhs, rhs) {
        case let (.scrolling(a), .scrolling(b)):
            return a == b
        case (.initial, .initial):
            return true
        case (.collapsed, .collapsed):
            return true
        case (.expanded, .expanded):
            return true
        case (.animating, .animating):
            return true
        default:
            return false
        }
    }
    
    public static func !=(lhs: MSScrollControlState, rhs: MSScrollControlState) -> Bool {
        return !(lhs == rhs)
    }
}

