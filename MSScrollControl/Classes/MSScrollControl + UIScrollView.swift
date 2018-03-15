//
//  MSScrollControl + UIScrollView.swift
//  LuluVideo
//
//  Created by Mason on 2018/1/30.
//  Copyright © 2018年 appimc.com. All rights reserved.
//

import Foundation
import UIKit

extension UIScrollView {
    
    private struct MS_AssociatedKeys {
        static var msScrollControl: MSScrollControl?
    }
    
    public var msScrollControl: MSScrollControl? {
        get {
            return objc_getAssociatedObject(self, &MS_AssociatedKeys.msScrollControl) as? MSScrollControl
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self,
                                         &MS_AssociatedKeys.msScrollControl,
                                         newValue as MSScrollControl?,
                                         objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
                self.updateScrollControl()
            }
        }
    }
    
    fileprivate func updateScrollControl() {
        guard let msScrollControl = self.msScrollControl else { return }
        msScrollControl.scrollView = self
    }
}

