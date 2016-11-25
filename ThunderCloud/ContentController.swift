//
//  ContentController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 06/10/2016.
//  Copyright © 2016 threesidedcube. All rights reserved.
//

import Foundation
import ThunderRequest
import UIKit

let API_VERSION: String? = Bundle.main.infoDictionary?["TSCAPIVersion"] as? String
let API_BASEURL: String? = Bundle.main.infoDictionary?["TSCBaseURL"] as? String
let API_APPID: String? = Bundle.main.infoDictionary?["TSCAppId"] as? String
let BUILD_DATE: Int? = Bundle.main.infoDictionary?["TSCBuildDate"] as? Int
let GOOGLE_TRACKING_ID: String? = Bundle.main.infoDictionary?["TSCGoogleTrackingId"] as? String
let STORM_TRACKING_ID: String? = Bundle.main.infoDictionary?["TSCTrackingId"] as? String

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
    
    /// Whether or not the app should display feedback to the user about new content activity
    private var showFeedback: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "download_feedback_enabled")
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
        
        if !UserDefaults.standard.bool(forKey: "TSCIndexedInitialBundle") {
            indexAppContent(with: { (error) -> (Void) in
                
                if error == nil {
                    UserDefaults.standard.set(true, forKey: "TSCIndexedInitialBundle")
                }
            })
        }
        
        checkForAppUpgrade()
        
        updateSettingsBundle()
        checkForUpdates()
    }
    
    //MARK: -
    //MARK: Checking for updates
    
    ///A boolean indicating whether or not the content controller is currently in the process of checking for an update
    public var checkingForUpdates: Bool = false
    
    public func checkForUpdates() {
        
        updateSettingsBundle()
        
        if showFeedback {
            
            OperationQueue.main.addOperation {
                TSCToastNotificationController.shared().displayToastNotification(withTitle: "Checking For Content", message: "Checking for new content from the CMS")
            }
        }
        
        checkForUpdates { (stage, downloaded, totalToDownload, error) -> (Void) in
            
            if ContentController.shared.showFeedback {
                
                OperationQueue.main.addOperation {
                    
                    // No new content
                    if let contentControllerError = error as? ContentControllerError, contentControllerError == .noNewContentAvailable {
                        TSCToastNotificationController.shared().displayToastNotification(withTitle: "No New Content", message: "There is no new content available from the CMS")
                    } else if let error = error {
                        TSCToastNotificationController.shared().displayToastNotification(withTitle: "Content Update Failed", message: "Content update failed with error: \(error.localizedDescription)")
                    }
                    
                    if stage == .finished {
                        TSCToastNotificationController.shared().displayToastNotification(withTitle: "New Content Downloaded", message: "The latest content was downloaded sucessfully")
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
        print("<ThunderStorm> [Updates] Checking for updates with timestamp: \(withTimestamp)")
        
        var environment = "live"
        if DeveloperModeController.appIsInDevMode {
            environment = "test"
        }
        
        // Hit API to check if any updates after this timestamp
        requestController?.get("?timestamp=\(withTimestamp)&density=\(UIScreen.main.scale > 1 ? "x2" : "x1")&environment=\(environment)", completion: { [weak self] (response, error) in
            
            // If we get back an error then fail
            if let error = error {
                
                if let responseStatus = response?.status {
                    print("<ThunderStorm> [Updates] Checking for updates failed (\(responseStatus)): \(error.localizedDescription)")
                } else {
                    print("<ThunderStorm> [Updates] Checking for updates failed: \(error.localizedDescription)")
                }
                
                progressHandler?(.checking, 0, 0, error)
                
            } else if let response = response {
                 // If we get a response, first check status then proceed
                
                // If not modified or no content, then fail the update
                if response.status == TSCResponseStatus.noContent.rawValue || response.status == TSCResponseStatus.notModified.rawValue {
                    
                    print("<ThunderStorm> [Updates] No update found")
                    progressHandler?(.checking, 0, 0, ContentControllerError.noNewContentAvailable)
                    return
                }
                
                // If we get a dictionary as response then download from the provided path
                if let responseDictionary = response.dictionary {
                    
                    // If we get a filepath then download it!
                    guard let filePath = responseDictionary["file"] as? String else {
                        
                        print("<ThunderStorm> [Updates] No bundle download url provided")
                        progressHandler?(.checking, 0, 0, ContentControllerError.noUrlProvided)
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
                    progressHandler?(.checking, 0, 0, ContentControllerError.invalidResponse)
                }
                
            } else {
                
                print("<ThunderStorm> [Updates] No response received from update endpoint")
                progressHandler?(.checking, 0, 0, ContentControllerError.noResponseReceived)
            }
            
            if let welf = self {
                welf.checkingForUpdates = false
            }
            
        })
    }
    
    private func callProgressHandlers(with stage: UpdateStage, error: Error?, amountDownloaded: Int = 0, totalToDownload: Int = 0) {
        
        progressHandlers.forEach { (handler) in
            handler(stage, amountDownloaded, totalToDownload, error)
        }
        
        if stage == .finished || error != nil {
            progressHandlers = []
        }
    }
    
    private func saveBundleData(data: Data) {
        
        // Make sure we have a cache directory and url
        guard let cacheDirectory = cacheDirectory else {
            
            print("<ThunderStorm> [Updates] No cache directory")
            callProgressHandlers(with: .unpacking, error: ContentControllerError.noCacheDirectory)
            return
        }
        
        let cacheURL = URL(fileURLWithPath: cacheDirectory.appending("/data.tar.gz"))
        
        // Write the data to cache url
        do {
            
            try data.write(to: cacheURL, options: .atomic)
            
            guard let temporaryUpdateDirectory = temporaryUpdateDirectory else {
                
                print("<ThunderStorm> [Updates] No temp update directory found")
                callProgressHandlers(with: .unpacking, error: ContentControllerError.noTempDirectory)

                return
            }
            
            // Unpack the bundle
            self.unpackBundle(from: cacheDirectory, into: temporaryUpdateDirectory)
            
        } catch let error {
            
            print("<ThunderStorm> [Updates] Failed to write update bundle to disk")
            callProgressHandlers(with: .unpacking, error: error)
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
        
        downloadRequestController.sharedRequestHeaders["User-Agent"] = TSCStormConstants.userAgent()
        
        downloadRequestController.downloadFile(withPath: fromURL, progress: { [weak self] (progress, totalBytes, bytesTransferred) in
            
            self?.callProgressHandlers(with: .downloading, error: nil, amountDownloaded: bytesTransferred, totalToDownload: totalBytes)
            
        }) { [weak self] (url, error) in
                
            if let error = error {
                
                print("<ThunderStorm> [Updates] Downloading update bundle failed \(error.localizedDescription)")
                
                self?.callProgressHandlers(with: .downloading, error: error)
                return
            }
            
            guard let url = url else {
                
                print("<ThunderStorm> [Updates] No bundle data returned")
                self?.callProgressHandlers(with: .downloading, error: ContentControllerError.invalidResponse)
                return
            }
            
            if let data = try? Data(contentsOf: url) {
                
                self?.saveBundleData(data: data)
                
            } else {
                
                self?.callProgressHandlers(with: .downloading, error: ContentControllerError.invalidResponse)
            }
        }
    }
    
    //MARK: -
    //MARK: Update Unpacking
    
    /// Unpacks a downloaded storm bundle into a directory from a specified directory
    ///
    /// - parameter inDirectory: The directory to read bundle data from
    /// - parameter toDirectory: The directory to write the unpacked bundle data to
    
    private func unpackBundle(from directory: String, into destinationDirectory: String) {
        
        print("<ThunderStorm> [Updates] Unpacking bundle...")
        
        callProgressHandlers(with: .unpacking, error: nil)
        
        let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
            
        backgroundQueue.async {
            
            let fileUrl = URL(fileURLWithPath: "\(directory)/data.tar.gz")
            var data: Data
            
            // Read data from directory
            do {
                data = try Data(contentsOf: fileUrl, options: Data.ReadingOptions.mappedIfSafe)
            } catch let error {
                print("<ThunderStorm> [Updates] Unpacking bundle failed \(error.localizedDescription)")
                self.callProgressHandlers(with: .unpacking, error: ContentControllerError.badFileRead)
                return
            }
            
            let archive = "/data.tar"
            let nsData = data as NSData
    
            // Unzip data
            let gunzipData = gunzip(nsData.bytes, nsData.length)
            
            let cDecompressed = Data(bytes: gunzipData.data, count: gunzipData.length)
        
            //Write unzipped data to directory
            let directoryWriteUrl = URL(fileURLWithPath: destinationDirectory.appending(archive), isDirectory: true)
            
            do {
                try cDecompressed.write(to:directoryWriteUrl, options: [])
            } catch let error {
                print("<ThunderStorm> [Updates] Writing unpacked bundle failed: \(error.localizedDescription)")
                self.callProgressHandlers(with: .unpacking, error: ContentControllerError.badFileRead)
                return
            }
    
            let arch = fopen(destinationDirectory.appending(archive).cString(using: String.Encoding.utf8), "r")
            
            untar(arch, destinationDirectory.cString(using: String.Encoding.utf8))
            
            fclose(arch)
            
            guard let cacheDirectory = self.cacheDirectory else {
                
                self.callProgressHandlers(with: .unpacking, error: ContentControllerError.noCacheDirectory)
                return
            }
            
            // Verify bundle
            let isValid = self.verifyBundle(in: destinationDirectory)
            
            if !isValid {
                
                self.removeCorruptDeltaBundle()
                
            } else {
                
                let fm = FileManager.default
                do {
                    
                    try fm.removeItem(atPath: "\(cacheDirectory)/data.tar.gz")
                    try fm.removeItem(atPath: "\(cacheDirectory)/data.tar")
                    
                } catch {
                    
                    self.copyValidBundle(from: destinationDirectory, to: cacheDirectory)
                    return
                }
                
                self.copyValidBundle(from: destinationDirectory, to: cacheDirectory)
            }
        }
    }
    
    
    
    //MARK: -
    //MARK: Verify Unpacked bundle
    private func verifyBundle(in directory: String) -> Bool {
        
        print("<ThunderStorm> [Updates] Verifying bundle...")
        callProgressHandlers(with: .verifying, error: nil)
    
        // Check temporary directory exists
        guard let temporaryUpdateDirectory = temporaryUpdateDirectory else {
            
            print("<ThunderStorm> [Verification] No temporary update directory found")
            callProgressHandlers(with: .verifying, error: ContentControllerError.noTempDirectory)
            return false
        }
        // Set up file path for manifest
        let temporaryUpdateManifestPath = "\(temporaryUpdateDirectory)/manifest.json"
        
        let temporaryUpdateManifestPathUrl = URL(fileURLWithPath: temporaryUpdateManifestPath)
        
        var manifestData: Data
        
        // Create data object from manifest
        do {
             manifestData  = try Data(contentsOf: temporaryUpdateManifestPathUrl, options: Data.ReadingOptions.mappedIfSafe)
            
        } catch let error {
            
            callProgressHandlers(with: .verifying, error: ContentControllerError.invalidManifest)
            print("<ThunderStorm> [Verification] Failed to read manifest at path: \(temporaryUpdateManifestPath)\n Error:\(error.localizedDescription)")
            return false
        }
        
        var manifestJSON: Any
        
        // Serialize manifest into JSON
        do {
            manifestJSON = try JSONSerialization.jsonObject(with: manifestData, options: JSONSerialization.ReadingOptions.mutableContainers)
            
        } catch let error {
            
            callProgressHandlers(with: .verifying, error: ContentControllerError.invalidManifest)
            print("<ThunderStorm> [Verification] Failed to parse JSON into dictionary: ", error.localizedDescription)
            return false
        }
        
        guard let manifest = manifestJSON as? [String: AnyObject] else {
            
            print("<ThunderStorm> [Verification] Can't cast manifest as dictionary")
            callProgressHandlers(with: .verifying, error: ContentControllerError.invalidManifest)
            return false
        }
       
        
        if (!self.fileExistsInBundle(file: "app.json")) {
            
            callProgressHandlers(with: .verifying, error: ContentControllerError.missingAppJSON)
            return false
        }
        
        if (!self.fileExistsInBundle(file: "manifest.json")) {
            
            callProgressHandlers(with: .verifying, error: ContentControllerError.missingManifestJSON)
            return false
        }
        
        // Verify pages
        guard let pages = manifest["pages"] as? [[String: Any]] else {
            
            callProgressHandlers(with: .verifying, error: ContentControllerError.invalidManifest)
            return false
        }
        
        for page in pages {
            
            guard let source = page["src"] as? String else {
                
                callProgressHandlers(with: .verifying, error: ContentControllerError.pageWithoutSRC)
                return false
            }
            
            let pageFile = "pages/\(source)"
            if !self.fileExistsInBundle(file: pageFile) {
                
                callProgressHandlers(with: .verifying, error: ContentControllerError.pageWithoutSRC)
                return false
            }
        }
        
        //Verify languages
        guard let languages = manifest["languages"] as? [[String: Any]] else {
            
            callProgressHandlers(with: .verifying, error: ContentControllerError.missingLanguages)
            return false
        }
    
        for language in languages {
            guard let source = language["src"] as? String else {
                
                callProgressHandlers(with: .verifying, error: ContentControllerError.languageWithoutSRC)
                return false
            }
            
            let pageFile = "languages/\(source)"
            if !self.fileExistsInBundle(file: pageFile) {
                
                callProgressHandlers(with: .verifying, error: ContentControllerError.languageWithoutSRC)
                return false
            }
        }
        
        //Verify Content
        guard let contents = manifest["content"] as? [[String: Any]] else {
            
            callProgressHandlers(with: .verifying, error: ContentControllerError.missingContent)
            return false
        }
        
        for content in contents {
            
            guard let source = content["src"] as? String else {
                
                callProgressHandlers(with: .verifying, error: ContentControllerError.contentWithoutSRC)
                return false
            }
            
            let pageFile = "content/\(source)"
            if !self.fileExistsInBundle(file: pageFile) {
                
                callProgressHandlers(with: .verifying, error: ContentControllerError.contentWithoutSRC)
                return false
            }
        }
        
        return true
    }
    
    private func removeCorruptDeltaBundle() {
        
        let fm = FileManager.default
        guard let cacheDirectory = cacheDirectory else {
            print("<ThunderStorm> [Updates] Failed to remove corrupt delta as cache directory was nil")
            return
        }
        
        if let attributes = try? fm.attributesOfItem(atPath: "\(cacheDirectory)/data.tar.gz"), let fileSize = attributes[FileAttributeKey.size] {
            print("<ThunderStorm> [Updates] Removing corrupt delta bundle of size: \(fileSize) bytes")
        } else {
            print("<ThunderStorm> [Updates] Removing corrupt delta bundle")
        }
        
        do {
            try fm.removeItem(atPath: "\(cacheDirectory)/data.tar.gz")
        } catch let error {
            print("<ThunderStorm> [Updates] Failed to remove corrupt delta update: \(error.localizedDescription)")
        }
        
        guard let tempDirectory = self.temporaryUpdateDirectory else {
            return
        }
        
        removeBundle(in: tempDirectory)
    }
    
    func removeBundle(in directory: String) {
        
        let fm = FileManager.default
        var files: [String] = []
        
        do {
            files = try fm.contentsOfDirectory(atPath: directory)
        } catch let error {
            print("<ThunderStorm> [Updates] Failed to get files for removing bundle in directory at path: \(directory), error: \(error.localizedDescription)")
        }
        
        files.forEach { (filePath) in
            
            do {
                try fm.removeItem(atPath: "\(directory)/\(filePath)")
            } catch let error {
                print("<ThunderStorm> [Updates] Failed to remove file at path: \(directory)/\(filePath), error: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: -
    //MARK: - Copy valid bundle to it's FINAL DESTINATION
    
    private func copyValidBundle(from fromDirectory: String, to toDirectory: String) {
        
        let fm = FileManager.default
        
        callProgressHandlers(with: .copying, error: nil)
        
        guard let files = try? fm.contentsOfDirectory(atPath: fromDirectory) else {
            
            callProgressHandlers(with: .copying, error: ContentControllerError.noFilesInBundle)
            return
        }
        
        files.forEach { (file) in
            
            // Check that file is not a directory
            var isDir: ObjCBool = false
            
            if fm.fileExists(atPath: "\(fromDirectory)/\(file)", isDirectory: &isDir) && !isDir.boolValue {
                
                // Remove pre-existing file
                do {
                    try fm.removeItem(atPath: "\(toDirectory)/\(file)")
                } catch {
//                    print("<ThunderStorm> [Updates] Failed to remove file from existing bundle: \(error.localizedDescription)")
                }
                
                // Copy new file
                do {
                    try fm.copyItem(atPath: "\(fromDirectory)/\(file)", toPath: "\(toDirectory)/\(file)")
                } catch let error {
                    print("<ThunderStorm> [Updates] failed to copy file into bundle: \(error.localizedDescription)")
                    callProgressHandlers(with: .copying, error: ContentControllerError.fileCopyFailed)
                }
                
            } else if fm.fileExists(atPath: "\(fromDirectory)/\(file)") {
                
                // Check if the sub folder exists in cache
                if !fm.fileExists(atPath: "\(toDirectory)/\(file)") {
                    do {
                        
                        try fm.createDirectory(atPath: "\(toDirectory)/\(file)", withIntermediateDirectories: true, attributes: nil)
                        
                        // It's a directory, so let's loop through it's files
                        fm.subpaths(atPath: "\(fromDirectory)/\(file)")?.forEach({ (subFile) in
                            
                            // Remove pre-existing file
                            do {
                                try fm.removeItem(atPath: "\(toDirectory)/\(file)/\(subFile)")
                            } catch {
//                                print("<ThunderStorm> [Updates] Failed to remove file from existing bundle: \(error.localizedDescription)")
                            }
                            
                            // Copy new file
                            do {
                                try fm.copyItem(atPath: "\(fromDirectory)/\(file)/\(subFile)", toPath: "\(toDirectory)/\(file)/\(subFile)")
                            } catch let error {
                                print("<ThunderStorm> [Updates] failed to copy file into bundle: \(error.localizedDescription)")
                                callProgressHandlers(with: .copying, error: ContentControllerError.fileCopyFailed)
                            }
                        })
                        
                        self.addSkipBackupAttributesToItems(in: "\(toDirectory)/\(file)")
                        
                    } catch let error {
                        
                        print("<ThunderStorm> [Updates] failed to create directory \(file) in bundle: \(error.localizedDescription)")
                        callProgressHandlers(with: .copying, error: ContentControllerError.fileCopyFailed)
                    }
                }
            }
        }

        addSkipBackupAttributesToItems(in: toDirectory)
        updateSettingsBundle()
        
        callProgressHandlers(with: .cleaning, error: nil)
        // Remove temporary cache
        if let tempUpdateDirectory = temporaryUpdateDirectory {
            removeBundle(in: tempUpdateDirectory)
        }

        // Remove leftover tar files
        if let cacheDirectory = cacheDirectory {
            do {
                try fm.removeItem(atPath: "\(cacheDirectory)/data.tar")
            } catch let error {
                print("<ThunderStorm> [Updates] failed to clear up cached data.tar: \(error.localizedDescription)")
            }
        }

        print("<ThunderStorm> [Updates] Update complete")
        print("<ThunderStorm> [Updates] Refreshing language")
        
        checkingForUpdates = false
        callProgressHandlers(with: .finished, error: nil)
        
        indexAppContent { (error) -> (Void) in
            
            if let error = error {
                print("<ThunderStorm> [Updates] failed to re-index content: \(error.localizedDescription)")
            } else {
                print("<ThunderStorm> [Updates] Re-indexed content")
            }
        }
        
        TSCStormLanguageController.shared().reloadLanguagePack()

        if DeveloperModeController.appIsInDevMode {
            NotificationCenter.default.post(name: NSNotification.Name.init("TSCModeSwitchingComplete"), object: nil)
        }
    }
    
    //MARK: -
    //MARK: - App Settings & Helpers

    private func addSkipBackupAttributesToItems(in directory: String) {
    
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
            
            print("<ThunderStorm> [Updates] Didn't clear cache because directory not present")
            return
        }
        
        ["app.json", "manifest.json", "pages", "content", "languages", "data"].forEach { (file) in
            
            do {
                try fm.removeItem(atPath: cacheDirectory.appending("/\(file)"))
            } catch {
                print("<ThunderStorm> [Updates] Failed to remove \(file) in cache directory: \(error.localizedDescription)")
            }
        }
        
        // Mark the app as needing to re-index on next launch
        UserDefaults.standard.set(false, forKey: "TSCIndexedInitialBundle")
    }
    
    public func updateSettingsBundle() {
        
        if let cacheManifest = cacheDirectory?.appending("/manifest.json") {
            
            let cacheManifestURL = URL(fileURLWithPath: cacheManifest)
            
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
                print("Error updating delta timestamp in settings")
            }
        }
        
        if let bundleManifest = bundleDirectory?.appending("/manifest.json") {
            
            let bundleManifestURL = URL(fileURLWithPath: bundleManifest)
            
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
    @available(*, deprecated, message: "Please use fileUrl(forResource, withExtension, inDirectory) instead")
    public func path(forResource: String, withExtension: String, inDirectory: String?) -> String? {
        
        var bundleFile: String?
        var cacheFile: String?

        if let bundleDirectory = bundleDirectory {
            bundleFile = inDirectory != nil ? "\(bundleDirectory)/\(inDirectory!)/\(forResource).\(withExtension)" : "\(bundleDirectory)/\(forResource).\(withExtension)"
        }
        
        if let cacheDirectory = cacheDirectory {
            cacheFile = inDirectory != nil ? "\(cacheDirectory)/\(inDirectory!)/\(forResource).\(withExtension)" : "\(cacheDirectory)/\(forResource).\(withExtension)"
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
    public func fileUrl(forResource: String, withExtension: String, inDirectory: String?) -> URL? {
        
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

        return self.fileUrl(forResource: fileName, withExtension: pathExtension, inDirectory: forCacheURL.host)
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
                print("error getting files in bundle directory: \(error.localizedDescription)")
            }
        }
        
        if let cacheDirectory = cacheDirectory {
            
            let filePath = cacheDirectory.appending("/\(inDirectory)")
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: filePath)
                files.append(contentsOf: contents)
            } catch let error {
                print("error getting files in cache directory: \(error.localizedDescription)")
            }
        }
        
        return files.count > 0 ? files : nil
    }
    
    func fileExistsInBundle(file: String) -> Bool {
        
        if let temporaryUpdateDirectory = temporaryUpdateDirectory {
            let fileTemporaryCachePath = "\(temporaryUpdateDirectory)/\(file)"
            if (FileManager.default.fileExists(atPath: fileTemporaryCachePath)) {
                return true
            }
        }
        
        if let cacheDirectory = cacheDirectory {
            let fileCachePath = "\(cacheDirectory)/\(file)"
            if (FileManager.default.fileExists(atPath: fileCachePath)) {
                return true
            }
        }
        
        if let bundleDirectory = bundleDirectory {
            let fileBundlePath = "\(bundleDirectory)/\(file)"
            if (FileManager.default.fileExists(atPath: fileBundlePath)) {
                return true
            }
        }
        
        var thinnedAssetName = URL(fileURLWithPath: file).lastPathComponent
        let lastUnderScoreComponent = thinnedAssetName.components(separatedBy: "_").last
        
        if let _lastUnderScoreComponent = lastUnderScoreComponent, (_lastUnderScoreComponent == thinnedAssetName) &&
            (_lastUnderScoreComponent.contains(".png") || _lastUnderScoreComponent.contains(".jpg")) {
            
            thinnedAssetName = thinnedAssetName.replacingOccurrences(of: "_\(_lastUnderScoreComponent)", with: "")
            }
    
        if (UIImage(named: thinnedAssetName) != nil) {
            return true
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
    public func indexAppContent(with completion: @escaping CoreSpotlightCompletion) {
        
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
        
        guard let pages = files(inDirectory: "pages") else {
            
            completion(ContentControllerError.noFilesInBundle)
            return
        }
        
        if #available(iOS 9.0, *) {
            
            var searchableItems: [CSSearchableItem] = []
        
            pages.forEach { (page) in
                
                guard page.contains(".json"), let pagePath = url(forCacheURL: URL(string: "caches://pages/\(page)"))  else { return }
                guard let pageData = try? Data(contentsOf: pagePath) else { return }
                guard let pageObject = try? JSONSerialization.jsonObject(with: pageData, options: []), let pageDictionary = pageObject as? [AnyHashable : Any] else { return }
                guard let pageClass = pageDictionary["class"] as? String else { return }
                
                var spotlightObject: NSObject?
                var uniqueIdentifier = page
                
                if pageClass != "TabbedPageCollection" && pageClass != "NativePage" {
                    
                    // Only try allocation because we're running on background thread and don't
                    // want to crash the app if the init method of a storm object needs running
                    // on the main thread.
                    
                    let exception = tryBlock {
                        spotlightObject = TSCStormObject(dictionary: pageDictionary, parentObject: nil)
                    }
                    
                    if exception != nil {
                        print("CoreSpotlight indexing tried to index a storm object of class TSC\(pageClass) which cannot be allocated on the main thread.\nTo enable it for indexing please make sure any view code is moved out of the -initWithDictionary:parentObject: method")
                    }
                    
                } else if pageClass == "NativePage" {
                    
                    // Only try allocation because we're running on background thread and don't
                    // want to crash the app if the init method of a storm object needs running
                    // on the main thread.
                    
                    guard let pageName = pageDictionary["name"] as? String else {
                        return
                    }
                    
                    let exception = tryBlock {
                        spotlightObject = TSCStormViewController.viewController(forNativePageName:pageName)
                        uniqueIdentifier = pageName
                    }
                    
                    if exception != nil {
                        print("CoreSpotlight indexing tried to index a native page of name \(pageName) which cannot be allocated on the main thread.\nTo enable it for indexing please make sure any view code is moved out of the -init method")
                    }
                }
                
                if let indexableObject = spotlightObject as? TSCCoreSpotlightIndexItem {
                    
                    guard let attributeSet = indexableObject.searchableAttributeSet() else { return }
                    let searchableItem = CSSearchableItem(uniqueIdentifier: uniqueIdentifier, domainIdentifier: TSCCoreSpotlightStormContentDomainIdentifier, attributeSet: attributeSet)
                    searchableItems.append(searchableItem)
                }
            }
            
            CSSearchableIndex.default().indexSearchableItems(searchableItems, completionHandler: { (error) in
                
                OperationQueue.main.addOperation({ 
                    completion(error)
                })
            })
        }
    }
}

enum ContentControllerError: Error {
    case copyFileFailed
    case contentWithoutSRC
    case createDirectoryFailed
    case noNewContentAvailable
    case noResponseReceived
    case invalidResponse
    case invalidManifest
    case pageWithoutSRC
    case languageWithoutSRC
    case missingAppJSON
    case missingContent
    case missingLanguages
    case missingManifestJSON
    case noUrlProvided
    case noCacheDirectory
    case cannotSaveBundleGZIP
    case noFilesInBundle
    case fileCopyFailed
    case noTempDirectory
    case badFileRead
    case badFileWrite
    case defaultError
}
