//
//  ProtraitNavigationController.swift
//  MathPix
//
//  Created by Sergey Glushchenko on 6/17/16.
//  Copyright © 2016 MathPix. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {
    
    override var shouldAutorotate : Bool {
        if let vc = topViewController {
            return vc.shouldAutorotate
        }
        return false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if let vc = topViewController {
            return vc.supportedInterfaceOrientations
        }
        
        return UIInterfaceOrientationMask.portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}




