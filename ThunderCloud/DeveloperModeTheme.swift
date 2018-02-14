//
//  DeveloperModeTheme.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 07/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// This theme is applied when the app switches to Dev mode, turning the app a vibrant green colour
@objc(TSCDeveloperModeTheme)
class DeveloperModeTheme: Theme {
	
	override init() {
		
		super.init()
		mainColor = UIColor(red: 138/255.0, green: 207/255, blue: 25/255, alpha: 1)
		titleTextColor = .white
	}
}
