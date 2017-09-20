//
//  Analytics.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 03/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

public extension NotificationCenter {
	
	public func sendStatEventNotification(category: String, action: String, label: String?, value: AnyObject?, object: Any?) {
		
		var info: [AnyHashable : Any] = [
			"type": "event",
			"category": category,
			"action": action
		]
		
		if let value = value {
			info["value"] = value
		}
		
		if let label = label {
			info["label"] = label
		}
		
		NotificationCenter.default.post(
			name: .analyticsEvent,
			object: object,
			userInfo: info
		)
	}
	
	public func sendScreenViewNotification(screenName: String, object: Any?) {
		
		let info: [AnyHashable : Any] = [
			"type": "screen",
			"name": screenName
		]
		
		NotificationCenter.default.post(
			name: .analyticsEvent,
			object: object,
			userInfo: info
		)
	}
}

public extension NSNotification.Name {
	static let analyticsEvent = NSNotification.Name.init("TSCStatEventNotification")
}
