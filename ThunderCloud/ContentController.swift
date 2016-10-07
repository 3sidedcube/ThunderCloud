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

public typealias ContentUpdateProgressHandler = (_ stage: UpdateStage, _ downloadSpeed: Float, _ amountDownloaded: Int, _ totalToDownload: Int, _ error: Error?) -> (Void)

/// An enum representing the stage of the current update process
public enum UpdateStage : String {
    /// We are checking for available updates
    case checking
    /// The bundle is being downloaded
    case downloading
    /// The bundle is being unpacked
    case unpacking
    /// The bundle is being verified
    case verifying
    /// The bundle is being copied into place
    case copying
    /// Cleaning up temporary files and such
    case cleaning
    /// Finished updating
    case finished
}

//// `TSCContentController` is a core piece in ThunderCloud that handles delta updates, loading page data and implements the language controller for Storm.
public class ContentController: NSObject {
    
    /// The shared instance responsible for serving pages and content throughout a storm app
    public static let shared = ContentController()
    
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
    
    private var progressHandlers: [ContentUpdateProgressHandler] = []
    
    private var latestBundleTimestamp: TimeInterval {
        
        guard let manifestPath = path(forResource: "manifest", withExtension: "json", inDirectory: nil) else { return 0 }
        
        do {
            let data = try Data(contentsOf: manifestPath)
            guard let manifest = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable : Any] else { return 0 }
            if let timeStamp = manifest["timestamp"] as? TimeInterval {
                return timeStamp
            } else {
                return 0
            }
        } catch {
            return 0
        }
    }
    
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
    
    private override init() {
        
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
        
        super.init()
        
        checkForAppUpgrade()
        checkForUpdates()
    }
    
    //MARK: -
    //MARK: Checking for updates
    
    ///A boolean indicating whether or not the content controller is currently in the process of checking for an update
    public var checkingForUpdates: Bool = false
    
    public func checkForUpdates() {
        
        checkForUpdates(withProgressHandler: nil)
    }
    
    /// Asks the content controller to check with the Storm server for updates
    ///
    /// The timestamp used to check will be taken from the bundle or delta bundle inside of the app
    public func checkForUpdates(withProgressHandler: ContentUpdateProgressHandler?) {
        
        checkForUpdates(withTimestamp:latestBundleTimestamp, progressHandler: withProgressHandler)
    }
    
    /// Asks the content controller to check with the Storm server for updates
    ///
    /// Use this method if you need to request the bundle for a specific timestamp
    ///
    /// - parameter withTimestamp: The timestamp to send to the server as the current bundle version
    public func checkForUpdates(withTimestamp: TimeInterval, progressHandler: ContentUpdateProgressHandler? = nil) {
        
        checkingForUpdates = true
        print("<ThunderStorm> [Updates] Checking for updates with timestamp: \(withTimestamp)")
        
        var environment = "live"
        if DeveloperModeController.appIsInDevMode {
            environment = "test"
        }
        
        // Hit API to check if any updates after this timestamp
        requestController?.get("?timestamp=\(withTimestamp)&density=\(UIScreen.main.scale > 1 ? "x2" : "x1")&environment=\(environment)", completion: { [weak self] (response, error) in
            
            if let welf = self {
                welf.checkingForUpdates = false
            }
            
            // If we get back an error then fail
            if let error = error {
                
                if let responseStatus = response?.status {
                    print("<ThunderStorm> [Updates] Checking for updates failed (\(responseStatus)): \(error.localizedDescription)")
                } else {
                    print("<ThunderStorm> [Updates] Checking for updates failed: \(error.localizedDescription)")
                }
                
                progressHandler?(.checking, 0, 0, 0, error)
                
            } else if let response = response {
                 // If we get a response, first check status then proceed
                
                // If not modified or no content, then fail the update
                if response.status == TSCResponseStatus.noContent.rawValue || response.status == TSCResponseStatus.notModified.rawValue {
                    
                    print("<ThunderStorm> [Updates] No update found")
                    progressHandler?(.checking, 0, 0, 0, ContentControllerError.noNewContentAvailable)
                    return
                }
                
                // If we get a dictionary as response then download from the provided path
                if let responseDictionary = response.dictionary {
                    
                    // If we get a filepath then download it!
                    guard let filePath = responseDictionary["file"] as? String else {
                        
                        print("<ThunderStorm> [Updates] No bundle download url provided")
                        progressHandler?(.checking, 0, 0, 0, ContentControllerError.noUrlProvided)
                        return
                    }
                    
                    self?.downloadUpdatePackage(fromURL: filePath, progressHandler: progressHandler)
                    
                } else if let data = response.data { // Unpack the bundle as it's already been downloaded
                    
                    if let url = response.httpResponse?.url?.absoluteString {
                        print("<ThunderStorm> [Updates] Downloading update bundle: \(url)")
                    } else {
                        print("<ThunderStorm> [Updates] Downloading update bundle")
                    }
                    
                    if let progressHandler = progressHandler {
                        self?.progressHandlers.append(progressHandler)
                    }
                    
                    self?.saveBundleData(data: data)
                    
                } else { // Otherwise the response was invalid
                    
                    print("<ThunderStorm> [Updates] Received an invalid response from update endpoint")
                    progressHandler?(.checking, 0, 0, 0, ContentControllerError.invalidResponse)
                }
                
            } else {
                
                print("<ThunderStorm> [Updates] No response received from update endpoint")
                progressHandler?(.checking, 0, 0, 0, ContentControllerError.noResponseReceived)
            }
        })
    }
    
    private func saveBundleData(data: Data) {
        
        // Make sure we have a cache directory and url
        guard let cacheDirectory = cacheDirectory, let cacheURL = URL(string: cacheDirectory.appending("/data.tar.gz")) else {
            
            print("<ThunderStorm> [Updates] No cache directory found")
            
            progressHandlers.forEach({ (progressHandler) in
                progressHandler(.unpacking, 0, 0, 0, ContentControllerError.noCacheDirectory)
            })
            
            return
        }
        
        // Write the data to cache url
        do {
            
            try data.write(to: cacheURL, options: .atomic)
            
            
            guard let temporaryUpdateDirectory = temporaryUpdateDirectory else {
                
                print("<ThunderStorm> [Updates] No temp update directory found")
                
                progressHandlers.forEach({ (progressHandler) in
                    progressHandler(.unpacking, 0, 0, 0, ContentControllerError.noTempDirectory)
                })
                
                return
            }
            
            // Unpack the bundle
            self.unpackBundle(inDirectory: cacheDirectory, toDirectory: temporaryUpdateDirectory)
            
        } catch let error {
            
            print("<ThunderStorm> [Updates] Failed to write update bundle to disk")
            progressHandlers.forEach({ (progressHandler) in
                progressHandler(.unpacking, 0, 0, 0, error)
            })
        }
    }
    
    /// Downloads a storm bundle from a specific url
    ///
    /// - parameter fromURL: The url to download the bundle from
    /// - parameter progressHandler: A closure which will be alerted of the progress of the download
    public func downloadUpdatePackage(fromURL: String, progressHandler: ContentUpdateProgressHandler?) {
    
        if let progressHandler = progressHandler {
            progressHandlers.append(progressHandler)
        }
        
        if DeveloperModeController.appIsInDevMode, let authToken = UserDefaults.standard.string(forKey: "TSCAuthenticationToken") {
            downloadRequestController.sharedRequestHeaders["TSCAuthenticationToken"] = authToken
        }
        
        downloadRequestController.downloadFile(withPath: fromURL, progress: { [weak self] (progress, totalBytes, bytesTransferred) in
            
            print("Downloaded \(bytesTransferred)/\(totalBytes)")
            
            self?.progressHandlers.forEach({ (handler) in
                handler(.downloading, 0, bytesTransferred, totalBytes, nil)
            })
            
        }) { [weak self] (url, error) in
                
            if let error = error {
                
                print("<ThunderStorm> [Updates] Downloading update bundle failed \(error.localizedDescription)")
                
                self?.progressHandlers.forEach({ (handler) in
                    handler(.downloading, 0, 0, 0, error)
                })
                return
            }
            
            guard let url = url else {
                
                print("<ThunderStorm> [Updates] No bundle data returned")
                self?.progressHandlers.forEach({ (handler) in
                    handler(.downloading, 0, 0, 0, ContentControllerError.invalidResponse)
                })
                return
            }
            
            if let data = try? Data(contentsOf: url) {
                
                self?.saveBundleData(data: data)
                
            } else {
                self?.progressHandlers.forEach({ (handler) in
                    handler(.downloading, 0, 0, 0, ContentControllerError.invalidResponse)
                })
            }
        }
    }
    
    //MARK: -
    //MARK: Update Unpacking
    
    private func unpackBundle(inDirectory: String, toDirectory: String) {
        
        print("<ThunderStorm> [Updates] Unpacking bundle...")
        
        self.progressHandlers.forEach { (handler) in
            handler(.unpacking, 0, 0, 0, nil)
        }
        
        // ERROR: This needs implementation
    }
    
    //MARK: -
    //MARK: - App Settings & Helpers
    
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
    
    public func updateSettingsBundle() {
        
        if let cacheManifest = cacheDirectory?.appending("/manifest.json"), let cacheManifestURL = URL(string: cacheManifest) {
            
            do {
                let data = try Data.init(contentsOf: cacheManifestURL)
                guard let manifest = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable : Any] else {
                    
                    UserDefaults.standard.set("Unknown", forKey: "delta_timestamp")
                    throw ContentControllerError.defaultError
                }
                
                guard let timeStamp = manifest["timestamp"] as? TimeInterval else {
                    
                    UserDefaults.standard.set("Unknown", forKey: "delta_timestamp")
                    throw ContentControllerError.defaultError
                }
                
                UserDefaults.standard.set("\(timeStamp)", forKey: "delta_timestamp")
                
            } catch {
                
                UserDefaults.standard.set("Unknown", forKey: "delta_timestamp")
                print("Error updating delta timestamp in settings")
            }
        }
        
        if let bundleManifest = bundleDirectory?.appending("/manifest.json"), let bundleManifestURL = URL(string: bundleManifest) {
            
            do {
                
                let data = try Data.init(contentsOf: bundleManifestURL)
                
                guard let manifest = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable : Any] else {
                    throw ContentControllerError.defaultError
                }
                
                guard let timeStamp = manifest["timestamp"] as? TimeInterval else {
                    throw ContentControllerError.defaultError
                }
                
                UserDefaults.standard.set("\(timeStamp)", forKey: "bundle_timestamp")
                
            } catch {
                
                print("Error updating bundle timestamp in settings")
            }
        }
    }
    
    
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
    public func url(forCacheURL: URL?) -> URL? {
        
        guard let forCacheURL = forCacheURL else { return nil }
        
        let lastPathComponent = forCacheURL.lastPathComponent
        let pathExtension = forCacheURL.pathExtension
        
        let fileName = lastPathComponent.replacingOccurrences(of: ".\(pathExtension)", with: "")

        return self.path(forResource: fileName, withExtension: pathExtension, inDirectory: forCacheURL.host)
    }
    
    /// Returns all the storm files available in a specific directory of the bundle
    ///
    /// - parameter inDirectory: The directory to look for files in
    ///
    /// - returns: An array of file names
    public func files(inDirectory: String) -> [String]? {
        
        var files: [String] = []
        
        if let bundleDirectory = bundleDirectory {
            
            let filePath = bundleDirectory.appending("/\(inDirectory)")
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: filePath)
                files.append(contentsOf: contents)
            } catch let error {
                print("error getting files in bundle directory \(error.localizedDescription)")
            }
        }
        
        if let cacheDirectory = cacheDirectory {
            
            let filePath = cacheDirectory.appending("/\(inDirectory)")
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: filePath)
                files.append(contentsOf: contents)
            } catch let error {
                print("error getting files in bundle directory \(error.localizedDescription)")
            }
        }
        
        return files.count > 0 ? files : nil
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
    public func metadataForPage(withId: String) -> [AnyHashable : Any]? {
        
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
    public func metadataForPage(withName: String) -> [AnyHashable : Any]? {
        
        guard let map = appDictionary?["map"] as? [[AnyHashable : Any]] else { return nil }
        
        return map.first { (page) -> Bool in
            
            guard let name = page["name"] as? String else { return false }
            return name == withName
        }
    }
}

public typealias CoreSpotlightCompletion = (_ error: Error?) -> (Void)

// MARK: - Indexing content
public extension ContentController {
    
    /// This method can be called to re-index the application in CoreSpotlight
    ///
    /// - parameter completion: A closure which will be called when the indexing has completed
    public func indexAppContent(withCompletion: CoreSpotlightCompletion) {
        
        // ERROR: This needs implementation
    }
}

enum ContentControllerError: Error {
    case noNewContentAvailable
    case noResponseReceived
    case invalidResponse
    case noUrlProvided
    case noCacheDirectory
    case noTempDirectory
    case defaultError
}
