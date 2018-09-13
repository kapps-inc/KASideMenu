//
//  MySideMenu.swift
//  KASideMenu_Example
//
//  Created by ZhihuaZhang on 2018/09/12.
//  Copyright (c) 2018 Kapps Inc. All rights reserved.
//

import UIKit
import KASideMenu

class MySideMenu: KASideMenu {
    override func awakeFromNib() {
        config.leftPadding = 100
        config.thresholdPercentage = 1 / 3
        
        leftMenuViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LeftMenuViewController")
        rightMenuViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RightMenuViewController")
        centerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CenterViewController")
        
        super.awakeFromNib()
    }
}
