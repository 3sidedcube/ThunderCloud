//
//  StormNotificationHelper.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 24/08/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation
import ThunderRequest

/// StormNotificationHelper is a class that aids registering of push notifications with the Storm CMS
public class StormNotificationHelper {
	
	/// Registers the user's push token to the storm servers so that the system can send notifications to the device
	///
	/// Call this method in the `application:didRegisterForRemoteNotifications` method of your App Delegate
	///
	/// - Parameters:
	///   - data: The data representing the user's push token
	///   - geoTargeted: Whether the user's location should be sent with the push token for geo-targeted push notifications
	public class func registerPushToken(with data: Data, geoTargeted: Bool = false) {
		
		let defaults = UserDefaults.standard
		let token = StormNotificationHelper.string(forPushTokenData: data)
		
		var body: [AnyHashable : Any] = [
			"token": token,
			"idiom": "ios"
		]
		if let appId = Bundle.main.infoDictionary?["TSCAppId"] as? String {
			body["appId"] = appId
		} else if let appIdInt = Bundle.main.infoDictionary?["TSCAppId"] as? Int {
			body["appId"] = "\(appIdInt)"
		}
		
		// If we're geotargeted, then let's resend the push token every time
		let tokenHasChanged = defaults.string(forKey: "TSCPushToken") != token
		guard tokenHasChanged || geoTargeted else { return }
		
		if geoTargeted {
			
			// Let's pull the user's location
			TSCSingleRequestLocationManager.shared().requestCurrentLocation(with: .whenInUse, completion: { (location, error) in
				
				// If we get location then register for pushes with CMS
				if let _location = location {
					
					body["location"] = [
						"type": "Point",
						"coordinates": [
							_location.coordinate.longitude,
							_location.coordinate.latitude
						]
					]
					self.registerForPushes(with: body)
					
				// If we don't, only register if token has changed
				} else if tokenHasChanged {
					
					self.registerForPushes(with: body)
				}
				
			})
			
		} else {
			
			// Only sent if token changed since last time it was registered
			self.registerForPushes(with: body)
		}
	}
	
	private class func registerForPushes(with payload: [AnyHashable : Any]) {
		
		let defaults = UserDefaults.standard
		
		guard let baseURL = Bundle.main.infoDictionary?["TSCBaseURL"] as? String else { return }
		guard let apiVersion = Bundle.main.infoDictionary?["TSCAPIVersion"] as? String else { return }
		let stormBaseURL = "\(baseURL)/\(apiVersion)"
		
		let requestController = TSCRequestController(baseAddress: stormBaseURL)
		
		requestController.post("push/token", bodyParams: payload) { (response, error) in
			
			if error != nil {
				return
			}
			
			defaults.set(payload["token"], forKey: "TSCPushToken")
		}
	}
	
	/// A string representation of push notification data
	///
	/// - Parameter pushTokenData: The data representing a push token
	/// - Returns: The user's push token as a string
	public class func string(forPushTokenData data: Data) -> String {
		
		let tokenParts = data.map { data -> String in
			return String(format: "%02.2hhx", data)
		}
		return tokenParts.joined()
	}
}
