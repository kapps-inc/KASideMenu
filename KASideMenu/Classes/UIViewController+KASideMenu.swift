//
//  UIViewController+KASideMenu.swift
//  KASideMenu
//
//  Created by ZhihuaZhang on 09/12/2018.
//  Copyright (c) 2018 Kapps Inc. All rights reserved.
//

import UIKit

extension UIViewController {
    public var sideMenu: KASideMenu? {
        var parent = self.parent
        
        while parent != nil {
            if parent is KASideMenu {
                return parent as? KASideMenu
            } else {
                parent = parent?.parent
            }
        }
        
        return nil
    }
}

