//
//  StreamingNavigationController.swift
//  ThunderCloud
//
//  Created by Ryan Bourne on 17/09/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import Foundation
import UIKit

/// An override of UINavigationController, that is used whenever we present a Streaming Page within the app.
/// We can check if the presentedViewController is a StreamingNavigationController at run time and if it is, we know that there's a streaming page presented.
/// We can then switch to present web views within this navigation controller.
public class StreamingNavigationController: UINavigationController {
    
}
