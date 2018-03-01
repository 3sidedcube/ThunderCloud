//
//  AuthenticationController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 15/02/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation
import ThunderRequest

/// The Authentication Controller is responsible for authenticating with the
/// Storm CMS API. Any endpoint that requires an authorisation token can use
/// this controller to obtain a token.
public class AuthenticationController {
	
	/// A structual representation of the user's authentication
	public struct Authorization: Decodable, Encodable {
		
		/// The authorization token
		let token: String
		
		/// The expiry date of the Authorization
		let expiry: Date
		
		/// Whether the user is currently authenticated
		var hasExpired: Bool {
			return expiry < Date()
		}
	}
	
	/// A typealias for an authentication completion
	public typealias AuthenticationCompletion = (_ authorization: Authorization?, _ error: Error?) -> Void
	
	private let requestController: TSCRequestController
	
	public init() {
		
		requestController = TSCRequestController(baseAddress: "https://auth.cubeapis.com/v1.6")
	}
	
	public func authenticateWith(username: String, password: String, completion: AuthenticationCompletion?) {
		
		requestController.post("authentication", bodyParams: ["username": username, "password": password]) { (response, error) in
			
			guard error == nil else {
				completion?(nil, error)
				return
			}
			
			guard let responseDict = response?.dictionary else {
				completion?(nil, AuthenticationControllerError.invalidResponse)
				return
			}
			
			guard let token = responseDict["token"] as? String, let expiryTimeStamp = (responseDict["expires"] as? [AnyHashable : Any])?["timeout"] as? TimeInterval else {
				completion?(nil, AuthenticationControllerError.invalidResponse)
				return
			}
			
			let authorisation = Authorization(token: token, expiry: Date(timeIntervalSince1970: expiryTimeStamp))
			
			if let data = try? JSONEncoder().encode(authorisation) {
				UserDefaults.standard.set(data, forKey: "TSCStormAuthentication")
			}
			
			completion?(authorisation, nil)
		}
	}
	
	public var authentication: Authorization? {
		
		// Fallback for legacy authorization
		if let token = UserDefaults.standard.string(forKey: "TSCAuthenticationToken"), let expiry = UserDefaults.standard.object(forKey: "TSCAuthenticationTimeout") as? TimeInterval {
			return Authorization(token: token, expiry: Date(timeIntervalSince1970: expiry))
		}
		
		guard let data = UserDefaults.standard.data(forKey: "TSCStormAuthentication") else { return nil }
		guard let authorization = try? JSONDecoder().decode(AuthenticationController.Authorization.self, from: data) else { return nil }
		
		return authorization
	}
}

public enum AuthenticationControllerError: Error {
	case invalidResponse
}
