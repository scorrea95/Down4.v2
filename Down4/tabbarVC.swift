//
//  tabbarVC.swift
//  Down4
//
//  Created by amrun on 02/06/17.
//  Copyright © 2017 Digital Hole. All rights reserved.
//

import UIKit

class tabbarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        UITabBar.appearance().tintColor = UIColor(red:0.56, green:0.07, blue:1.00, alpha:1.0)
        if #available(iOS 10.0, *) {
            UITabBar.appearance().unselectedItemTintColor = UIColor.lightGray
        } else {
            // Fallback on earlier versions
        }
        UITabBar.appearance().barTintColor = UIColor.white
    }
}
