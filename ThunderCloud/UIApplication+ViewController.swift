//
//  UIApplication+ViewController.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 12/12/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import UIKit
import ThunderBasics

extension UIApplication {
    
    class var visibleViewController: UIViewController? {
        return UIApplication.shared.keyWindow?.visibleViewController
    }
}
