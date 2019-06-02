//
//  UITabBarController.swift
//  Thanks
//
//  Created by 岩男高史 on 2019/03/16.
//  Copyright © 2019 岩男高史. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
      //tabbarの線を消す処理
      tabBar.backgroundImage = UIImage()
      tabBar.shadowImage = UIImage()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
