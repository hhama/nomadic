//
//  MyTabBarController.swift
//  nomadic
//
//  Created by 濱田 一 on 2017/11/19.
//  Copyright © 2017年 濱田 一. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 背景色
        UITabBar.appearance().barTintColor = UIColor(red: 190/255, green: 194/255, blue: 63/255, alpha: 1.0) // grey black
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
