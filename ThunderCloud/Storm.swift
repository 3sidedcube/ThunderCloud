//
//  Storm.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 03/05/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import Foundation

/// A caseless enum for typespacing of storm constants
public enum Storm {
    
    /// A caseless enum for typespacing of storm API constants
    public enum API {
        /// The current API version as defined in the Info.plist under `TSCAPIVersion`
        public static let Version: String? = Bundle.main.infoDictionary?["TSCAPIVersion"] as? String
        /// The API's base url as defined in the Info.plist under `TSCBaseURL`
        public static let BaseURL: String? = (Bundle.main.infoDictionary?["TSCBaseURL"] as? String)?.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        
        /// The App ID in the API as defined in the Info.plist under `TSCAppId`
        public static let AppID: String? = Bundle.main.infoDictionary?["TSCAppId"] as? String
    }
    
    /// A caseless enum for typespacing of storm Build constants
    public enum Build {
        /// The timestamp that the build was made at
        public static let Timestamp: Int? = Bundle.main.infoDictionary?["TSCBuildDate"] as? Int
    }
    
    /// A caseless enum for typespacing of storm Tracking constants
    public enum Tracking {
        /// Google analytics ID
        public static let GoogleAnalytics = Bundle.main.infoDictionary?["TSCGoogleTrackingId"] as? String
        
        /// Storm tracking ID
        public static let ID: String? = Bundle.main.infoDictionary?["TSCTrackingId"] as? String
    }
    
    /// A user agent to be used with any requests which may need to be identified with a storm CMS
    static var UserAgent: String {
        
        var userAgent = ""
        
        if let stormId = Storm.Tracking.ID {
            let components = stormId.components(separatedBy: "-"
            )
            if components.count > 1 {
                userAgent = components.first! + components.last!
            } else {
                userAgent = (Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String)?.replacingOccurrences(of: " ", with: "") ?? ""
            }
        } else {
            userAgent = (Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String)?.replacingOccurrences(of: " ", with: "") ?? ""
        }
        
        if let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            userAgent.append("/\(bundleVersion)")
        }
        
        let device = UIDevice.current.model
        if device.lowercased() == "ipad" {
            userAgent.append(" (\(device); CPU OS ")
        } else {
            userAgent.append(" (\(device); CPU \(device) OS ")
        }
        
        let vComponents = UIDevice.current.systemVersion.components(separatedBy: ".")
        vComponents.enumerated().forEach { (index, component) in
            userAgent.append(component)
            if index != vComponents.count - 1 {
                userAgent.append("_")
            } else {
                userAgent.append(" like Mac OS X")
            }
        }
        
        return userAgent
    }
}
