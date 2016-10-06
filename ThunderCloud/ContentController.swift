//
//  ContentController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 06/10/2016.
//  Copyright © 2016 threesidedcube. All rights reserved.
//

import Foundation
import ThunderRequest

let API_VERSION: String? = Bundle.main.infoDictionary["TSCAPIVersion"] as? String
let API_BASEURL: String? = Bundle.main.infoDictionary["TSCBaseURL"] as? String
let API_APPID: String? = Bundle.main.infoDictionary["TSCAppId"] as? String
let BUILD_DATE: Int? = Bundle.main.infoDictionary["TSCBuildDate"] as? Int
let GOOGLE_TRACKING_ID: String? = Bundle.main.infoDictionary["TSCGoogleTrackingId"] as? String
let STORM_TRACKING_ID: String? = Bundle.main.infoDictionary["TSCTrackingId"] as? String
let DEVELOPER_MODE = UserDefaults.standard.bool(forKey: "developer_mode_enabled")

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
    
    /// A dictionary detailing the contents of the app bundle
    public var appDictionary: String?
    
    /// A shared request controller for making requests throughout the content controller
    let requestController: TSCRequestController?
    
    /// A request controller responsible for handling file downloads. It does not have a base URL set
    let downloadRequestController: TSCRequestController

    ///The shared language controller used to access localisations throughout the app
    let languageController: TSCStormLanguageController

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

        if let excPath = Bundle.main.executablePath, let excAttributes = try fm.attributesOfItem(atPath: excPath), let creationDate = excAttributes[NSFileCreationDate] as? Date {
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .medium
            dateFormatter.dateStyle = .long
            
            UserDefaults.standard.set(dateFormatter.string(from: creationDate), forKey: "build_date")
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
//        self.requestController = [[TSCRequestController alloc] initWithBaseURL:self.baseURL];
//        self.downloadRequestController = [[TSCRequestController alloc] initWithBaseAddress:nil];
        
        //Identify folders for bundle
        cacheDirectory = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).last
        bundleDirectory = Bundle.main.path(forResource: "Bundle", ofType: "")
        
        //Create application support directory
        if let cacheDirectory = cacheDirectory {
            
            do {
                FileManager.default.createDirectory(atPath: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print("<ThunderStorm> [CRITICAL ERROR] Failed to create cache directory at \(cacheDirectory)")
            }
        }
        
        //Temporary cache folder for updates
        temporaryUpdateDirectory = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first?.appending("/updateCache")

        if let tempDirectory = temporaryUpdateDirectory, !FileManager.default.fileExists(atPath: tempDirectory) {
            do {
                try FileManager.default.createDirectory(atPath: tempDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print("<ThunderStorm> [CRITICAL ERROR] Failed to create temporary update directory at \(tempDirectory)")
            }
        }

        languageController = TSCStormLanguageController.sharedController()
        
        checkForAppUpgrade()
        checkForUpdates()
    }
    
    private func checkForAppUpgrade() {
        
        // App versioning
        let currentVersion = Bundle.main.infoDictionary["CFBundleShortVersionString"]
        let previousVersion = UserDefaults.standard.string(forKey: "TSCLastVersionNumber")
        
        if let current = currentVersion, let previous = previousVersion, current != previous {
            
            print("<ThunderStorm> [Upgrades] Upgrade in progress...")
            cleanoutCache()
        }
        
        UserDefaults.standard.set(currentVersion, forKey: "TSCLastVersionNumber")
    }
    
    private func cleanoutCache() {
        
        let fm = FileManager.default
        
        guard let cacheDirectory = cacheDirectory else {
            
            print("<ThunderStorm> [Upgrades] Didn't clear cache because directory not present")
            return
        }
        
        ["app.json", "manifest.json", "pages", "content", "languages", "data"].forEach { (file) in
            
            do {
                try fm.removeItem(atPath: cacheDirectory.appending(file))
            } catch let error {
                print("<ThunderStorm> [Upgrades] Failed to remove \(file) in cache directory")
            }
        }
        
        // Mark the app as needing to re-index on next launch
        UserDefaults.standard.set(false, forKey: "TSCIndexedInitialBundle")
    }
    
    ///---------------------------------------------------------------------------------------
    /// @name Loading pages and page information
    ///---------------------------------------------------------------------------------------
    
//    /**
//     @abstract Requests a page dictionary for a given path
//     @param pageURL A NSURL of the page to be loaded
//     */
//    - (NSDictionary * _Nullable)pageDictionaryWithURL:(NSURL * _Nonnull)pageURL;
//    
//    /**
//     @abstract Requests metadata information for a storm page
//     @param pageId The unique identifier of the page to lookup in the bundle
//     */
//    - (NSDictionary * _Nullable)metadataForPageId:(NSString * _Nonnull)pageId;
//    
//    /**
//     @abstract Requests metadata information for a storm page
//     @param pageName The page name of the page to lookup in the bundle
//     */
//    - (NSDictionary * _Nullable)metadataForPageName:(NSString * _Nonnull)pageName;
//    
//    ///---------------------------------------------------------------------------------------
//    /// @name Looking up file paths
//    ///---------------------------------------------------------------------------------------
//    
//    /**
//     @abstract Returns the url of a file in the storm bundle
//     @param name The name of the file, excluding it's file extension
//     @param extension The file extension to look up
//     @param directory A specific directory inside of the storm bundle to lookup
//     */
//    - (NSString * _Nullable)pathForResource:(NSString * _Nonnull)name ofType:(NSString * _Nonnull)extension inDirectory:(NSString * _Nullable)directory;
//    
//    /**
//     @abstract Returns a file path from a storm cache link
//     @param url The storm cache URL to convert
//     */
//    - (NSString * _Nullable)pathForCacheURL:(NSURL * _Nonnull)url;
//    
//    /**
//     @abstract Used for looking up files in the Storm bundle directory
//     @param directory The name of the directory to look source the file list from
//     @return An NSArray of file names for files in the given directory
//     */
//    - (NSArray * _Nullable)filesInDirectory:(NSString * _Nonnull)directory;
//    
//    /**
//     @abstract Cleans out the cache directory of files, causing the controller to fall back to the main bundle
//     */
//    - (void)TSC_cleanoutCache;
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
