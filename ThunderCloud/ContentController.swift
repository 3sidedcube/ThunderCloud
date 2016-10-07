//
//  ContentController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 06/10/2016.
//  Copyright © 2016 threesidedcube. All rights reserved.
//

import Foundation
import ThunderRequest

let API_VERSION: String? = Bundle.main.infoDictionary?["TSCAPIVersion"] as? String
let API_BASEURL: String? = Bundle.main.infoDictionary?["TSCBaseURL"] as? String
let API_APPID: String? = Bundle.main.infoDictionary?["TSCAppId"] as? String
let BUILD_DATE: Int? = Bundle.main.infoDictionary?["TSCBuildDate"] as? Int
let GOOGLE_TRACKING_ID: String? = Bundle.main.infoDictionary?["TSCGoogleTrackingId"] as? String
let STORM_TRACKING_ID: String? = Bundle.main.infoDictionary?["TSCTrackingId"] as? String
let DEVELOPER_MODE = UserDefaults.standard.bool(forKey: "developer_mode_enabled")

/// A delegate for receiving callbacks from the content controller
public protocol ContentControllerDelegate {
    
    
}

//// `TSCContentController` is a core piece in ThunderCloud that handles delta updates, loading page data and implements the language controller for Storm.
open class ContentController {
    
    /// The shared instance responsible for serving pages and content throughout a storm app
    static let shared = ContentController()
    
    /// The path for the bundle directory bundled with the app at compile time
    public let bundleDirectory: String?
    
    /// The path for the directory containing files from any delta updates applied after the app has been launched
    public let cacheDirectory: String?
    
    /// The path for the directory that is used for temporary storage when unpacking delta updates
    public let temporaryUpdateDirectory: String?
    
    /// The base URL for the app. Typically the address of the storm server
    public var baseURL: URL?
    
    /// A shared request controller for making requests throughout the content controller
    let requestController: TSCRequestController?
    
    /// A request controller responsible for handling file downloads. It does not have a base URL set
    let downloadRequestController: TSCRequestController

    /// The shared language controller used to access localisations throughout the app
    let languageController: TSCStormLanguageController
    
