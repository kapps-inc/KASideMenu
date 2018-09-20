//
//  UIViewController+KASideMenu.swift
//  KASideMenu
//
//  Created by ZhihuaZhang on 09/12/2018.
//  Copyright (c) 2018 Kapps Inc. All rights reserved.
//

import UIKit

extension UIViewController {
    public var sideMenuController: KASideMenuController? {
        var parent = self.parent
        
        while parent != nil {
            if parent is KASideMenuController {
                return parent as? KASideMenuController
            } else {
                parent = parent?.parent
            }
        }
        
        return nil
    }
}

