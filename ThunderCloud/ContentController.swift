//
//  ContentController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 06/10/2016.
//  Copyright © 2016 threesidedcube. All rights reserved.
//

import CoreSpotlight
import ThunderRequest
import ThunderBasics
import UIKit
import os

extension String {
    /// Returns a Boolean value indicating whether the string contains any of the given elements.
    /// - Parameter containedStrings: The substrings to check for
    func containsOneOf(_ containedStrings: [String], caseSensitive: Bool = true) -> Bool {
        let caseSensitiveSelf = caseSensitive ? self : lowercased()
        let caseSensitiveContainedStrings = caseSensitive ? containedStrings : containedStrings.map({ $0.lowercased() })
        return caseSensitiveContainedStrings.contains(where: { caseSensitiveSelf.contains($0) })
    }
}

let DOWNLOAD_REQUEST_TAG: Int = "TSCBundleRequestTag".hashValue

// This needs to stay like this, it was a mistake, but without a migration piece just leave it be
let TSCCoreSpotlightStormContentDomainIdentifier = "com.threesidedcube.addressbook"

public typealias ContentUpdateProgressHandler = (_ stage: UpdateStage, _ amountDownloaded: Int, _ totalToDownload: Int, _ error: Error?) -> (Void)

/// An enum representing the stage of the current update process
public enum UpdateStage : String {
    /// We are checking for available updates
    case checking
    /// We are preparing for the download
    case preparing
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
    public var bundleDirectory: URL?
    
    /// The path for the directory containing files from any delta updates applied after the app has been launched
    public var deltaDirectory: URL?
    
    /// The path for the directory that is used for temporary storage when unpacking delta updates
    public let temporaryUpdateDirectory: URL?
    
    /// The base URL for the app. Typically the address of the storm server
    public var baseURL: URL?
    
    /// A shared request controller for making requests throughout the content controller
    var requestController: RequestController?
    
    /// A request controller responsible for handling file downloads. It does not have a base URL set
    var downloadRequestController: RequestController?
    
    /// The log for which all content controller events should be sent
    private var contentControllerLog = OSLog(subsystem: "com.threesidedcube.ThunderCloud", category: "ContentController")
    