    /// A dictionary detailing the contents of the app bundle
    var appDictionary: [AnyHashable : Any]? {
        
        guard let appPath = path(forResource: "app", withExtension: "json", inDirectory: nil) else { return nil }
        
        do {
            let data = try Data(contentsOf: appPath)
            return try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable : Any]
        } catch {
            return nil
        }
    }

    ///---------------------------------------------------------------------------------------
    /// @name Checking for updates
    ///---------------------------------------------------------------------------------------
    
    /// Asks the content controller to check with the Storm server for updates
    ///
    /// The timestamp used to check will be taken from the bundle or delta bundle inside of the app
    public func checkForUpdates() {
        
    }
    
    /// Asks the content controller to check with the Storm server for updates
    ///
    /// Use this method if you need to request the bundle for a specific timestamp
    ///
    /// - parameter withTimestamp: The timestamp to send to the server as the current bundle version
    public func checkForUpdates(withTimestamp: TimeInterval) {
        
    }
    
    ///A boolean indicating whether or not the content controller is currently in the process of checking for an update
    var checkingForUpdates: Bool = false
    
    private init() {
        
        if API_BASEURL == nil {
            print("<ThunderStorm> [CRITICAL ERROR] TSCBaseURL not defined in info plist")
        }
        
        if API_APPID == nil {
            print("<ThunderStorm> [CRITICAL ERROR] TSCAppId not defined info plist")
        }
        
        if API_VERSION == nil {
            print("<ThunderStorm> [CRITICAL ERROR] TSCAPIVersion not defined info plist")
        } else if let apiVersion = API_VERSION, apiVersion == "latest" {
            print("<ThunderStorm> [CRITICAL ERROR] TSCAPIVersion is defined as \"Latest\". Please change to correct version before submission")
        } else {
            UserDefaults.standard.set(API_VERSION, forKey: "update_api_version")
        }
        
        //BUILD DATE
        let fm = FileManager.default

        if let excPath = Bundle.main.executablePath {
            
            do {
                if let creationDate = try fm.attributesOfItem(atPath: excPath)[FileAttributeKey.creationDate] as? Date {
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeStyle = .medium
                    dateFormatter.dateStyle = .long
                    
                    UserDefaults.standard.set(dateFormatter.string(from: creationDate), forKey: "build_date")
                }
            } catch {
                print("<ThunderStorm> [ERROR] Couldn't find initial build date")
            }
        }

        //END BUILD DATE
        
        if GOOGLE_TRACKING_ID == nil {
            print("<ThunderStorm> [CRITICAL ERROR] TSCGoogleTrackingId not defined info plist");
        }
        
        if STORM_TRACKING_ID == nil {
            print("<ThunderStorm> [CRITICAL ERROR] TSCTrackingId not defined info plist");
        }
        
        if let baseString = API_BASEURL, let version = API_VERSION, let appId = API_APPID {
            baseURL = URL(string: "\(baseString)/\(version)/apps/\(appId)/update")
        }
        
        //Setup request kit
        requestController = TSCRequestController(baseURL: baseURL)
        downloadRequestController = TSCRequestController(baseURL: nil)
        
        //Identify folders for bundle
        cacheDirectory = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).last
        bundleDirectory = Bundle.main.path(forResource: "Bundle", ofType: "")
        
        //Create application support directory
        if let cacheDirectory = cacheDirectory {
            
            do {
                try FileManager.default.createDirectory(atPath: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("<ThunderStorm> [CRITICAL ERROR] Failed to create cache directory at \(cacheDirectory)")
            }
        }
        
        //Temporary cache folder for updates
        temporaryUpdateDirectory = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first?.appending("/updateCache")

        if let tempDirectory = temporaryUpdateDirectory, !FileManager.default.fileExists(atPath: tempDirectory) {
            do {
                try FileManager.default.createDirectory(atPath: tempDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("<ThunderStorm> [CRITICAL ERROR] Failed to create temporary update directory at \(tempDirectory)")
            }
        }

        languageController = TSCStormLanguageController.shared()
        
        checkForAppUpgrade()
        checkForUpdates()
    }
    
    private func checkForAppUpgrade() {
        
        // App versioning
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let previousVersion = UserDefaults.standard.string(forKey: "TSCLastVersionNumber")
        
        if let current = currentVersion, let previous = previousVersion, current != previous {
            
            print("<ThunderStorm> [Upgrades] Upgrade in progress...")
            cleanoutCache()
        }
        
        UserDefaults.standard.set(currentVersion, forKey: "TSCLastVersionNumber")
    }
    
    public func cleanoutCache() {
        
        let fm = FileManager.default
        
        guard let cacheDirectory = cacheDirectory else {
            
            print("<ThunderStorm> [Upgrades] Didn't clear cache because directory not present")
            return
        }
        
        ["app.json", "manifest.json", "pages", "content", "languages", "data"].forEach { (file) in
            
            do {
                try fm.removeItem(atPath: cacheDirectory.appending(file))
            } catch {
                print("<ThunderStorm> [Upgrades] Failed to remove \(file) in cache directory")
            }
        }
        
        // Mark the app as needing to re-index on next launch
        UserDefaults.standard.set(false, forKey: "TSCIndexedInitialBundle")
    }
    

//    /**
//     @abstract Used for looking up files in the Storm bundle directory
//     @param directory The name of the directory to look source the file list from
//     @return An NSArray of file names for files in the given directory
//     */
//    - (NSArray * _Nullable)filesInDirectory:(NSString * _Nonnull)directory;
//    

//    /**
//     @abstract Starts a downloaad of an update package from the given URL
//     @param url The url of the delta bundle
//     */
//    - (void)downloadUpdatePackageFromURL:(NSString * _Nonnull)url;
//    
//    /**
//     @return The timestamp of the bundle contained in the app
//     */
//    - (NSTimeInterval)originalBundleDate;
//    
//    /**
//     @abstract Updates the details of delta bundle timestamps in the settings bundle
//     */
//    - (void)TSC_updateSettingsBundle;
//    
//    /**
//     @abstract This should be called to re-index the application in CoreSpotlight
//     @param completion A completion block which is called when the indexing has completed
//     */
//    - (void)indexAppContentWithCompletion:(TSCCoreSpotlightCompletion _Nullable)completion;
}

