//
//  StormNotificationHelper.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 24/08/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation
import ThunderBasics
import ThunderRequest
import CoreLocation

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
		if let appId = UserDefaults.standard.string(forKey: "TSCAppId") ?? API_APPID {
			body["appId"] = appId
		}
		
		if let _deviceId = UIDevice.current.identifierForVendor?.uuidString {
			body["deviceId"] = _deviceId
		}
		
		// If we're geotargeted, then let's resend the push token every time
		let tokenHasChanged = defaults.string(forKey: "TSCPushToken") != token
		guard tokenHasChanged || geoTargeted else { return }
		
		if geoTargeted {
			
			// Let's pull the user's location
            SingleRequestLocationManager.shared.requestCurrentLocation(authorization: .whenInUse, accuracy: kCLLocationAccuracyHundredMeters) { (location, _) in
				
				// If we get location then register for pushes with CMS
				if let location = location {
					
					body["location"] = [
						"type": "Point",
						"coordinates": [
							location.coordinate.longitude,
							location.coordinate.latitude
						]
					]
					self.registerForPushes(with: body)
					
				// If we don't, only register if token has changed
				} else if tokenHasChanged {
					
					self.registerForPushes(with: body)
				}
				
			}
			
		} else {
			
			// Only sent if token changed since last time it was registered
			self.registerForPushes(with: body)
		}
	}
	
	private class func registerForPushes(with payload: [AnyHashable : Any]) {
		
		let defaults = UserDefaults.standard
		
		guard let baseURL = Bundle.main.infoDictionary?["TSCBaseURL"] as? String else { return }
		guard let apiVersion = Bundle.main.infoDictionary?["TSCAPIVersion"] as? String else { return }
        guard let stormBaseURL = URL(string: "\(baseURL)/\(apiVersion)") else {
            return
        }
		
        let requestController = RequestController(baseURL: stormBaseURL)
		
        requestController.request("push/token", method: .POST, body: JSONRequestBody(payload)) { (response, error) in
            guard error == nil else { return }
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
