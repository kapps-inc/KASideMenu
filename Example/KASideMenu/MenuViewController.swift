//
//  MenuViewController.swift
//  KASideMenu_Example
//
//  Created by ZhihuaZhang on 2018/09/13.
//  Copyright (c) 2018 Kapps Inc. All rights reserved.
//

import UIKit

class MenuViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

extension MenuViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sideMenu?.closeMenu()
    }
}