    /// Whether or not the app should display feedback to the user about new content activity
    private var showFeedback: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "download_feedback_enabled")
        }
    }
    
    /// Whether content should only be downloaded over wifi
    private var onlyDownloadOverWifi: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "download_content_only_wifi")
        }
    }
    
    private var progressHandlers: [ContentUpdateProgressHandler] = []
    
    private var latestBundleTimestamp: TimeInterval {
        
        guard let manifestPath = fileUrl(forResource: "manifest", withExtension: "json", inDirectory: nil) else { return 0 }
        
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
        
        guard let appPath = fileUrl(forResource: "app", withExtension: "json", inDirectory: nil) else { return nil }
        
        do {
            let data = try Data(contentsOf: appPath)
            return try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable : Any]
        } catch {
            return nil
        }
    }
    
    private override init() {
        
        os_log("Initialising Content Controller", log: contentControllerLog, type: .info)
        
        UserDefaults.standard.set(Storm.API.Version, forKey: "update_api_version")
        
        //BUILD DATE
        let fm = FileManager.default
        
        if let excPath = Bundle.main.executablePath {
            
            do {
                if let creationDate = try fm.attributesOfItem(atPath: excPath)[FileAttributeKey.creationDate] as? Date {
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeStyle = .medium
                    dateFormatter.dateStyle = .long
                    
                    os_log("Setting app build date to %@", log: contentControllerLog, type: . debug, dateFormatter.string(from: creationDate))
                    UserDefaults.standard.set(dateFormatter.string(from: creationDate), forKey: "build_date")
                }
            } catch {
                os_log("Couldn't find initial build date", log: contentControllerLog, type: .error)
            }
        }
        
        //END BUILD DATE
        
        //Identify folders for bundle
        if let _deltaPath = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).last {
            
            let _deltaDirectory = URL(fileURLWithPath: _deltaPath, isDirectory: true).appendingPathComponent("StormDeltaBundle")
            
            deltaDirectory = _deltaDirectory
            
            //Create application support directory
            do {
                try FileManager.default.createDirectory(atPath: _deltaDirectory.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                os_log("Failed to create delta directory at %@", log: contentControllerLog, type: .fault, _deltaDirectory.absoluteString)
            }
        }
        
        if let _embeddedBundlePath = Bundle.main.path(forResource: "Bundle", ofType: "") {
            bundleDirectory = URL(fileURLWithPath: _embeddedBundlePath)
        }
        
        if bundleDirectory == nil {
            
            //Identify folders for bundle
            if let _bundlePath = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).last {
                
                let _bundleDirectory = URL(fileURLWithPath: _bundlePath, isDirectory: true).appendingPathComponent("StormBundle")
                
                bundleDirectory = _bundleDirectory
                
                //Create application support directory
                do {
                    try FileManager.default.createDirectory(atPath: _bundleDirectory.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    os_log("Failed to create bundle directory at %@", log: contentControllerLog, type: .fault, _bundleDirectory.absoluteString)
                }
            }
            
        }
        
        //Temporary cache folder for updates
        temporaryUpdateDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("StormDeltaBundle")
        
        if let tempDirectory = temporaryUpdateDirectory, !FileManager.default.fileExists(atPath: tempDirectory.path) {
            do {
                try FileManager.default.createDirectory(atPath: tempDirectory.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                os_log("Failed to create temporary update directory at  %@", log: contentControllerLog, type: .fault, tempDirectory.absoluteString)
            }
        }
        
        super.init()
        
        if !UserDefaults.standard.bool(forKey: "TSCIndexedInitialBundle") {
            indexAppContent(with: { (error) -> (Void) in
                
                if error == nil {
                    UserDefaults.standard.set(true, forKey: "TSCIndexedInitialBundle")
                }
            })
        }
        
        configureBaseURL()
        checkForAppUpgrade()
        updateSettingsBundle()
        
        defer {
            if fileExistsInBundle(file: "app.json") {
                checkForUpdates()
            }
        }
    }
    
    //MARK: -
    //MARK: Downloading full bundles
    
    func configureBaseURL() {
        
        guard requestController == nil, downloadRequestController == nil else {
            return
        }
        
        let stormAppId = UserDefaults.standard.string(forKey: "TSCAppId") ?? Storm.API.AppID
        
        if let baseString = Storm.API.BaseURL, let version = Storm.API.Version, let appId = stormAppId {
            baseURL = URL(string: "\(baseString)/\(version)/apps/\(appId)/update")
        }
        
        guard let baseURL = baseURL else {
            os_log("Base URL invalid", log: contentControllerLog, type: .error)
            return
        }
        
        requestController = RequestController(baseURL: baseURL)
        downloadRequestController = RequestController(baseURL: baseURL)
        
        os_log("Base URL configured as: %@", log: contentControllerLog, type: .debug, baseURL.absoluteString)
    }
    
    public func downloadFullBundle(with progressHandler: ContentUpdateProgressHandler?) {
        
        //Clear existing bundles first
        if let _currentBundle = bundleDirectory {
            removeBundle(in: _currentBundle)
        }
        
        if let _deltaBundle = deltaDirectory {
            removeBundle(in: _deltaBundle)
        }
        
        if let _tempDirectory = temporaryUpdateDirectory {
            removeBundle(in: _tempDirectory)
        }
        
        configureBaseURL()
        
        let stormAppId = UserDefaults.standard.string(forKey: "TSCAppId") ?? Storm.API.AppID
        
        if let baseString = Storm.API.BaseURL, let version = Storm.API.Version, let appId = stormAppId {
            
            if let _fullBundleURL = URL(string: "\(baseString)/\(version)/apps/\(appId)/bundle"), let _destinationURL = bundleDirectory {
                downloadPackage(fromURL: _fullBundleURL, destinationDirectory: _destinationURL, progressHandler: progressHandler)
            }
        }
        
    }
    
    //MARK: -
    //MARK: Checking for updates
    
    ///A boolean indicating whether or not the content controller is currently in the process of checking for an update
    public var checkingForUpdates: Bool = false
    
    public func checkForUpdates() {
        
        let currentStatus = TSCReachability.forInternetConnection().currentReachabilityStatus()
        if onlyDownloadOverWifi && currentStatus != ReachableViaWiFi {
            
            os_log("Abandoned checking for updates as not connected to WiFi", log: contentControllerLog, type: .debug)
            return
        }
        
        updateSettingsBundle()
        
        if showFeedback {
            
            OperationQueue.main.addOperation {
                ToastNotificationController.shared.displayToastWith(title: "Checking For Content", message: "Checking for new content from the CMS")
            }
        }
        
        checkForUpdates { (stage, downloaded, totalToDownload, error) -> (Void) in
            
            if ContentController.shared.showFeedback {
                
                OperationQueue.main.addOperation {
                    
                    // No new content
                    if let contentControllerError = error as? ContentControllerError, contentControllerError == .noNewContentAvailable {
                        ToastNotificationController.shared.displayToastWith(title: "No New Content", message: "There is no new content available from the CMS")
                    } else if let error = error {
                        ToastNotificationController.shared.displayToastWith(title: "Content Update Failed", message: "Content update failed with error: \(error.localizedDescription)")
                    }
                    
                    if stage == .finished {
                        ToastNotificationController.shared.displayToastWith(title: "New Content Downloaded", message: "The latest content was downloaded sucessfully")
                    }
                }
            }
        }
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
        os_log("Checking for updates with timestamp: %.0f", log: contentControllerLog, type: .debug, withTimestamp)
        
        var environment = "live"
        if DeveloperModeController.appIsInDevMode {
            environment = "test"
            if let authorization = AuthenticationController().authentication {
                requestController?.sharedRequestHeaders["Authorization"] = authorization.token
            }
        }
        
        // Hit API to check if any updates after this timestamp
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "timestamp", value: "\(withTimestamp)"),
            URLQueryItem(name: "density", value: "\(UIScreen.main.scale > 1 ? "x2" : "x1")"),
            URLQueryItem(name: "environment", value: environment)
        ]
        requestController?.request("", method: .GET, queryItems: queryItems) { [weak self] (response, error) in
            
            // If we get back an error then fail
            if let error = error {
                
                if let responseStatus = response?.status {
                    if let contentControllerLog = self?.contentControllerLog {
                        os_log("Checking for updates failed %d: %@", log: contentControllerLog, type: .debug, responseStatus.rawValue, error.localizedDescription)
                    }
                } else {
                    if let contentControllerLog = self?.contentControllerLog {
                        os_log("Checking for updates failed: %@", log: contentControllerLog, type: .debug, error.localizedDescription)
                    }
                }
                
                progressHandler?(.checking, 0, 0, error)
                
            } else if let response = response {
                // If we get a response, first check status then proceed
                
                // If not modified or no content, then fail the update
                if response.status == .noContent || response.status == .notModified {
                    
                    if let contentControllerLog = self?.contentControllerLog {
                        os_log("No update found", log: contentControllerLog, type: .debug)
                    }
                    progressHandler?(.checking, 0, 0, ContentControllerError.noNewContentAvailable)
                    return
                }
                
                // If we get a dictionary as response then download from the provided path
                if let responseDictionary = response.dictionary {
                    
                    // If we get a filepath then download it!
                    guard let filePath = responseDictionary["file"] as? String else {
                        
                        if let contentControllerLog = self?.contentControllerLog {
                            os_log("No bundle download url provided", log: contentControllerLog, type: .error)
                        }
                        progressHandler?(.checking, 0, 0, ContentControllerError.noUrlProvided)
                        return
                    }
                    
                    guard let fileURL = URL(string: filePath) else {
                        if let contentControllerLog = self?.contentControllerLog {
                            os_log("No bundle download url provided", log: contentControllerLog, type: .error)
                        }
                        progressHandler?(.checking, 0, 0, ContentControllerError.invalidUrlProvided)
                        return
                    }
                    
                    if let _destinationURL = self?.deltaDirectory {
                        self?.downloadPackage(fromURL: fileURL, destinationDirectory: _destinationURL, progressHandler: progressHandler)
                    }
                    
                } else if let data = response.data { // Unpack the bundle as it's already been downloaded
                    
                    if let url = response.httpResponse?.url?.absoluteString {
                        if let contentControllerLog = self?.contentControllerLog {
                            os_log("Downloading update bundle: %@", log: contentControllerLog, type: .debug, url)
                        }
                    } else {
                        if let contentControllerLog = self?.contentControllerLog {
                            os_log("Downloading update bundle", log: contentControllerLog, type: .debug)
                        }
                    }
                    
                    if let progressHandler = progressHandler {
                        self?.progressHandlers.append(progressHandler)
                    }
                    
                    if let deltaDirectory = self?.deltaDirectory {
                        self?.saveBundleData(data: data, finalDestination: deltaDirectory)
                    } else {
                        self?.callProgressHandlers(with: .downloading, error: ContentControllerError.noDeltaDirectory)
                    }
                    
                } else { // Otherwise the response was invalid
                    
                    if let contentControllerLog = self?.contentControllerLog {
                        os_log("Received an invalid response from update endpoint", log: contentControllerLog, type: .error)
                    }
                    progressHandler?(.checking, 0, 0, ContentControllerError.invalidResponse)
                }
                
            } else {
                
                if let contentControllerLog = self?.contentControllerLog {
                    os_log("No response received from update endpoint", log: contentControllerLog, type: .error)
                }
                progressHandler?(.checking, 0, 0, ContentControllerError.noResponseReceived)
            }
            
            if let welf = self {
                welf.checkingForUpdates = false
            }
            
        }
    }
    
    private func callProgressHandlers(with stage: UpdateStage, error: Error?, amountDownloaded: Int = 0, totalToDownload: Int = 0) {
        
        progressHandlers.forEach { (handler) in
            handler(stage, amountDownloaded, totalToDownload, error)
        }
        
        if stage == .finished || error != nil {
            checkingForUpdates = false
            progressHandlers = []
        }
    }
    
    /// Saves bundle data to a temporary directory
    ///
    /// - Parameters:
    ///   - data: The raw data downloaded from the storm CMS (This is a tar.gz file)
    ///   - finalDestination: The directory to which the bundle should be unpacked if possible
    private func saveBundleData(data: Data, finalDestination: URL) {
        
        // Make sure we have a cache directory and temp directory and url
        guard let temporaryUpdateDirectory = temporaryUpdateDirectory else {
            
            os_log("No temp update directory found", log: contentControllerLog, type: .fault)
            callProgressHandlers(with: .unpacking, error: ContentControllerError.noDeltaDirectory)
            return
        }
        
        let cacheTarFileURL = temporaryUpdateDirectory.appendingPathComponent("data.tar.gz")
        
        // Write the data to cache url
        do {
            
            try data.write(to: cacheTarFileURL, options: .atomic)
            
            // Unpack the bundle
            self.unpackBundle(from: temporaryUpdateDirectory, into: finalDestination)
            
        } catch let error {
            
            os_log("Failed to write update bundle to disk", log: contentControllerLog, type: .error)
            callProgressHandlers(with: .unpacking, error: error)
        }
    }
    
    /// Downloads a storm bundle from a specific url
    ///
    /// - parameter fromURL: The url to download the bundle from
    /// - parameter progressHandler: A closure which will be alerted of the progress of the download
    public func downloadPackage(fromURL: URL, destinationDirectory: URL, progressHandler: ContentUpdateProgressHandler?) {
        
        os_log("Downloading bundle: %@\nDestination: %@", log: contentControllerLog, type: .debug, fromURL.absoluteString, destinationDirectory.absoluteString)
        
        if let progressHandler = progressHandler {
            progressHandlers.append(progressHandler)
        }
        
        if DeveloperModeController.devModeOn, let authorization = AuthenticationController().authentication {
            downloadRequestController?.sharedRequestHeaders["Authorization"] = authorization.token
        }
        
        downloadRequestController?.sharedRequestHeaders["User-Agent"] = Storm.UserAgent
        
        downloadRequestController?.download(nil, tag: DOWNLOAD_REQUEST_TAG, overrideURL: fromURL, progress: { [weak self] (progress, totalBytes, bytesTransferred) in
            self?.callProgressHandlers(with: .downloading, error: nil, amountDownloaded: Int(bytesTransferred), totalToDownload: Int(totalBytes))
        }) { [weak self] (response, url, error) in
            
            if let error = error {
                if let contentControllerLog = self?.contentControllerLog {
                    os_log("Downloading bundle failed: %@", log: contentControllerLog, type: .error, error.localizedDescription)
                }
                
                self?.callProgressHandlers(with: .downloading, error: error)
                return
            }
            
            guard let url = url else {
                
                if let contentControllerLog = self?.contentControllerLog {
                    os_log("No bundle data returned", log: contentControllerLog, type: .error)
                }
                self?.callProgressHandlers(with: .downloading, error: ContentControllerError.invalidResponse)
                return
            }
            
            if let data = try? Data(contentsOf: url) {
                
                self?.saveBundleData(data: data, finalDestination: destinationDirectory)
                
            } else {
                
                self?.callProgressHandlers(with: .downloading, error: ContentControllerError.invalidResponse)
            }
        }
    }
    
    public func cancelDownloadRequest(with tag: Int? = nil) {
        
        if let tag = tag {
            downloadRequestController?.cancelRequestsWith(tag: tag)
        } else {
            downloadRequestController?.cancelRequestsWith(tag: DOWNLOAD_REQUEST_TAG)
        }
    }
    
    //MARK: -
    //MARK: Update Unpacking
    
    /// Unpacks a downloaded storm bundle into a directory from a specified directory
    ///
    /// - parameter inDirectory: The directory to read bundle data from
    /// - parameter toDirectory: The directory to write the unpacked bundle data
    
    private func unpackBundle(from directory: URL, into destinationDirectory: URL) {
        
        os_log("Unpacking bundle...", log: contentControllerLog, type: .debug)
        
        callProgressHandlers(with: .unpacking, error: nil)
        
        let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
        
        backgroundQueue.async {
            
            let fileUrl = directory.appendingPathComponent("data.tar.gz")
            var data: Data
            
            // Read data from directory
            do {
                data = try Data(contentsOf: fileUrl, options: Data.ReadingOptions.mappedIfSafe)
            } catch let error {
                os_log("Unpacking bundle failed: %@", log: self.contentControllerLog, type: .error, error.localizedDescription)
                self.callProgressHandlers(with: .unpacking, error: ContentControllerError.badFileRead)
                return
            }
            os_log("data.tar.gz read to data object", log: self.contentControllerLog, type: .debug)
            
            let archive = "data.tar"
            let nsData = data as NSData
            
            // Unzip data
            os_log("Attempting to gunzip data from data.tar.gz", log: self.contentControllerLog, type: .debug)
            let gunzipData = gunzip(nsData.bytes, nsData.length)
            os_log("Gunzip successful", log: self.contentControllerLog, type: .debug)
            
            let cDecompressed = Data(bytes: gunzipData.data, count: gunzipData.length)
            
            //Write unzipped data to directory
            let directoryWriteUrl = directory.appendingPathComponent(archive)
            
            do {
                try cDecompressed.write(to:directoryWriteUrl, options: [])
            } catch let error {
                os_log(" Writing unpacked bundle failed: %@", log: self.contentControllerLog, type: .error, error.localizedDescription)
                self.callProgressHandlers(with: .unpacking, error: ContentControllerError.badFileWrite)
                return
            }
            os_log("Bundle tar saved to disk", log: self.contentControllerLog, type: .debug)
            
            // We bridge to Objective-C here as the untar doesn't like switch CString struct
            os_log("Attempting to untar the bundle", log: self.contentControllerLog, type: .debug)
            let arch = fopen((directory.appendingPathComponent(archive).path as NSString).cString(using: String.Encoding.utf8.rawValue), "r")
            
            untar(arch, (directory.path as NSString).cString(using: String.Encoding.utf8.rawValue))
            
            fclose(arch)
            os_log("Untar successful", log: self.contentControllerLog, type: .debug)
            
            // Verify bundle
            let isValid = self.verifyBundle(in: directory)
            
            guard isValid else {
                self.removeCorruptDeltaBundle(in: directory)
                return
            }
            
            let fm = FileManager.default
            do {
                
                // Remove unzip files
                os_log("Cleaning up `data.tar.gz` and `data.tar` files", log: self.contentControllerLog, type: .debug)
                try fm.removeItem(at: directory.appendingPathComponent("data.tar.gz"))
                try fm.removeItem(at: directory.appendingPathComponent("data.tar"))
                
            } catch {
                
                // Copy bundle to destination directory and then clear up the directory it was unpacked in
                self.copyValidBundle(from: directory, to: destinationDirectory)
                self.removeBundle(in: directory)
                return
            }
            
            // Copy bundle to destination directory and then clear up the directory it was unpacked in
            self.copyValidBundle(from: directory, to: destinationDirectory)
            self.removeBundle(in: directory)
        }
    }
    
    
    
    //MARK: -
    //MARK: Verify Unpacked bundle
    private func verifyBundle(in directory: URL) -> Bool {
        
        os_log("Verifying bundle...", log: self.contentControllerLog, type: .debug)
        
        callProgressHandlers(with: .verifying, error: nil)
        
        // Set up file path for manifest
        let temporaryUpdateManifestPathUrl = directory.appendingPathComponent("manifest.json")
        
        var manifestData: Data
        
        // Create data object from manifest
        do {
            manifestData  = try Data(contentsOf: temporaryUpdateManifestPathUrl, options: Data.ReadingOptions.mappedIfSafe)
            
        } catch let error {
            
            callProgressHandlers(with: .verifying, error: ContentControllerError.invalidManifest)
            os_log("Failed to read manifest at path: %@\n Error: %@", log: self.contentControllerLog, type: .error, temporaryUpdateManifestPathUrl.absoluteString, error.localizedDescription)
            return false
        }
        
        var manifestJSON: Any
        
        // Serialize manifest into JSON
        os_log("Loading manifest.json into JSON object", log: self.contentControllerLog, type: .debug)
        do {
            manifestJSON = try JSONSerialization.jsonObject(with: manifestData, options: JSONSerialization.ReadingOptions.mutableContainers)
            
        } catch let error {
            
            callProgressHandlers(with: .verifying, error: ContentControllerError.invalidManifest)
            os_log("Failed to parse JSON into dictionary: %@", log: self.contentControllerLog, type: .error, error.localizedDescription)
            return false
        }
        
        os_log("Loading manifest.json as dictionary", log: self.contentControllerLog, type: .debug)
        guard let manifest = manifestJSON as? [String: Any] else {
            
            os_log("Can't cast manifest as dictionary\n %@", log: self.contentControllerLog, type: .error, ContentControllerError.invalidManifest.localizedDescription)
            
            callProgressHandlers(with: .verifying, error: ContentControllerError.invalidManifest)
            return false
        }
        
        if !self.fileExistsInBundle(file: "app.json") {
            
            os_log("%@", log: self.contentControllerLog, type: .error, ContentControllerError.missingAppJSON.localizedDescription)
            
            callProgressHandlers(with: .verifying, error: ContentControllerError.missingAppJSON)
            return false
        }
        os_log("app.json exists", log: self.contentControllerLog, type: .debug)
        
        if !self.fileExistsInBundle(file: "manifest.json") {
            
            os_log("%@", log: self.contentControllerLog, type: .error, ContentControllerError.missingManifestJSON.localizedDescription)
            
            callProgressHandlers(with: .verifying, error: ContentControllerError.missingManifestJSON)
            return false
        }
        os_log("manifest.json exists", log: self.contentControllerLog, type: .debug)
        
        // Verify pages
        os_log("Verifying pages", log: self.contentControllerLog, type: .debug)
        guard let pages = manifest["pages"] as? [[String: Any]] else {
            
            os_log("%@", log: self.contentControllerLog, type: .error, ContentControllerError.manifestMissingPages.localizedDescription)
            callProgressHandlers(with: .verifying, error: ContentControllerError.manifestMissingPages)
            return false
        }
        
        for page in pages {
            
            guard let source = page["src"] as? String else {
                
                os_log("%@\n%@", log: self.contentControllerLog, type: .error, ContentControllerError.pageWithoutSRC.localizedDescription, page)
                callProgressHandlers(with: .verifying, error: ContentControllerError.pageWithoutSRC)
                return false
            }
            os_log("%@ has a valid 'src'", log: self.contentControllerLog, type: .debug, source)
            
            let pageFile = "pages/\(source)"
            if !self.fileExistsInBundle(file: pageFile) {
                
                os_log("%@\n%@", log: self.contentControllerLog, type: .error, ContentControllerError.missingFile.localizedDescription, page)
                callProgressHandlers(with: .verifying, error: ContentControllerError.missingFile)
                return false
            }
            os_log("%@ exists in the bundle", log: self.contentControllerLog, type: .debug, source)
        }
        
        //Verify languages
        os_log("Verifying languages", log: self.contentControllerLog, type: .debug)
        guard let languages = manifest["languages"] as? [[String: Any]] else {
            
            os_log("%@", log: self.contentControllerLog, type: .error, ContentControllerError.manifestMissingLanguages.localizedDescription)
            callProgressHandlers(with: .verifying, error: ContentControllerError.manifestMissingLanguages)
            return false
        }
        
        for language in languages {
            guard let source = language["src"] as? String else {
                
                os_log("%@\n%@", log: self.contentControllerLog, type: .error, ContentControllerError.languageWithoutSRC.localizedDescription, language)
                callProgressHandlers(with: .verifying, error: ContentControllerError.languageWithoutSRC)
                return false
            }
            os_log("%@ has a valid 'src'", log: self.contentControllerLog, type: .debug, source)
            
            let pageFile = "languages/\(source)"
            if !self.fileExistsInBundle(file: pageFile) {
                
                os_log("%@\n%@", log: self.contentControllerLog, type: .error, ContentControllerError.missingFile.localizedDescription, language)
                callProgressHandlers(with: .verifying, error: ContentControllerError.languageWithoutSRC)
                return false
            }
            os_log("%@ exists in the bundle", log: self.contentControllerLog, type: .debug, source)
        }
        
        //Verify Content
        os_log("Verifying Content", log: self.contentControllerLog, type: .debug)
        guard let contents = manifest["content"] as? [[String: Any]] else {
            
            os_log("%@", log: self.contentControllerLog, type: .error, ContentControllerError.manifestMissingContent.localizedDescription)
            callProgressHandlers(with: .verifying, error: ContentControllerError.manifestMissingContent)
            return false
        }
        
        for content in contents {
            
            guard let source = content["src"] as? String else {
                
                os_log("%@\n%@", log: self.contentControllerLog, type: .error, ContentControllerError.contentWithoutSRC.localizedDescription, content)
                callProgressHandlers(with: .verifying, error: ContentControllerError.contentWithoutSRC)
                return false
            }
            os_log("%@ has a valid 'src'", log: self.contentControllerLog, type: .debug, source)
            
            let pageFile = "content/\(source)"
            if !self.fileExistsInBundle(file: pageFile) {
                
                os_log("%@\n%@", log: self.contentControllerLog, type: .error, ContentControllerError.missingFile.localizedDescription, content)
                callProgressHandlers(with: .verifying, error: ContentControllerError.contentWithoutSRC)
                return false
            }
            os_log("%@ exists in the bundle", log: self.contentControllerLog, type: .debug, source)
        }
        
        os_log("Bundle is valid", log: self.contentControllerLog, type: .debug)
        return true
    }
    
    private func removeCorruptDeltaBundle(in directory: URL) {
        
        let fm = FileManager.default
        
        if let attributes = try? fm.attributesOfItem(atPath: directory.appendingPathComponent("data.tar.gz").path), let fileSize = attributes[FileAttributeKey.size] as? UInt64 {
            os_log("Removing corrupt delta bundle of size: %lu bytes", log: self.contentControllerLog, type: .error, fileSize)
        } else {
            os_log("Removing corrupt delta bundle", log: self.contentControllerLog, type: .error)
        }
        
        do {
            try fm.removeItem(at: directory.appendingPathComponent("data.tar.gz"))
            try fm.removeItem(at: directory.appendingPathComponent("data.tar"))
        } catch let error {
            os_log("Failed to remove corrupt delta update: %@", log: self.contentControllerLog, type: .error, error.localizedDescription)
        }
        
        removeBundle(in: directory)
    }
    
    func removeBundle(in directory: URL) {
        
        os_log("Removing Bundle in directory: %@", log: contentControllerLog, type: .debug, directory.absoluteString)
        let fm = FileManager.default
        var files: [String] = []
        
        do {
            files = try fm.contentsOfDirectory(atPath: directory.path)
        } catch let error {
            os_log("Failed to get files for removing bundle in directory at path: %@\n Error: %@", log: self.contentControllerLog, type: .error, directory.path, error.localizedDescription)
        }
        
        files.forEach { (filePath) in
            
            do {
                try fm.removeItem(at: directory.appendingPathComponent(filePath))
            } catch let error {
                os_log("Failed to remove file at path: %@/%@\n Error: %@", log: self.contentControllerLog, type: .error, directory.path, filePath, error.localizedDescription)
            }
        }
    }
    
    //MARK: -
    //MARK: - Copy valid bundle to it's FINAL DESTINATION
    
    private func copyValidBundle(from fromDirectory: URL, to toDirectory: URL) {
        
        os_log("Copying bundle\nFrom: %@\nTo: %@", log: self.contentControllerLog, type: .debug, fromDirectory.absoluteString, toDirectory.absoluteString)
        
        let fm = FileManager.default
        
        callProgressHandlers(with: .copying, error: nil)
        
        guard let files = try? fm.contentsOfDirectory(atPath: fromDirectory.path) else {
            
            callProgressHandlers(with: .copying, error: ContentControllerError.noFilesInBundle)
            return
        }
        
        files.forEach { (file) in
            
            // Check that file is not a directory
            var isDir: ObjCBool = false
            
            if fm.fileExists(atPath: fromDirectory.appendingPathComponent(file).path, isDirectory: &isDir) && !isDir.boolValue {
                
                // Remove pre-existing file
                do {
                    try fm.removeItem(at: toDirectory.appendingPathComponent(file))
                } catch {
                    //                    print("<ThunderStorm> [Updates] Failed to remove file from existing bundle: \(error.localizedDescription)")
                }
                
                // Copy new file
                do {
                    try fm.copyItem(at: fromDirectory.appendingPathComponent(file), to: toDirectory.appendingPathComponent(file))
                } catch let error {
                    os_log("Failed to copy file into bundle: %@", log: self.contentControllerLog, type: .error, error.localizedDescription)
                    callProgressHandlers(with: .copying, error: ContentControllerError.fileCopyFailed)
                }
                
            } else if fm.fileExists(atPath: fromDirectory.appendingPathComponent(file).path) {
                
                // Check if the sub folder exists in cache
                if !fm.fileExists(atPath: toDirectory.appendingPathComponent(file).path) {
                    do {
                        
                        try fm.createDirectory(at: toDirectory.appendingPathComponent(file), withIntermediateDirectories: true, attributes: nil)
                        
                    } catch let error {
                        
                        os_log("Failed to create directory: %@ in bundle: %@", log: self.contentControllerLog, type: .error, file, error.localizedDescription)
                        callProgressHandlers(with: .copying, error: ContentControllerError.fileCopyFailed)
                    }
                }
                
                // It's a directory, so let's loop through it's files
                fm.subpaths(atPath: fromDirectory.appendingPathComponent(file).path)?.forEach({ (subFile) in
                    
                    // Remove pre-existing file
                    do {
                        try fm.removeItem(at: toDirectory.appendingPathComponent(file).appendingPathComponent(subFile))
                    } catch {
                        //                                print("<ThunderStorm> [Updates] Failed to remove file from existing bundle: \(error.localizedDescription)")
                    }
                    
                    // Copy new file
                    do {
                        try fm.copyItem(at: fromDirectory.appendingPathComponent(file).appendingPathComponent(subFile), to: toDirectory.appendingPathComponent(file).appendingPathComponent(subFile))
                    } catch let error {
                        os_log("Failed to copy file into bundle: %@", log: self.contentControllerLog, type: .error, error.localizedDescription)
                        callProgressHandlers(with: .copying, error: ContentControllerError.fileCopyFailed)
                    }
                })
                
                self.addSkipBackupAttributesToItems(in: toDirectory.appendingPathComponent(file))
            }
        }
        
        addSkipBackupAttributesToItems(in: toDirectory)
        updateSettingsBundle()
        
        callProgressHandlers(with: .cleaning, error: nil)
        // Remove temporary cache
        if let tempUpdateDirectory = temporaryUpdateDirectory {
            removeBundle(in: tempUpdateDirectory)
        }
        
        os_log("Update complete", log: self.contentControllerLog, type: .debug)
        os_log("Refreshing language", log: self.contentControllerLog, type: .debug)
        
        checkingForUpdates = false
        StormLanguageController.shared.reloadLanguagePack()
        callProgressHandlers(with: .finished, error: nil)
        
        indexAppContent { (error) -> (Void) in
            
            if let error = error {
                os_log("Failed to re-index content: %@", log: self.contentControllerLog, type: .error, error.localizedDescription)
            } else {
                os_log("Re-indexed content", log: self.contentControllerLog, type: .debug)
            }
        }
        
        if DeveloperModeController.appIsInDevMode {
            NotificationCenter.default.post(name: NSNotification.Name.init("TSCModeSwitchingComplete"), object: nil)
        }
    }
    
    //MARK: -
    //MARK: - App Settings & Helpers
    
    private func addSkipBackupAttributesToItems(in directory: URL) {
        
        os_log("Beginning protection of files in directory: %@", log: contentControllerLog, type: .debug, directory.path)
        
        let fm = FileManager.default
        
        fm.subpaths(atPath: directory.path)?.forEach({ (subFile) in
            
            os_log("Protecting: %@", log: contentControllerLog, type: .debug, subFile)
            do {
                var fileURL = directory.appendingPathComponent(subFile)
                if fm.fileExists(atPath: fileURL.path) {
                    var resourceValues = URLResourceValues()
                    resourceValues.isExcludedFromBackup = true
                    try fileURL.setResourceValues(resourceValues)
                }
            } catch let error {
                os_log("Error excluding %@ from backup\n Error: %@", log: self.contentControllerLog, type: .error, subFile, error.localizedDescription)
            }
        })
    }
    
    private func checkForAppUpgrade() {
        
        os_log("Checking for app upgrade", log: contentControllerLog, type: .debug)
        // App versioning
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let previousVersion = UserDefaults.standard.string(forKey: "TSCLastVersionNumber")
        
        if let current = currentVersion, let previous = previousVersion, current != previous {
            
            os_log("New app version detected, delta updates will now be removed", log: contentControllerLog, type: .debug)
            cleanoutCache()
        }
        
        UserDefaults.standard.set(currentVersion, forKey: "TSCLastVersionNumber")
    }
    
    public func cleanoutCache() {
        
        let fm = FileManager.default
        
        guard Bundle.main.path(forResource: "Bundle", ofType: "") != nil else {
            os_log("Did not clear delta updates due to app not using an embedded Storm Bundle")
            return
        }
        
        guard let deltaDirectory = deltaDirectory else {
            
            os_log("Did not clear delta updates for upgrade due to delta directory not existing", log: self.contentControllerLog, type: .debug)
            return
        }
        
        ["app.json", "manifest.json", "pages", "content", "languages", "data"].forEach { (file) in
            
            do {
                try fm.removeItem(at: deltaDirectory.appendingPathComponent(file))
            } catch {
                os_log("Failed to remove %@ in cache directory: %@", log: self.contentControllerLog, type: .debug, file, error.localizedDescription)
            }
        }
        
        os_log("Delta updates removed", log: contentControllerLog, type: .debug)
        
        // Mark the app as needing to re-index on next launch
        UserDefaults.standard.set(false, forKey: "TSCIndexedInitialBundle")
        
    }
    
    public func updateSettingsBundle() {
        
        if let cacheManifestURL = deltaDirectory?.appendingPathComponent("manifest.json"){
            
            do {
                let data = try Data(contentsOf: cacheManifestURL)
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
                os_log("Delta timestamp not updated in settings: Delta bundle does not exist or it's manifest.json cannot be read", log: self.contentControllerLog, type: .debug)
            }
        }
        
        if let bundleManifestURL = bundleDirectory?.appendingPathComponent("manifest.json"){
            
            do {
                
                let data = try Data(contentsOf: bundleManifestURL)
                
                guard let manifest = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable : Any] else {
                    throw ContentControllerError.defaultError
                }
                
                guard let timeStamp = manifest["timestamp"] as? TimeInterval else {
                    throw ContentControllerError.defaultError
                }
                
                UserDefaults.standard.set("\(timeStamp)", forKey: "bundle_timestamp")
                
            } catch {
                os_log("Error updating bundle timestamp in settings", log: self.contentControllerLog, type: .error)
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
    @available(*, deprecated, message: "Please use fileUrl(forResource, withExtension, inDirectory) instead")
    func path(forResource: String, withExtension: String, inDirectory: String?) -> String? {
        
        var bundleFile: String?
        var cacheFile: String?
        
        if let bundleDirectory = bundleDirectory {
            bundleFile = inDirectory != nil ? "\(bundleDirectory)/\(inDirectory!)/\(forResource).\(withExtension)" : "\(bundleDirectory)/\(forResource).\(withExtension)"
        }
        
        if let deltaDirectory = deltaDirectory {
            
            let cacheURL: URL
            if let _inDirectory = inDirectory {
                cacheURL = deltaDirectory.appendingPathComponent(_inDirectory).appendingPathComponent(forResource).appendingPathExtension(withExtension)
            } else {
                cacheURL = deltaDirectory.appendingPathComponent(forResource).appendingPathExtension(withExtension)
            }
            
            if cacheURL.isFileURL {
                cacheFile = cacheURL.path
            } else {
                cacheFile = cacheURL.absoluteString
            }
        }
        
        if let _cacheFile = cacheFile, FileManager.default.fileExists(atPath: _cacheFile) {
            return _cacheFile
        } else if let _bundleFile = bundleFile, FileManager.default.fileExists(atPath: _bundleFile) {
            return _bundleFile
        }
        
        return nil
    }
    
    /// Returns the file url of a file in the storm bundle
    ///
    /// - parameter forResource:   The name of the file, excluding it's file extension
    /// - parameter withExtension: The file extension to look up
    /// - parameter inDirectory:   A specific directory inside of the storm bundle to lookup (Optional)
    ///
    /// - returns: Returns a url for the resource if it's found
    func fileUrl(forResource: String, withExtension: String, inDirectory: String?) -> URL? {
        
        var bundleFile: URL?
        var cacheFile: URL?
        var streamedFile: URL?
        
        if let streamedDirectory = StreamingPagesController.streamingCacheURL {
            if let _inDirectory = inDirectory {
                streamedFile = streamedDirectory.appendingPathComponent(_inDirectory).appendingPathComponent(forResource).appendingPathExtension(withExtension)
            } else {
                streamedFile = streamedDirectory.appendingPathComponent(forResource).appendingPathExtension(withExtension)
            }
        }
        
        if let bundleDirectory = bundleDirectory {
            
            if let _inDirectory = inDirectory {
                bundleFile = bundleDirectory.appendingPathComponent(_inDirectory).appendingPathComponent(forResource).appendingPathExtension(withExtension)
            } else {
                bundleFile = bundleDirectory.appendingPathComponent(forResource).appendingPathExtension(withExtension)
            }
        }
        
        if let deltaDirectory = deltaDirectory {
            
            if let _inDirectory = inDirectory {
                cacheFile = deltaDirectory.appendingPathComponent(_inDirectory).appendingPathComponent(forResource).appendingPathExtension(withExtension)
            } else {
                cacheFile = deltaDirectory.appendingPathComponent(forResource).appendingPathExtension(withExtension)
            }
        }
        
        if let _streamedFile = streamedFile, FileManager.default.fileExists(atPath: _streamedFile.path) {
            return _streamedFile
        } else if let _cacheFile = cacheFile, FileManager.default.fileExists(atPath: _cacheFile.path) {
            return _cacheFile
        } else if let _bundleFile = bundleFile, FileManager.default.fileExists(atPath: _bundleFile.path) {
            return _bundleFile
        }
        
        return nil
    }
    
    /// Returns a file path from a storm cache link
    ///
    /// - parameter forCacheURL: The storm cache URL to convert
    ///
    /// - returns: Returns an optional path if the file exists at the cache link
    func url(forCacheURL: URL?) -> URL? {
        
        guard let forCacheURL = forCacheURL else { return nil }
        
        let lastPathComponent = forCacheURL.lastPathComponent
        let pathExtension = forCacheURL.pathExtension
        
        let fileName = lastPathComponent.replacingOccurrences(of: ".\(pathExtension)", with: "")
        
        return self.fileUrl(forResource: fileName, withExtension: pathExtension, inDirectory: forCacheURL.host)
    }
    
    /// Returns all the storm fileNames available in a specific directory of the bundle and delta
    ///
    /// - parameter inDirectory: The directory to look for files in
    ///
    /// - returns: A set of file names found in a directory (note: this does NOT include the path)
    func fileNames(inDirectory: String) -> Set<String>? {
        
        var files: Set<String> = []
        
        if let streamDirectory = StreamingPagesController.streamingCacheURL {
            
            let filePathURL = streamDirectory.appendingPathComponent(inDirectory)
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: filePathURL.path)
                contents.forEach({ files.insert($0) })
            } catch let error {
                os_log("No files exist in streamed bundle directory subfolder: %@\nError: %@", log: self.contentControllerLog, type: .debug, inDirectory, error.localizedDescription)
            }
        }
        
        if let deltaDirectory = deltaDirectory {
            
            let filePathURL = deltaDirectory.appendingPathComponent(inDirectory)
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: filePathURL.path)
                contents.forEach({ files.insert($0) })
            } catch let error {
                os_log("No files exist in delta directory subfolder: %@\nError: %@", log: self.contentControllerLog, type: .debug, inDirectory, error.localizedDescription)
            }
        }
        
        if let bundleDirectory = bundleDirectory {
            
            let filePathURL = bundleDirectory.appendingPathComponent(inDirectory)
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: filePathURL.path)
                contents.forEach({ files.insert($0) })
            } catch let error {
                os_log("No files exist in bundle directory subfolder: %@\nError: %@", log: self.contentControllerLog, type: .debug, inDirectory, error.localizedDescription)
            }
        }
        
        return files.count > 0 ? files : nil
    }
    
    func fileExistsInBundle(file: String) -> Bool {
        
        if let temporaryUpdateDirectory = temporaryUpdateDirectory {
            let fileTemporaryCachePath = temporaryUpdateDirectory.appendingPathComponent(file).path
            if FileManager.default.fileExists(atPath: fileTemporaryCachePath) {
                return true
            }
        }
        
        if let deltaDirectory = deltaDirectory {
            let fileCachePath = deltaDirectory.appendingPathComponent(file).path
            if FileManager.default.fileExists(atPath: fileCachePath) {
                return true
            }
        }
        
        if let bundleDirectory = bundleDirectory {
            let fileBundlePath = bundleDirectory.appendingPathComponent(file).path
            if FileManager.default.fileExists(atPath: fileBundlePath) {
                return true
            }
        }
        
        if let streamDirectory = StreamingPagesController.streamingCacheURL {
            let fileStreamedPath = streamDirectory.appendingPathComponent(file).path
            if FileManager.default.fileExists(atPath: fileStreamedPath) {
                return true
            }
        }
        
        var thinnedAssetName = URL(fileURLWithPath: file).lastPathComponent
        let lastUnderScoreComponent = thinnedAssetName.components(separatedBy: "_").last
        
        let extensions = StormImage.validExtensions.map({ return "." + $0 })
        
        // Because of the app thinner, files in the original content directory have been removed
        // And moved to the Bundle.xcassets, so lets check for them in there.
        if let _lastUnderScoreComponent = lastUnderScoreComponent, _lastUnderScoreComponent != thinnedAssetName &&
            _lastUnderScoreComponent.containsOneOf(extensions, caseSensitive: false) {
            
            thinnedAssetName = thinnedAssetName.replacingOccurrences(of: "_\(_lastUnderScoreComponent)", with: "")
        }
        
        if UIImage(named: thinnedAssetName) != nil {
            return true
        }
        
        // We can safely ignore missing x1.5 and x0.75 assets, as they aren't used in iOS apps at all (So the bundle is still valid)
        if var imageSize = lastUnderScoreComponent {
            
            // Replace these for a later check
            extensions.forEach { (fileExtension) in
                imageSize = imageSize.lowercased().replacingOccurrences(of: fileExtension, with: "")
            }
                        
            return imageSize == "x1.5" || imageSize == "x0.75"
        }
        
        return false
    }
}