// MARK: - Paths and helper functions
public extension ContentController {
    
    /// Returns the path of a file in the storm bundle
    ///
    /// - parameter forResource:   The name of the file, excluding it's file extension
    /// - parameter withExtension: The file extension to look up
    /// - parameter inDirectory:   A specific directory inside of the storm bundle to lookup (Optional)
    ///
    /// - returns: Returns a path for the resource if it's found
    public func path(forResource: String, withExtension: String, inDirectory: String?) -> URL? {
        
        var bundleFile: String?
        var cacheFile: String?

        if let bundleDirectory = bundleDirectory {
            bundleFile = inDirectory != nil ? "\(bundleDirectory)/\(inDirectory!)/\(forResource).\(withExtension)" : "\(bundleDirectory)/\(forResource).\(withExtension)"
        }
        
        if let cacheDirectory = cacheDirectory {
            cacheFile = inDirectory != nil ? "\(cacheDirectory)/\(inDirectory!)/\(forResource).\(withExtension)" : "\(cacheDirectory)/\(forResource).\(withExtension)"
        }
        
        if let _cacheFile = cacheFile, FileManager.default.fileExists(atPath: _cacheFile) {
            return URL(fileURLWithPath: _cacheFile)
        } else if let _bundleFile = bundleFile, FileManager.default.fileExists(atPath: _bundleFile) {
            return URL(fileURLWithPath: _bundleFile)
        }

        return nil
    }
    
    /// Returns a file path from a storm cache link
    ///
    /// - parameter forCacheURL: The storm cache URL to convert
    ///
    /// - returns: Returns an optional path if the file exists at the cache link
    public func url(forCacheURL: URL) -> URL? {
        
        let lastPathComponent = forCacheURL.lastPathComponent
        let pathExtension = forCacheURL.pathExtension
        
        let fileName = lastPathComponent.replacingOccurrences(of: ".\(pathExtension)", with: "")

        return self.path(forResource: fileName, withExtension: pathExtension, inDirectory: forCacheURL.host)
    }
}

// MARK: - Loading pages and page information
public extension ContentController {
    
    /// Requests a page dictionary for a given path
    ///
    /// - parameter withURL: A URL of the page to be loaded
    ///
    /// - returns: A dictionary of the page for a certain page
    public func pageDictionary(withURL: URL) -> [AnyHashable : Any]? {
        
        guard let fileURL = url(forCacheURL: withURL) else { return nil }
        
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable : Any]
        } catch {
            return nil
        }
    }
    
    /// Requests metadata information for a storm page
    ///
    /// - parameter withId: The unique identifier of the page to lookup in the bundle
    ///
    /// - returns: A dictionary of the metadata for a certain page
    public func metadataForPageId(withId: String) -> [AnyHashable : Any]? {
        
        guard let map = appDictionary?["map"] as? [[AnyHashable : Any]] else { return nil }

        return map.first { (page) -> Bool in
            
            guard let identifier = page["id"] as? String else { return false }
            return identifier == withId
        }
    }
    
    /// Requests metadata information for a storm page
    ///
    /// - parameter withName: The page name of the page to lookup in the bundle
    ///
    /// - returns: A dictionary of the metadata for a certain page
    public func metadataForPageName(withName: String) -> [AnyHashable : Any]? {
        
        guard let map = appDictionary?["map"] as? [[AnyHashable : Any]] else { return nil }
        
        return map.first { (page) -> Bool in
            
            guard let name = page["name"] as? String else { return false }
            return name == withName
        }
    }
}
