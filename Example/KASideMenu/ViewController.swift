//
//  ViewController.swift
//  KASideMenu
//
//  Created by ZhihuaZhang on 09/12/2018.
//  Copyright (c) 2018 Kapps Inc. All rights reserved.
//

import UIKit
import KASideMenu

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func leftMenuBtnTapped(_ sender: Any) {
        sideMenu?.openLeft()
    }
    
    @IBAction func rightMenuBtnTapped(_ sender: Any) {
        sideMenu?.openRight()
    }
    
}