// MARK: - Loading pages and page information
public extension ContentController {
    
    /// Requests a page dictionary for a given path
    ///
    /// - parameter withURL: A URL of the page to be loaded
    ///
    /// - returns: A dictionary of the page for a certain page
    func pageDictionary(withURL: URL) -> [AnyHashable : Any]? {
        
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
    func metadataForPage(withId: String) -> [AnyHashable : Any]? {
        
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
    func metadataForPage(withName: String) -> [AnyHashable : Any]? {
        
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
    func indexAppContent(with completion: @escaping CoreSpotlightCompletion) {
        
        OperationQueue().addOperation {
            
            self.unIndexOldContent(with: { (error) -> (Void) in
                
                if let error = error {
                    
                    OperationQueue.main.addOperation({
                        
                        completion(error)
                    })
                    
                } else {
                    
                    self.indexNewContent(with: completion)
                }
            })
        }
    }
    
    private func unIndexOldContent(with completion: @escaping CoreSpotlightCompletion) {
        
        if #available(iOS 9.0, *) {
            CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [TSCCoreSpotlightStormContentDomainIdentifier], completionHandler: { (error) -> (Void) in
                
                completion(error)
            })
        }
    }
    
    private func indexNewContent(with completion: @escaping CoreSpotlightCompletion) {
        
        guard let pages = fileNames(inDirectory: "pages") else {
            
            completion(ContentControllerError.noFilesInBundle)
            return
        }
        
        var searchableItems: [CSSearchableItem] = []
        
        pages.forEach { (page) in
            
            guard page.contains(".json"), let pagePath = url(forCacheURL: URL(string: "caches://pages/\(page)"))  else { return }
            guard let pageData = try? Data(contentsOf: pagePath) else { return }
            guard let pageObject = try? JSONSerialization.jsonObject(with: pageData, options: []), let pageDictionary = pageObject as? [AnyHashable : Any] else { return }
            guard let pageClass = pageDictionary["class"] as? String else { return }
            
            var spotlightObject: Any?
            var uniqueIdentifier = page
            
            if pageClass != "TabbedPageCollection" && pageClass != "NativePage" {
                
                // Only try allocation because we're running on background thread and don't
                // want to crash the app if the init method of a storm object needs running
                // on the main thread.
                
                let exception = tryBlock {
                    spotlightObject = StormObjectFactory.shared.indexableStormObject(with: pageDictionary)
                }
                
                if exception != nil {
                    os_log("CoreSpotlight indexing tried to index a storm object of class TSC%@ which cannot be allocated on the main thread.\nTo enable it for indexing please make sure any view code is moved out of the -initWithDictionary:parentObject: method", log: self.contentControllerLog, type: .error, pageClass)
                }
                
            } else if pageClass == "NativePage" {
                
                // Only try allocation because we're running on background thread and don't
                // want to crash the app if the init method of a storm object needs running
                // on the main thread.
                
                guard let pageName = pageDictionary["name"] as? String else {
                    return
                }
                
                let exception = tryBlock {
                    spotlightObject = StormGenerator.indexableObjectForViewControllerWith(name: pageName)
                    uniqueIdentifier = pageName
                }
                
                if exception != nil {
                    os_log("CoreSpotlight indexing tried to index a native page of name %@ which cannot be allocated on the main thread.\nTo enable it for indexing please make sure any view code is moved out of the -init method", log: self.contentControllerLog, type: .error, pageName)
                }
            }
            
            guard let attributeSet = (spotlightObject as? CoreSpotlightIndexable)?.searchableAttributeSet else {
                return
            }
            
            let searchableItem = CSSearchableItem(uniqueIdentifier: uniqueIdentifier, domainIdentifier: TSCCoreSpotlightStormContentDomainIdentifier, attributeSet: attributeSet)
            searchableItems.append(searchableItem)
        }
        
        CSSearchableIndex.default().indexSearchableItems(searchableItems, completionHandler: { (error) in
            
            OperationQueue.main.addOperation({
                completion(error)
            })
        })
    }
}

enum ContentControllerError: Error {
    case contentWithoutSRC
    case noNewContentAvailable
    case noResponseReceived
    case invalidResponse
    case invalidManifest
    case pageWithoutSRC
    case languageWithoutSRC
    case missingAppJSON
    case manifestMissingContent
    case manifestMissingLanguages
    case manifestMissingPages
    case missingFile
    case missingManifestJSON
    case invalidUrlProvided
    case noUrlProvided
    case noDeltaDirectory
    case noFilesInBundle
    case fileCopyFailed
    case badFileRead
    case badFileWrite
    case defaultError
}

extension ContentControllerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .contentWithoutSRC:
            return "A file listed in the manifest content section does not have a valid src url"
        case .noNewContentAvailable:
            return "The server indicated that no new content is available"
        case .noResponseReceived:
            return "No response was received from the Storm CMS when checking for updates"
        case .invalidResponse:
            return "The server returned an invalid response that could not be understood by the ContentController"
        case .invalidManifest:
            return "The manifest.json was deemed invalid during the verification process of the delta bundle"
        case .pageWithoutSRC:
            return "A page in the 'src' section of manifest.json does not have a valid source URL"
        case .languageWithoutSRC:
            return "A language in the `languages' section of manifest.json does not have a valid source URL"
        case .missingAppJSON:
            return "app.json is missing from the bundle"
        case .manifestMissingContent:
            return "The 'content' key is missing from manifest.json"
        case .manifestMissingLanguages:
            return "The 'languages' key is missing from manifest.json"
        case .manifestMissingPages:
            return "The 'pages' key is missing from manifest.json"
        case .missingFile:
            return "A file listed in the manifest was not found in the bundle"
        case .missingManifestJSON:
            return "The 'manifest.json' file is missing from the bundle"
        case .noUrlProvided:
            return "The server indicated that an update was available but did not return a valid URL in the 'file' key of the JSON response"
        case .invalidUrlProvided:
            return "The server indicated that an update was available but did not return a valid URL in the 'file' key of the JSON response"
        case .noDeltaDirectory:
            return "A delta update was downloaded but could not be unpacked because the delta directory does not exist"
        case .noFilesInBundle:
            return "Attempted to copy the delta update to the new directory but no files were found in the source directory"
        case .fileCopyFailed:
            return "Failed to copy a file during the delta update"
        case .badFileRead:
            return "Unable to read the tar.gz downloaded for the delta update"
        case .badFileWrite:
            return "Unable to write the files extracted from the .tar.gz to disk"
        case .defaultError:
            return "An unknown error occured"
        }
    }
}
