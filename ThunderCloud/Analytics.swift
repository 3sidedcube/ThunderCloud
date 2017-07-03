//
//  Analytics.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 03/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

extension NotificationCenter {
	
	func sendStatEventNotification(category: String, action: String, value: AnyObject?, object: Any?) {
		
		var info: [AnyHashable : Any] = [
			"type": "event",
			"category": category,
			"action": action
		]
		
		if let _value = value {
			info["value"] = _value
		}
		
		NotificationCenter.default.post(
			name: NSNotification.Name.init("TSCStatEventNotification"),
			object: object,
			userInfo: info
		)
	}
	
	func sendScreenViewNotification(screenName: String, object: Any?) {
		
		let info: [AnyHashable : Any] = [
			"type": "screen",
			"name": screenName
		]
		
		NotificationCenter.default.post(
			name: NSNotification.Name.init("TSCStatEventNotification"),
			object: object,
			userInfo: info
		)
	}
}
