//
//  ContentController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 06/10/2016.
//  Copyright © 2016 threesidedcube. All rights reserved.
//

import BackgroundTasks
import Baymax
import CoreSpotlight
import ThunderRequest
import ThunderBasics
import UIKit
import os

extension TimeInterval {
    
    init?(_ any: Any) {
        
        if let itvl = any as? TimeInterval {
            self = itvl
            return
        }
        
        switch any {
        case let string as String:
            guard let intvl = TimeInterval(string) else {
                return nil
            }
            self = intvl
        case let int as Int:
            self = TimeInterval(int)
        case let uint as UInt:
            self = TimeInterval(uint)
        case let float as Float:
            self = TimeInterval(float)
        default:
            return nil
        }
    }
}

public extension TimeInterval {
    
    /// 1 minute constant
    static let minute: TimeInterval = 60
    
    /// 1 hour constant
    static let hour: TimeInterval = 60 * 60
}

extension String {
    /// Returns a Boolean value indicating whether the string contains any of the given elements.
    /// - Parameter containedStrings: The substrings to check for
    /// - Parameter caseSensitive: Whether the check should run in a case sensitive manner
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
    
    private static let logCategory = "ContentController"
    
    /// The log for which all content controller events should be sent
    private var contentControllerLog = OSLog(subsystem: "com.threesidedcube.ThunderCloud", category: ContentController.logCategory)
    
    /// Whether or not the app should display feedback to the user about new content activity
    internal static var showFeedback: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "download_feedback_enabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "download_feedback_enabled")
        }
    }
    
    /// Whether or not feedback should be sent as local notification if the app is running in the background!
    internal static var showFeedbackInBackground: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "download_feedback_enabled_background")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "download_feedback_enabled_background")
        }
    }
    
    /// Whether content should only be downloaded over wifi
    internal static var onlyDownloadOverWifi: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "download_content_only_wifi")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "download_content_only_wifi")
        }
    }
    
    private var progressHandlers: [ContentUpdateProgressHandler] = []
    
    /// The timestamp of the latest available content (Delta or original bundle)
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
    
    /// The timestamp of the initial content bundle the app was bundled with
    private var initialBundleTimestamp: TimeInterval? {
        get {
            if let overrideTimestamp = UserDefaults.standard.object(forKey: "initial_bundle_timestamp") as? TimeInterval {
                return overrideTimestamp
            }
            
            guard let bundleDirectory = bundleDirectory else { return nil }
            let manifestURL = bundleDirectory.appendingPathComponent("manifest").appendingPathExtension("json")
            do {
                let data = try Data(contentsOf: manifestURL)
                guard let manifest = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable : Any] else { return nil }
                if let timeStamp = manifest["timestamp"] as? TimeInterval {
                    return timeStamp
                } else {
                    return nil
                }
            } catch {
                return nil
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "initial_bundle_timestamp")
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
        
        baymax_log("Initialising Content Controller", subsystem: Logger.stormSubsystem, category: "ContentController", type: .info)
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
                    
                    baymax_log("Setting app build date to \(dateFormatter.string(from: creationDate))", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
                    os_log("Setting app build date to %@", log: contentControllerLog, type: .debug, dateFormatter.string(from: creationDate))
                    UserDefaults.standard.set(dateFormatter.string(from: creationDate), forKey: "build_date")
                }
            } catch {
                baymax_log("Couldn't find initial build date", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
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
                baymax_log("Failed to create delta directory at \(_deltaDirectory.absoluteString)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .fault)
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
                    baymax_log("Failed to create bundle directory at \(_bundleDirectory.absoluteString)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .fault)
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
                baymax_log("Failed to create temporary update directory at \(tempDirectory.absoluteString)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .fault)
                os_log("Failed to create temporary update directory at %@", log: contentControllerLog, type: .fault, tempDirectory.absoluteString)
            }
        }
        
        super.init()
        configureBaseURL()
    }
    
    /// This function should be called in the `AppDelegate`'s `application(_ application:, didFinishLaunchingWithOptions:)` function to check for new content
    /// - Parameter updateCheck: Whether the app launch should result in the app checking for updates. If the launch was due to a content-available push this should be false for example!
    /// - Note: This should not be called externally if at all possible. However if you are performing transforms to data files and saving in the delta directory
    /// it can be necessary to call this before your logic to avoid Storm's version update check from deleting all your data!
    public func appLaunched(checkForUpdates updateCheck: Bool = true, isLaunching: Bool = false) {
        
        baymax_log("`appLaunched` called", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("`appLaunched` called", log: contentControllerLog, type: .debug)
        
        checkForAppUpgrade()
        updateSettingsBundle()
                
        // Always register BG Task Listener, as this method checks if we're already listening anyway
        //
        // Background tasks must be registered before the application finishes launching
        // otherwise an NSInternalInconsistencyException will be raised:
        // 'All launch handlers must be registered before application finishes launching'
        if isLaunching, #available(iOS 13.0, *) {
            registerBGTaskListeners()
        }
        
        guard updateCheck else {
            return
        }
        
        // Only do this if a true launch of the app!
        if !UserDefaults.standard.bool(forKey: "TSCIndexedInitialBundle") {
            indexAppContent(with: { (error) -> (Void) in
                
                if error == nil {
                    UserDefaults.standard.set(true, forKey: "TSCIndexedInitialBundle")
                }
            })
        }
        
        baymax_log("Optionally checking for updated content", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("Optionally checking for updated content", log: contentControllerLog, type: .debug)
        
        guard fileExistsInBundle(file: "app.json") else {
            baymax_log("No app.json found, update check abandoned", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
            os_log("No app.json found, update check abandoned", log: contentControllerLog, type: .debug)
            return
        }
        
        self.checkForUpdates()
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
            baymax_log("Base URL invalid", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
            os_log("Base URL invalid", log: contentControllerLog, type: .error)
            return
        }
        
        requestController = RequestController(baseURL: baseURL)
        downloadRequestController = RequestController(baseURL: baseURL)
        
        baymax_log("Base URL configured as: \(baseURL.absoluteString)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("Base URL configured as: %@", log: contentControllerLog, type: .debug, baseURL.absoluteString)
    }
    
    /// Downloads a full storm content bundle, this will clear all directories and will also mark the downloaded bundle as the 'initial' bundle timestamp
    /// so that we can avoid downloading any post-landmark publishes from content-available notifications!
    /// - Parameter buildTimestamp: The timestamp of the build since the unix epoch, used to make sure we don't bypass any landmark publishes
    /// - Parameter progressHandler: A closure called when as the download progresses
    public func downloadFullBundle(buildTimestamp: TimeInterval? = nil, with progressHandler: ContentUpdateProgressHandler?) {
        
        removeAllContentBundles()
        configureBaseURL()
        
        let stormAppId = UserDefaults.standard.string(forKey: "TSCAppId") ?? Storm.API.AppID
        
        guard let baseString = Storm.API.BaseURL, let version = Storm.API.Version, let appId = stormAppId else {
            fatalError("Failed to get required parameters to download a storm bundle: missing one of Base URL, Api Version or AppID")
        }
        
        guard var urlComponents = URLComponents(string: "\(baseString)/\(version)/apps/\(appId)/bundle") else {
            fatalError("Failed to create url to download a storm bundle: one of Base URL, Api Version or AppID are invalid url parts")
        }
            
        guard let bundleDirectory = bundleDirectory else {
            return
        }
        
        if let buildTimestamp = buildTimestamp {
            urlComponents.queryItems = [
                URLQueryItem(name: "timestamp", value: "\(Int(buildTimestamp))")
            ]
        }
        
        guard let bundleUrl = urlComponents.url else {
            fatalError("Failed to create url to download a storm bundle: one of Base URL, Api Version or AppID are invalid url parts")
        }
        
        // We set the initial bundle timestamp here because this bundle will now act as the app's initial bundle!
        downloadPackage(fromURL: bundleUrl, destinationDirectory: bundleDirectory, setAsInitialBundle: true, progressHandler: progressHandler)
    }
    
    //MARK: -
    //MARK: Checking for updates
    
    /// Whether new content was downloaded with the app in the background
    ///
    /// If this is true, there is content ready to be applied when the app next enters foreground. This will only be sent to true if
    /// content finishes downloading with the app in the `background` `UIApplication.State`.
    public var newContentAvailableOnNextForeground: Bool = false
    
    ///A boolean indicating whether or not the content controller is currently in the process of checking for an update
    public var isCheckingForUpdates: Bool = false
    
    /// Asks the content controller to check with the Storm server for updates
    /// - Parameter isBackgroundUpdate: Whether the update is happening as result of one of Apple's background refresh mechanisms
    public func checkForUpdates(isBackgroundUpdate: Bool = false) {
        
        let currentStatus = TSCReachability.forInternetConnection().currentReachabilityStatus()
        if ContentController.onlyDownloadOverWifi && currentStatus != ReachableViaWiFi {
            baymax_log("Abandoned checking for updates as not connected to WiFi", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
            os_log("Abandoned checking for updates as not connected to WiFi", log: contentControllerLog, type: .debug)
            return
        }
        
        updateSettingsBundle()
        
        checkForUpdates(isBackgroundUpdate: isBackgroundUpdate) { [weak self] (stage, _, _, error) -> (Void) in
            
            // If we got an error, handle it properly
            if let error = error {
                
                guard let contentControllerError = error as? ContentControllerError else {
                    self?.onTaskCompleted?(false)
                    return
                }
                
                switch contentControllerError {
                case .noNewContentAvailable:
                    // Seems to be we should set this to true even if no new content available
                    self?.onTaskCompleted?(true)
                default:
                    self?.onTaskCompleted?(false)
                }
                
            } else {
                
                switch stage {
                    // If we reach the finished or preparing phase, then we can call completionHandler
                    // and rely on background download API. Finished is if we directly download the bundle
                    // by hitting /bundle, preparing is if we need to make a further API call
                case .finished, .preparing:
                    self?.onTaskCompleted?(true)
                default:
                    break
                }
            }
        }
    }
    
    /// Asks the content controller to check with the Storm server for updates
    ///
    /// The timestamp used to check will be taken from the bundle or delta bundle inside of the app
    ///
    /// - Parameters:
    ///   - withProgressHandler: A closure called with progress updates on the update
    ///   - isBackgroundUpdate: Whether the update is happening as result of one of Apple's background refresh mechanisms
    public func checkForUpdates(isBackgroundUpdate: Bool = false, progressHandler: ContentUpdateProgressHandler?) {
        checkForUpdates(withTimestamp: latestBundleTimestamp, isBackgroundUpdate: isBackgroundUpdate, progressHandler: progressHandler)
    }
    
    /// Asks the content controller to check with the Storm server for updates
    ///
    /// Use this method if you need to request the bundle for a specific timestamp
    ///
    /// - parameter withTimestamp: The timestamp to send to the server as the current bundle version
    /// - parameter progressHandler: A closure called with progress updates on the update
    /// - parameter isBackgroundUpdate: Whether the update is happening as result of one of Apple's background refresh mechanisms
    public func checkForUpdates(withTimestamp: TimeInterval, isBackgroundUpdate: Bool = false, progressHandler: ContentUpdateProgressHandler? = nil) {
        
        showFeedback(title: "Checking For Content", message: "Checking for new content from the CMS")
        
        isCheckingForUpdates = true
        baymax_log("Checking for updates with timestamp: \(withTimestamp)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("Checking for updates with timestamp: %.0f", log: contentControllerLog, type: .debug, withTimestamp)
        
        var environment = "live"
        if DeveloperModeController.appIsInDevMode {
            environment = "test"
            if let authorization = AuthenticationController().authentication {
                requestController?.sharedRequestHeaders["Authorization"] = authorization.token
            }
        }
        
        if let progressHandler = progressHandler {
            progressHandlers.append(progressHandler)
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
                        baymax_log("Checking for updates failed \(responseStatus.rawValue): \(error.localizedDescription)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
                        os_log("Checking for updates failed %d: %@", log: contentControllerLog, type: .debug, responseStatus.rawValue, error.localizedDescription)
                    }
                } else {
                    if let contentControllerLog = self?.contentControllerLog {
                        baymax_log("Checking for updates failed: \(error.localizedDescription)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
                        os_log("Checking for updates failed: %@", log: contentControllerLog, type: .debug, error.localizedDescription)
                    }
                }
                
                self?.callProgressHandlers(with: .checking, error: error)
                
            } else if let response = response {
                // If we get a response, first check status then proceed
                
                // If not modified or no content, then fail the update
                if response.status == .noContent || response.status == .notModified {
                    
                    if let contentControllerLog = self?.contentControllerLog {
                        baymax_log("No update found", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
                        os_log("No update found", log: contentControllerLog, type: .debug)
                    }
                    self?.callProgressHandlers(with: .checking, error: ContentControllerError.noNewContentAvailable)
                    return
                }
                
                // If we get a dictionary as response then download from the provided path
                if let responseDictionary = response.dictionary {
                    
                    // If we get a filepath then download it!
                    guard let filePath = responseDictionary["file"] as? String else {
                        
                        if let contentControllerLog = self?.contentControllerLog {
                            baymax_log("No bundle download url provided in response", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
                            os_log("No bundle download url provided in response", log: contentControllerLog, type: .error)
                        }
                        self?.callProgressHandlers(with: .checking, error: ContentControllerError.noUrlProvided)
                        return
                    }
                    
                    guard let fileURL = URL(string: filePath) else {
                        if let contentControllerLog = self?.contentControllerLog {
                            baymax_log("Bundle download url in response is invalid: \(filePath)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
                            os_log("Bundle download url in response is invalid", log: contentControllerLog, type: .error)
                        }
                        self?.callProgressHandlers(with: .checking, error: ContentControllerError.invalidUrlProvided)
                        return
                    }
                    
                    if let _destinationURL = self?.deltaDirectory {
                        self?.callProgressHandlers(with: .preparing, error: nil)
                        self?.downloadPackage(fromURL: fileURL, destinationDirectory: _destinationURL, isBackgroundUpdate: isBackgroundUpdate, progressHandler: progressHandler)
                    }
                    
                } else if let data = response.data { // Unpack the bundle as it's already been downloaded
                    
                    if let url = response.httpResponse?.url?.absoluteString {
                        if let contentControllerLog = self?.contentControllerLog {
                            baymax_log("Downloading update bundle: \(url)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
                            os_log("Downloading update bundle: %@", log: contentControllerLog, type: .debug, url)
                        }
                    } else {
                        if let contentControllerLog = self?.contentControllerLog {
                            baymax_log("Downloading update bundle", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
                            os_log("Downloading update bundle", log: contentControllerLog, type: .debug)
                        }
                    }
                    
                    if let deltaDirectory = self?.deltaDirectory {
                        self?.saveBundleData(data: data, finalDestination: deltaDirectory, isBackgroundUpdate: isBackgroundUpdate)
                    } else {
                        self?.callProgressHandlers(with: .downloading, error: ContentControllerError.noDeltaDirectory)
                    }
                    
                } else { // Otherwise the response was invalid
                    
                    if let contentControllerLog = self?.contentControllerLog {
                        baymax_log("Received an invalid response from update endpoint", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
                        os_log("Received an invalid response from update endpoint", log: contentControllerLog, type: .error)
                    }
                    self?.callProgressHandlers(with: .checking, error: ContentControllerError.invalidResponse)
                    progressHandler?(.checking, 0, 0, ContentControllerError.invalidResponse)
                }
                
            } else {
                
                if let contentControllerLog = self?.contentControllerLog {
                    baymax_log("No response received from update endpoint", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
                    os_log("No response received from update endpoint", log: contentControllerLog, type: .error)
                }
                self?.callProgressHandlers(with: .checking, error: ContentControllerError.noResponseReceived)
            }
        }
    }
    
    private func callProgressHandlers(with stage: UpdateStage, error: Error?, amountDownloaded: Int = 0, totalToDownload: Int = 0) {
        
        progressHandlers.forEach { (handler) in
            handler(stage, amountDownloaded, totalToDownload, error)
        }
        
        if stage == .finished || error != nil {
        
            // No new content
            if let contentControllerError = error as? ContentControllerError, contentControllerError == .noNewContentAvailable {
                self.showFeedback(title: "No New Content", message: "There is no new content available from the CMS")
            } else if let error = error {
                // Other error
                self.showFeedback(title: "Content Update Failed", message: "Content update failed with error: \(error.localizedDescription)")
            } else {
                // Succeeded
                self.showFeedback(title: "New Content Downloaded", message: "The latest content was downloaded sucessfully")
            }
            
            isCheckingForUpdates = false
            progressHandlers = []
        }
    }
    
    /// Moves bundle file to a temporary directory
    ///
    /// - Parameters:
    ///   - originalURL: The url to the bundle to move
    ///   - finalDestination: The final destination of the bundle
    ///   - setAsInitialBundle: Whether the timestamp of the bundle once retrieved should be set as the "initial bundle" timestamp of the app
    ///   - completion: A closure called once the process has completed
    ///   - isBackgroundUpdate: Whether the update is happening as result of one of Apple's background refresh mechanisms
    private func saveBundleFile(at originalURL: URL, finalDestination: URL, setAsInitialBundle: Bool = false, isBackgroundUpdate: Bool = false, completion: (() -> Void)?) {
        
        // Make sure we have a cache directory and temp directory and url
        guard let temporaryUpdateDirectory = temporaryUpdateDirectory else {
            baymax_log("No temp update directory found", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .fault)
            os_log("No temp update directory found", log: contentControllerLog, type: .fault)
            callProgressHandlers(with: .unpacking, error: ContentControllerError.noDeltaDirectory)
            completion?()
            return
        }
        
        let cacheTarFileURL = temporaryUpdateDirectory.appendingPathComponent("data.tar.gz")
        let fileManager = FileManager.default
        
        // Write the data to cache url
        do {
            
            try fileManager.copyItem(at: originalURL, to: cacheTarFileURL)
            // Unpack the bundle
            self.unpackBundle(from: temporaryUpdateDirectory, into: finalDestination, isBackgroundUpdate: isBackgroundUpdate, completion: completion)
            
        } catch let error {
            
            completion?()
            baymax_log("Failed to copy update bundle to temporary directory: \(error.localizedDescription)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
            os_log("Failed to copy update bundle to temporary directory", log: contentControllerLog, type: .error)
            callProgressHandlers(with: .unpacking, error: error)
        }
    }
    
    /// Saves bundle data to a temporary directory
    ///
    /// - Parameters:
    ///   - data: The raw data downloaded from the storm CMS (This is a tar.gz file)
    ///   - finalDestination: The directory to which the bundle should be unpacked if possible
    ///   - setAsInitialBundle: Whether the timestamp of the bundle once retrieved should be set as the "initial bundle" timestamp of the app
    ///   - isBackgroundUpdate: Whether the update is happening as result of one of Apple's background refresh mechanisms
    private func saveBundleData(data: Data, finalDestination: URL, setAsInitialBundle: Bool = false, isBackgroundUpdate: Bool = false) {
        
        // Make sure we have a cache directory and temp directory and url
        guard let temporaryUpdateDirectory = temporaryUpdateDirectory else {
            baymax_log("No temp update directory found", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .fault)
            os_log("No temp update directory found", log: contentControllerLog, type: .fault)
            callProgressHandlers(with: .unpacking, error: ContentControllerError.noDeltaDirectory)
            return
        }
        
        let cacheTarFileURL = temporaryUpdateDirectory.appendingPathComponent("data.tar.gz")
        
        // Write the data to cache url
        do {
            
            try data.write(to: cacheTarFileURL, options: .atomic)
            
            // Unpack the bundle
            self.unpackBundle(from: temporaryUpdateDirectory, into: finalDestination, isBackgroundUpdate: isBackgroundUpdate)
            
        } catch let error {
            
            baymax_log("Failed to write update bundle to disk: \(error.localizedDescription)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
            os_log("Failed to write update bundle to disk", log: contentControllerLog, type: .error)
            callProgressHandlers(with: .unpacking, error: error)
        }
    }
    
    //MARK: -
    //MARK: Background Updates!
    
    static let BundleURLNotificationKey = "filename"
    
    static let BundleTimestampNotificationKey = "timestamp"
    
    static let BundleLatestLandmarkNotificationKey = "latestLandmarkTimestamp"
    
    var backgroundRequestController: BackgroundRequestController?
    
    private static let bgTaskIdentifier = "com.3sidedcube.thundercloud.contentrefresh"
    
    private var bgTaskListenerRegistered = false
    
    @available(iOS 13.0, *)
    private func registerBGTaskListeners() {
        
        guard !bgTaskListenerRegistered else {
            baymax_log("BGAppRefreshTask listener already registered, skipping", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .info)
            os_log("BGAppRefreshTask listener already registered, skipping", log: self.contentControllerLog, type: .info)
            return
        }
        
        bgTaskListenerRegistered = BGTaskScheduler.shared.register(forTaskWithIdentifier: ContentController.bgTaskIdentifier, using: nil) { [weak self] (task) in
            guard let self = self else { return }
            guard let bgRefreshTask = task as? BGAppRefreshTask else {
                baymax_log("Task is not BGAppRefreshTask, ignoring", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
                os_log("Task is not BGAppRefreshTask, ignoring", log: self.contentControllerLog, type: .error)
                task.setTaskCompleted(success: false)
                return
            }
            self.handleBackgroundDownloadTask(bgRefreshTask)
        }
        
        if bgTaskListenerRegistered {
            baymax_log("Background task launch handler registered with BGTaskScheduler", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .info)
            os_log("Background task launch handler registered with BGTaskScheduler", log: contentControllerLog, type: .info)
        } else {
            baymax_log("Failed to register launch handler. If you want to enable scheduled background downloads of storm content, please add \(ContentController.bgTaskIdentifier) to your info.plist's `BGTaskSchedulerPermittedIdentifiers` array", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .info)
            os_log("Failed to register launch handler. If you want to enable scheduled background downloads of storm content, please add %@ to your info.plist's `BGTaskSchedulerPermittedIdentifiers` array", log: contentControllerLog, type: .info, ContentController.bgTaskIdentifier)
        }
    }
    
    /// Performs a background fetch, this should be called from `application:performFetchWithCompletionHandler`
    /// - Parameter completionHandler: The closure to be called when the background fetch has completed
    public func performBackgroundFetch(completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        guard !isCheckingForUpdates else {
            baymax_log("Already checking for updates, ignoring further request", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
            os_log("Already checking for updates, ignoring further request", log: contentControllerLog, type: .debug)
            onTaskCompleted = { success in
                completionHandler(success ? .newData : .noData)
            }
            return
        }
        
        ContentController.shared.checkForUpdates(isBackgroundUpdate: true) { (stage, _, _, error) -> (Void) in
            
            // If we got an error, handle it properly
            if let error = error {
                
                guard let contentControllerError = error as? ContentControllerError else {
                    completionHandler(.failed)
                    return
                }
                
                switch contentControllerError {
                    // No content available error should trigger .noData
                case .noNewContentAvailable:
                    completionHandler(.noData)
                default:
                    completionHandler(.failed)
                }
                
            } else {
                
                switch stage {
                    // If we reach the finished or preparing phase, then we can call completionHandler
                    // and rely on background download API. Finished is if we directly download the bundle
                    // by hitting /bundle, preparing is if we need to make a further API call
                case .finished, .preparing:
                    completionHandler(.newData)
                default:
                    break
                }
            }
        }
    }
    
    private var backgroundIntervalRange: Range<TimeInterval>? {
        set {
            guard let newValue = newValue else {
                UserDefaults.standard.removeObject(forKey: "TSCBackgroundRefreshIntervalMin")
                UserDefaults.standard.removeObject(forKey: "TSCBackgroundRefreshIntervalMax")
                return
            }
            UserDefaults.standard.set(newValue.lowerBound, forKey: "TSCBackgroundRefreshIntervalMin")
            UserDefaults.standard.set(newValue.upperBound, forKey: "TSCBackgroundRefreshIntervalMax")
        }
        get {
            guard let upperBoundObject = UserDefaults.standard.object(forKey: "TSCBackgroundRefreshIntervalMax"), let upperBound = TimeInterval(upperBoundObject) else {
                return nil
            }
            guard let lowerBoundObject = UserDefaults.standard.object(forKey: "TSCBackgroundRefreshIntervalMin"), let lowerBound = TimeInterval(lowerBoundObject) else {
                return nil
            }
            return lowerBound..<upperBound
        }
    }
    
    private func restartBGAppRefreshTask() {
        guard let backgroundIntervalRange = backgroundIntervalRange else { return }
        scheduleBackgroundUpdates(minimumFetchIntervalRange: backgroundIntervalRange)
    }
    
    /// Stops the recurring background interval updates
    ///
    /// If in a previous version you initiated background interval updates, they may continue automatically
    /// because Storm has to store the interval range you initiated them with. If you want to forcibly end
    /// scheduled background updates, you have to call this method
    public func stopBackgroundIntervalUpdates() {
        backgroundIntervalRange = nil
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: ContentController.bgTaskIdentifier)
        }
    }
    
    /// Schedules background refresh update at a random point in the range of TimeIntervals provided. This will use the appropriate API based on the iOS version the app is running and may behave differently
    /// between OS versions.
    /// - Parameter minimumFetchIntervalRange: The range of time intervals to schedule at, defaults to `4hr ..< 6hr`
    public func scheduleBackgroundUpdates(minimumFetchIntervalRange: Range<TimeInterval> = (4 * .hour)..<(6 * .hour)) {
        
        backgroundIntervalRange = minimumFetchIntervalRange
        
        let fetchInterval = TimeInterval.random(in: minimumFetchIntervalRange)
        
        baymax_log("Scheduling background updates with minimum fetch interval \(fetchInterval)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("Handling events for background url session: %f", log: contentControllerLog, type: .debug, fetchInterval)
        
        if #available(iOS 13.0, *) {
            
            let request = BGAppRefreshTaskRequest(identifier: ContentController.bgTaskIdentifier)
            request.earliestBeginDate = Date(timeIntervalSinceNow: fetchInterval)
            
            do {
                BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: ContentController.bgTaskIdentifier)
                try BGTaskScheduler.shared.submit(request)
            } catch {
                baymax_log("Failed to schedule app refresh: \(error.localizedDescription)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
                os_log("Failed to schedule app refresh: %@", log: contentControllerLog, type: .error, error.localizedDescription)
            }
            
        } else {
            
            UIApplication.shared.setMinimumBackgroundFetchInterval(fetchInterval)
        }
    }
    
    private var onTaskCompleted: ((Bool) -> Void)?
    
    @available(iOS 13.0, *)
    private func handleBackgroundDownloadTask(_ task: BGAppRefreshTask) {
        
        baymax_log("Handling BGAppRefreshTask", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("Handling BGAppRefreshTask", log: contentControllerLog, type: .debug)
        
        // According to a medium article, we can restart this as soon as our handler is called!
        defer {
            restartBGAppRefreshTask()
        }
        
        guard !isCheckingForUpdates else {
            baymax_log("Already checking for updates, ignoring BGAppRefreshTask", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
            os_log("Already checking for updates, ignoring BGAppRefreshTask", log: contentControllerLog, type: .debug)
            onTaskCompleted = { success in
                task.setTaskCompleted(success: success)
            }
            return
        }
        
        ContentController.shared.checkForUpdates(isBackgroundUpdate: true) { [weak self] (stage, _, _, error) -> (Void) in
            
            // If we got an error, handle it properly
            if let error = error {
                
                guard let contentControllerError = error as? ContentControllerError else {
                    baymax_log("Check for updates errored, setting BGAppRefreshTask completed (false)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
                    if let self = self {
                        os_log("Check for updates errored, setting BGAppRefreshTask completed (false)", log: self.contentControllerLog, type: .debug)
                    }
                    task.setTaskCompleted(success: false)
                    return
                }
                
                switch contentControllerError {
                case .noNewContentAvailable:
                    // Seems to be we should set this to true even if no new content available
                    baymax_log("No new content available, setting BGAppRefreshTask completed (true)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
                    if let self = self {
                        os_log("No new content available, setting BGAppRefreshTask completed (true)", log: self.contentControllerLog, type: .debug)
                    }
                    task.setTaskCompleted(success: true)
                default:
                    baymax_log("\(contentControllerError.localizedDescription), setting BGAppRefreshTask completed (false)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
                    if let self = self {
                        os_log("%@, Setting BGAppRefreshTask completed (false)", log: self.contentControllerLog, type: .debug, contentControllerError.localizedDescription)
                    }
                    task.setTaskCompleted(success: false)
                }
                
            } else {
                
                switch stage {
                    // If we reach the finished or preparing phase, then we can call completionHandler
                    // and rely on background download API. Finished is if we directly download the bundle
                    // by hitting /bundle, preparing is if we need to make a further API call
                case .finished, .preparing:
                    baymax_log("Update check finished/preparing, setting BGAppRefreshTask completed (true)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
                    if let self = self {
                        os_log("Update check finished/preparing, setting BGAppRefreshTask completed (true)", log: self.contentControllerLog, type: .debug)
                    }
                    task.setTaskCompleted(success: true)
                default:
                    break
                }
            }
        }
    }
    
    /// Calls and destroys background download completion handler!
    private func callBackgroundDownloadCompletionHandler() {
        baymax_log("Calling background completion handler to let system know we're done handling background download events", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("Calling background completion handler to let system know we're done handling background download events", log: contentControllerLog, type: .debug)
        backgroundDownloadCompletionHandler?()
        backgroundDownloadCompletionHandler = nil
    }
    
    /// We have to store this according to [Apple's docs](https://developer.apple.com/documentation/foundation/url_loading_system/downloading_files_in_the_background)
    var backgroundDownloadCompletionHandler: (() -> Void)?
    
    /// Handles events for background url sessions
    /// - Parameters:
    ///   - identifier: The background session identifier
    ///   - completionHandler: A closure to be called when everything is done with!
    public func handleEventsForBackgroundURLSession(session identifier: String, completionHandler: @escaping () -> Void) {
        
        baymax_log("Handling events for background url session: \(identifier)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("Handling events for background url session: %@", log: contentControllerLog, type: .debug, identifier)
        
        guard let destinationDirectory = deltaDirectory else {
            baymax_log("Can't save background bundle download as delta directory not available", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .fault)
            os_log("Can't save background bundle download as delta directory not available", log: contentControllerLog, type: .fault)
            completionHandler()
            return
        }
        
        showFeedback(title: "Background Download Finished", message: "Validating and copying new bundle to the correct directory")
        
        // Save this for later!
        backgroundDownloadCompletionHandler = completionHandler
        
        // First off we need to make sure our `downloadRequestController` that we used to issue this request isn't still around in memory! If it is
        // then we can continue using it, see comment from Apple Technical Support:
        //
        // If you have already created a background URLSession and you recreate a new background session without invalidating the previous,
        // then this could explain the lost connection message you are seeing.  You can also run into this if you have an extension accessing
        // the same background identifier.
        
        guard downloadRequestController?.backgroundSessionIdentifier != identifier else {
            baymax_log("`RequestController` which made original request is still available, skipping creating new `URLSession` for background events", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
            os_log("`RequestController` which made original request is still available, skipping creating new `URLSession` for background events", log: contentControllerLog, type: .debug, identifier)
            return
        }
        
        // This logic assumes that the destination directory for any storm bundles is the delta directory. This is currently the case for `ThunderCloud` itself,
        // and all 3 Sided Cube apps which download bundles themselves. If you are distributing a storm app which doesn't save to the delta directory then some
        // work will need to be done here!
        
        baymax_log("Starting background request controller", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("Starting background request controller", log: contentControllerLog, type: .debug, identifier)
        
        backgroundRequestController = BackgroundRequestController(identifier: identifier, responseHandler: { [weak self] (task, response, error) in
            
            guard let self = self else { return }
            
            guard let fileURL = response?.fileURL else {
                baymax_log("No file url from background request controller for task with error:\n\(error?.localizedDescription ?? "null")", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
                os_log("No file url from background request controller for task with error:\n%@", log: self.contentControllerLog, type: .error, error?.localizedDescription ?? "null")
                return
            }
            
            baymax_log("Got file back from background request controller, saving to: \(destinationDirectory.absoluteString)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
            os_log("Got file back from background request controller, saving to: %@", log: self.contentControllerLog, type: .error, destinationDirectory.absoluteString)
            
            self.saveBundleFile(at: fileURL, finalDestination: destinationDirectory, isBackgroundUpdate: true) { [weak self] in
                guard let self = self else { return }
                OperationQueue.main.addOperation { [weak self] in
                    self?.callBackgroundDownloadCompletionHandler()
                }
            }
            
        }, finishedHandler: { [weak self] (session) in
            
            guard let self = self else { return }
            
            baymax_log("Background request controller finished", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .info)
            os_log("Background request controller finished", log: self.contentControllerLog, type: .info)
            
            self.backgroundRequestController = nil
        },
           readDataAutomatically: false // Don't read to data as we're limited to 40mb in background transfer Daemon
        )
    }
    
    /// Downloads a storm bundle from a given content available push notification
    ///
    /// - parameter
    public func downloadBundle(forNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        defer {
            restartBGAppRefreshTask()
        }
                
        guard !isCheckingForUpdates else {
            baymax_log("Already checking for updates, ignoring content-available push", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .info)
            os_log("Already checking for updates, ignoring content-available push", log: contentControllerLog, type: .info)
            completionHandler(.newData)
            return
        }
        
        guard !DeveloperModeController.appIsInDevMode else {
            baymax_log("App in \"test\" content mode, ignoring content-available push so it doesn't override test content", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .info)
            os_log("App in \"test\" content mode, ignoring content-available push so it doesn't override test content", log: contentControllerLog, type: .info)
            completionHandler(.noData)
            return
        }
        
        let currentStatus = TSCReachability.forInternetConnection().currentReachabilityStatus()
        guard !ContentController.onlyDownloadOverWifi || currentStatus == ReachableViaWiFi else {
            baymax_log("Ignoring content-available push as download over mobile network disabled by user", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .info)
            os_log("Ignoring content-available push as download over mobile network disabled by user", log: contentControllerLog, type: .info)
            completionHandler(.noData)
            return
        }
        
        baymax_log("Handling content-available notification", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("Handling content-available notification", log: contentControllerLog, type: .debug)
        
        guard let payload = userInfo["payload"] as? [AnyHashable : Any] else {
            baymax_log("No 'payload' object found in push notification payload", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
            os_log("No 'payload' object found in push notification payload", log: contentControllerLog, type: .error)
            completionHandler(.noData)
            return
        }
        
        // Get the bundle URL directly from the notification
        guard let urlString = payload[ContentController.BundleURLNotificationKey] as? String, let url = URL(string: urlString) else {
            baymax_log("No bundle URL or invalid bundle URL in notification payload", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
            os_log("No bundle URL or invalid bundle URL in notification payload", log: contentControllerLog, type: .error)
            completionHandler(.noData)
            return
        }
        
        // Get the timestamp of the bundle from the notification
        guard let timestampObject = payload[ContentController.BundleTimestampNotificationKey], let timestamp = TimeInterval(timestampObject) else {
            baymax_log("No bundle timestamp present in notification payload", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
            os_log("No bundle timestamp present in notification payload", log: contentControllerLog, type: .error)
            completionHandler(.noData)
            return
        }
        
        // Make sure we're not downloading a bundle we shouldn't due to landmark publish!
        baymax_log("Making sure notification bundle isn't after a landmark publish this app shouldn't receive", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("Making sure notification bundle isn't after a landmark publish this app shouldn't receive", log: contentControllerLog, type: .debug)
        if let latestLandmarkObject = payload[ContentController.BundleLatestLandmarkNotificationKey], let latestLandmarkTimestamp = TimeInterval(latestLandmarkObject) {
            
            // If we have an original bundle timestamp (That the app was released with), check we're not updating beyond the landmark!
            if let originalBundleTimestamp = initialBundleTimestamp, originalBundleTimestamp < latestLandmarkTimestamp {
                baymax_log("Ignoring content-available bundle as there is a landmark publish at \(latestLandmarkTimestamp) which this app's original bundle: \(originalBundleTimestamp) should not receive", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
                os_log("Ignoring content-available bundle as there is a landmark publish at %f which this app's original bundle: %f should not receive", log: contentControllerLog, type: .debug, latestLandmarkTimestamp, originalBundleTimestamp)
                completionHandler(.noData)
                return
            }
            
            baymax_log("Okay to download content-available bundle as initial bundle timestamp is either not available, or there is no landmark publish between the new bundle and the original content bundle", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
            os_log("Okay to download content-available bundle as initial bundle timestamp is either not available, or there is no landmark publish between the new bundle and the original content bundle", log: contentControllerLog, type: .debug)
            
        } else {
            
            baymax_log("No landmark timestamp provided in notification", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
            os_log("No landmark timestamp provided in notification", log: contentControllerLog, type: .debug)
        }
        
        baymax_log("Checking notification timestamp against latest on-disk bundle version", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("Checking notification timestamp against latest on-disk bundle version", log: contentControllerLog, type: .debug)
        
        // Make sure we're not downloading older data than we already have!
        guard timestamp > latestBundleTimestamp else {
            baymax_log("On-disk bundle (\(latestBundleTimestamp)) is newer or same as the notification's bundle (\(timestamp)), skipping download.", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
            os_log("On-disk bundle (%f) is newer or same as the notification's bundle (%f), skipping download.", log: contentControllerLog, type: .debug, latestBundleTimestamp, timestamp)
            completionHandler(.noData)
            return
        }
        
        guard let destinationURL = deltaDirectory else {
            baymax_log("Can't download bundle as delta directory not available", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .fault)
            os_log("Can't download bundle as delta directory not available", log: contentControllerLog, type: .fault)
            completionHandler(.failed)
            return
        }
        
        isCheckingForUpdates = true
        
        baymax_log("Downloading content-available bundle with timestamp: \(timestamp)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("Downloading content-available bundle with timestamp: %f", log: contentControllerLog, type: .debug, timestamp)
        
        showFeedback(title: "Content Available Notification Received", message: "Downloading new bundle from the CMS")
                
        // We'll send off a background download request!
        downloadPackage(fromURL: url, destinationDirectory: destinationURL, isBackgroundUpdate: true) { (stage, _, _, error) -> (Void) in
            guard error == nil else {
                completionHandler(.failed)
                return
            }
            guard stage == .finished else {
                return
            }
            completionHandler(.newData)
        }
        
        completionHandler(.newData)
    }
    
    /// Downloads a storm bundle from a specific url
    ///
    /// - parameter fromURL: The url to download the bundle from
    /// - parameter destinationDirectory: The directory to download the bundle into
    /// - parameter inBackground: Whether the download of the bundle should be run as a background task, defaults to tru, as should behave normally in foreground anyway!
    /// - parameter setAsInitialBundle: If set to true, the timestamp of the bundle will be saved in the user defaults and will act as the app's "Bundled with" timestamp
    /// - parameter progressHandler: A closure which will be alerted of the progress of the download
    /// - parameter isBackgroundUpdate: Whether the update is happening as result of one of Apple's background refresh mechanisms
    public func downloadPackage(fromURL: URL, destinationDirectory: URL, inBackground: Bool = true, setAsInitialBundle: Bool = false, isBackgroundUpdate: Bool = false, progressHandler: ContentUpdateProgressHandler?) {
        
        baymax_log("Downloading bundle: \(fromURL.absoluteString)\nDestination: \(destinationDirectory.absoluteString)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("Downloading bundle: %@\nDestination: %@", log: contentControllerLog, type: .debug, fromURL.absoluteString, destinationDirectory.absoluteString)
        
        if let progressHandler = progressHandler {
            progressHandlers.append(progressHandler)
        }
        
        if DeveloperModeController.devModeOn, let authorization = AuthenticationController().authentication {
            downloadRequestController?.sharedRequestHeaders["Authorization"] = authorization.token
        }
        
        downloadRequestController?.sharedRequestHeaders["User-Agent"] = Storm.UserAgent
        
        downloadRequestController?.download(nil, inBackground: inBackground, tag: DOWNLOAD_REQUEST_TAG, overrideURL: fromURL, progress: { [weak self] (progress, totalBytes, bytesTransferred) in
            self?.callProgressHandlers(with: .downloading, error: nil, amountDownloaded: Int(bytesTransferred), totalToDownload: Int(totalBytes))
        }) { [weak self] (response, url, error) in
            
            guard let self = self else { return }
            
            if let error = error {
                baymax_log("Downloading bundle failed: \(error.localizedDescription)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
                os_log("Downloading bundle failed: %@", log: self.contentControllerLog, type: .error, error.localizedDescription)
                self.callBackgroundDownloadCompletionHandler()
                self.callProgressHandlers(with: .downloading, error: error)
                return
            }
            
            guard let url = url else {
                
                baymax_log("No bundle data returned", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
                os_log("No bundle data returned", log: self.contentControllerLog, type: .error)
    
                self.callBackgroundDownloadCompletionHandler()
                self.callProgressHandlers(with: .downloading, error: ContentControllerError.invalidResponse)
                return
            }
            
            self.saveBundleFile(at: url, finalDestination: destinationDirectory, setAsInitialBundle: setAsInitialBundle, isBackgroundUpdate: isBackgroundUpdate, completion: { [weak self] in
                guard let self = self else { return }
                OperationQueue.main.addOperation { [weak self] in
                    self?.callBackgroundDownloadCompletionHandler()
                }
            })
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
    /// - parameter directory: The directory to read bundle data from
    /// - parameter destinationDirectory: The directory to write the unpacked bundle data to
    /// - parameter setAsInitialBundle: Whether the timestamp of the bundle once retrieved should be set as the "initial bundle" timestamp of the app
    /// - parameter completion: A closure called when the unpacking has either finished or failed
    /// - parameter isBackgroundUpdate: Whether the update is happening as result of one of Apple's background refresh mechanisms
    private func unpackBundle(from directory: URL, into destinationDirectory: URL, setAsInitialBundle: Bool = false, isBackgroundUpdate: Bool = false, completion: (() -> Void)? = nil) {
        
        baymax_log("Unpacking bundle...", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("Unpacking bundle...", log: contentControllerLog, type: .debug)
        
        callProgressHandlers(with: .unpacking, error: nil)
        
        let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
        
        backgroundQueue.async {
            
            let fileUrl = directory.appendingPathComponent("data.tar.gz")
            let archive = "data.tar"
            let tarUrl = directory.appendingPathComponent(archive)
            
            baymax_log("Attempting to gunzip data from data.tar.gz", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
            os_log("Attempting to gunzip data from data.tar.gz", log: self.contentControllerLog, type: .debug)
            
            do {
                
                try gunzip(fileUrl, to: tarUrl)
                
                baymax_log("Gunzip successful", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
                os_log("Gunzip successful", log: self.contentControllerLog, type: .debug)
                
                // We bridge to Objective-C here as the untar doesn't like switch CString struct
                baymax_log("Attempting to untar the bundle", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
                os_log("Attempting to untar the bundle", log: self.contentControllerLog, type: .debug)
                let arch = fopen((directory.appendingPathComponent(archive).path as NSString).cString(using: String.Encoding.utf8.rawValue), "r")

                untar(arch, (directory.path as NSString).cString(using: String.Encoding.utf8.rawValue))

                fclose(arch)
                baymax_log("Untar successful", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
                os_log("Untar successful", log: self.contentControllerLog, type: .debug)

                // Verify bundle
                let verification = self.verifyBundle(in: directory)

                guard verification.isValid else {
                   self.removeCorruptDeltaBundle(in: directory)
                    completion?()
                   return
                }

                // If we got a timestamp back from verification and this should be used to set initial bundle
                if let timestamp = verification.timestamp, setAsInitialBundle {
                   self.initialBundleTimestamp = timestamp
                }

                let fm = FileManager.default
                do {
                   
                   // Remove unzip files
                   baymax_log("Cleaning up `data.tar.gz` and `data.tar` files", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
                   os_log("Cleaning up `data.tar.gz` and `data.tar` files", log: self.contentControllerLog, type: .debug)
                   try fm.removeItem(at: directory.appendingPathComponent("data.tar.gz"))
                   try fm.removeItem(at: directory.appendingPathComponent("data.tar"))
                   
                } catch {
                   
                   // Copy bundle to destination directory and then clear up the directory it was unpacked in
                   self.copyValidBundle(from: directory, to: destinationDirectory, isBackgroundUpdate: isBackgroundUpdate)
                   self.removeBundle(in: directory)
                    completion?()
                   return
                }

                // Copy bundle to destination directory and then clear up the directory it was unpacked in
                self.copyValidBundle(from: directory, to: destinationDirectory, isBackgroundUpdate: isBackgroundUpdate)
                self.removeBundle(in: directory)
                completion?()
                
            } catch {
                
                baymax_log("gunzip failed with error: \(error.localizedDescription)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .fault)
                os_log("gunzip failed with error: %@", log: self.contentControllerLog, type: .fault, error.localizedDescription)
                completion?()
                self.callProgressHandlers(with: .unpacking, error: ContentControllerError.gunzipFailed)
            }
        }
    }
    
    
    
    //MARK: -
    //MARK: Verify Unpacked bundle
    private func verifyBundle(in directory: URL) -> (isValid: Bool, timestamp: TimeInterval?) {
        
        baymax_log("Verifying bundle...", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
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
            baymax_log("Failed to read manifest at path: \(temporaryUpdateManifestPathUrl.absoluteString)\nError: \(error.localizedDescription)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
            os_log("Failed to read manifest at path: %@\nError: %@", log: self.contentControllerLog, type: .error, temporaryUpdateManifestPathUrl.absoluteString, error.localizedDescription)
            return (false, nil)
        }
        
        var manifestJSON: Any
        
        // Serialize manifest into JSON
        baymax_log("Loading manifest.json into JSON object", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("Loading manifest.json into JSON object", log: self.contentControllerLog, type: .debug)
        do {
            manifestJSON = try JSONSerialization.jsonObject(with: manifestData, options: JSONSerialization.ReadingOptions.mutableContainers)
            
        } catch let error {
            
            callProgressHandlers(with: .verifying, error: ContentControllerError.invalidManifest)
            baymax_log("Failed to parse manifest.json as JSON: \(error.localizedDescription)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
            os_log("Failed to parse manifest.json as JSON: %@", log: self.contentControllerLog, type: .error, error.localizedDescription)
           return (false, nil)
        }
        
        baymax_log("Loading manifest.json as dictionary", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("Loading manifest.json as dictionary", log: self.contentControllerLog, type: .debug)
        guard let manifest = manifestJSON as? [String: Any] else {
            
            baymax_log("Can't cast manifest as dictionary", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
            os_log("Can't cast manifest as dictionary\n %@", log: self.contentControllerLog, type: .error, ContentControllerError.invalidManifest.localizedDescription)
            
            callProgressHandlers(with: .verifying, error: ContentControllerError.invalidManifest)
            return (false, nil)
        }
        
        if !self.fileExistsInBundle(file: "app.json") {
            
            baymax_log(ContentControllerError.missingAppJSON.localizedDescription, subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
            os_log("%@", log: self.contentControllerLog, type: .error, ContentControllerError.missingAppJSON.localizedDescription)
            
            callProgressHandlers(with: .verifying, error: ContentControllerError.missingAppJSON)
            return (false, nil)
        }
        baymax_log("app.json exists", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("app.json exists", log: self.contentControllerLog, type: .debug)
        
        if !self.fileExistsInBundle(file: "manifest.json") {
            
            baymax_log(ContentControllerError.missingManifestJSON.localizedDescription, subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
            os_log("%@", log: self.contentControllerLog, type: .error, ContentControllerError.missingManifestJSON.localizedDescription)
            
            callProgressHandlers(with: .verifying, error: ContentControllerError.missingManifestJSON)
            return (false, nil)
        }
        baymax_log("manifest.json exists", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("manifest.json exists", log: self.contentControllerLog, type: .debug)
        
        // Verify pages
        baymax_log("Verifying pages", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("Verifying pages", log: self.contentControllerLog, type: .debug)
        guard let pages = manifest["pages"] as? [[String: Any]] else {
            
            baymax_log(ContentControllerError.manifestMissingPages.localizedDescription, subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
            os_log("%@", log: self.contentControllerLog, type: .error, ContentControllerError.manifestMissingPages.localizedDescription)
            callProgressHandlers(with: .verifying, error: ContentControllerError.manifestMissingPages)
            return (false, nil)
        }
        
        for page in pages {
            
            guard let source = page["src"] as? String else {
                
                baymax_log("\(ContentControllerError.pageWithoutSRC.localizedDescription)\n\(page)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
                os_log("%@\n%@", log: self.contentControllerLog, type: .error, ContentControllerError.pageWithoutSRC.localizedDescription, page)
                callProgressHandlers(with: .verifying, error: ContentControllerError.pageWithoutSRC)
                return (false, nil)
            }
            
            // No baymax log to reduce log file sizes!
            os_log("%@ has a valid 'src'", log: self.contentControllerLog, type: .debug, source)
            
            let pageFile = "pages/\(source)"
            if !self.fileExistsInBundle(file: pageFile) {
                
                baymax_log("\(ContentControllerError.missingFile.localizedDescription)\n\(page)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
                os_log("%@\n%@", log: self.contentControllerLog, type: .error, ContentControllerError.missingFile.localizedDescription, page)
                callProgressHandlers(with: .verifying, error: ContentControllerError.missingFile)
                return (false, nil)
            }
            // No baymax log to reduce log file sizes!
            os_log("%@ exists in the bundle", log: self.contentControllerLog, type: .debug, source)
        }
        
        //Verify languages
        baymax_log("Verifying languages", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("Verifying languages", log: self.contentControllerLog, type: .debug)
        guard let languages = manifest["languages"] as? [[String: Any]] else {
            
            baymax_log(ContentControllerError.manifestMissingLanguages.localizedDescription, subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
            os_log("%@", log: self.contentControllerLog, type: .error, ContentControllerError.manifestMissingLanguages.localizedDescription)
            callProgressHandlers(with: .verifying, error: ContentControllerError.manifestMissingLanguages)
            return (false, nil)
        }
        
        for language in languages {
            guard let source = language["src"] as? String else {
                baymax_log("\(ContentControllerError.languageWithoutSRC.localizedDescription)\n\(language)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
                os_log("%@\n%@", log: self.contentControllerLog, type: .error, ContentControllerError.languageWithoutSRC.localizedDescription, language)
                callProgressHandlers(with: .verifying, error: ContentControllerError.languageWithoutSRC)
                return (false, nil)
            }
            // No baymax log to reduce log file sizes!
            os_log("%@ has a valid 'src'", log: self.contentControllerLog, type: .debug, source)
            
            let pageFile = "languages/\(source)"
            if !self.fileExistsInBundle(file: pageFile) {
                
                baymax_log("\(ContentControllerError.missingFile.localizedDescription)\n\(language)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
                os_log("%@\n%@", log: self.contentControllerLog, type: .error, ContentControllerError.missingFile.localizedDescription, language)
                callProgressHandlers(with: .verifying, error: ContentControllerError.languageWithoutSRC)
                return (false, nil)
            }
            // No baymax log to reduce log file sizes!
            os_log("%@ exists in the bundle", log: self.contentControllerLog, type: .debug, source)
        }
        
        //Verify Content
        baymax_log("Verifying content", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("Verifying Content", log: self.contentControllerLog, type: .debug)
        guard let contents = manifest["content"] as? [[String: Any]] else {
            
            baymax_log(ContentControllerError.manifestMissingContent.localizedDescription, subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
            os_log("%@", log: self.contentControllerLog, type: .error, ContentControllerError.manifestMissingContent.localizedDescription)
            callProgressHandlers(with: .verifying, error: ContentControllerError.manifestMissingContent)
            return (false, nil)
        }
        
        for content in contents {
            
            guard let source = content["src"] as? String else {
                baymax_log("\(ContentControllerError.contentWithoutSRC.localizedDescription)\n\(content)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
                os_log("%@\n%@", log: self.contentControllerLog, type: .error, ContentControllerError.contentWithoutSRC.localizedDescription, content)
                callProgressHandlers(with: .verifying, error: ContentControllerError.contentWithoutSRC)
                return (false, nil)
            }
            // No baymax log to reduce log file sizes!
            os_log("%@ has a valid 'src'", log: self.contentControllerLog, type: .debug, source)
            
            let pageFile = "content/\(source)"
            if !self.fileExistsInBundle(file: pageFile) {
                
                baymax_log("\(ContentControllerError.missingFile.localizedDescription)\n\(content)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
                os_log("%@\n%@", log: self.contentControllerLog, type: .error, ContentControllerError.missingFile.localizedDescription, content)
                callProgressHandlers(with: .verifying, error: ContentControllerError.contentWithoutSRC)
                return (false, nil)
            }
            // No baymax log to reduce log file sizes!
            os_log("%@ exists in the bundle", log: self.contentControllerLog, type: .debug, source)
        }
        
        baymax_log("Bundle is valid", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("Bundle is valid", log: self.contentControllerLog, type: .debug)
        return (true, manifest["timestamp"] as? TimeInterval)
    }
    
    private func removeCorruptDeltaBundle(in directory: URL) {
        
        let fm = FileManager.default
        
        if let attributes = try? fm.attributesOfItem(atPath: directory.appendingPathComponent("data.tar.gz").path), let fileSize = attributes[FileAttributeKey.size] as? UInt64 {
            baymax_log("Removing corrupt delta bundle of size: \(fileSize) bytes", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
            os_log("Removing corrupt delta bundle of size: %lu bytes", log: self.contentControllerLog, type: .error, fileSize)
        } else {
            baymax_log("Removing corrupt delta bundle", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
            os_log("Removing corrupt delta bundle", log: self.contentControllerLog, type: .error)
        }
        
        do {
            try fm.removeItem(at: directory.appendingPathComponent("data.tar.gz"))
            try fm.removeItem(at: directory.appendingPathComponent("data.tar"))
        } catch let error {
            baymax_log("Failed to remove corrupt delta update: \(error.localizedDescription)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
            os_log("Failed to remove corrupt delta update: %@", log: self.contentControllerLog, type: .error, error.localizedDescription)
        }
        
        removeBundle(in: directory)
    }
    
    func removeBundle(in directory: URL) {
        
        baymax_log("Removing bundle in directory: \(directory.absoluteString)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("Removing Bundle in directory: %@", log: contentControllerLog, type: .debug, directory.absoluteString)
        let fm = FileManager.default
        var files: [String] = []
        
        do {
            files = try fm.contentsOfDirectory(atPath: directory.path)
        } catch let error {
            baymax_log("Failed to get files for removing bundle in directory at path: \(directory.path)\nError: \(error.localizedDescription)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
            os_log("Failed to get files for removing bundle in directory at path: %@\nError: %@", log: self.contentControllerLog, type: .error, directory.path, error.localizedDescription)
        }
        
        files.forEach { (filePath) in
            
            do {
                try fm.removeItem(at: directory.appendingPathComponent(filePath))
            } catch let error {
                baymax_log("Failed to remove file at path:\(directory.path)/\(filePath)\nError: \(error.localizedDescription)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
                os_log("Failed to remove file at path: %@/%@\nError: %@", log: self.contentControllerLog, type: .error, directory.path, filePath, error.localizedDescription)
            }
        }
    }
    
    //MARK: -
    //MARK: - Copy valid bundle to it's FINAL DESTINATION
    
    private func copyValidBundle(from fromDirectory: URL, to toDirectory: URL, isBackgroundUpdate: Bool = false) {
        
        baymax_log("Copying bundle\nFrom: \(fromDirectory.absoluteString)\nTo: \(toDirectory.absoluteString)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("Copying bundle\nFrom: %@\nTo: %@", log: contentControllerLog, type: .debug, fromDirectory.absoluteString, toDirectory.absoluteString)
        
        let fm = FileManager.default
        
        callProgressHandlers(with: .copying, error: nil)
        
        guard let files = try? fm.contentsOfDirectory(atPath: fromDirectory.path) else {
            
            baymax_log("Copying bundle failed, couldn't get contents of directory", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .fault)
            os_log("Copying bundle failed, couldn't get contents of directory", log: contentControllerLog, type: .fault)
            
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
                    baymax_log("Failed to copy file into bundle: \(error.localizedDescription)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
                    os_log("Failed to copy file into bundle: %@", log: self.contentControllerLog, type: .error, error.localizedDescription)
                    callProgressHandlers(with: .copying, error: ContentControllerError.fileCopyFailed)
                }
                
            } else if fm.fileExists(atPath: fromDirectory.appendingPathComponent(file).path) {
                
                // Check if the sub folder exists in cache
                if !fm.fileExists(atPath: toDirectory.appendingPathComponent(file).path) {
                    do {
                        
                        try fm.createDirectory(at: toDirectory.appendingPathComponent(file), withIntermediateDirectories: true, attributes: nil)
                        
                    } catch let error {
                        
                        baymax_log("Failed to create directory: \(file) in bundle: \(error.localizedDescription)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
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
                        baymax_log("Failed to copy file into bundle: \(error.localizedDescription)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
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
        
        baymax_log("Update complete, Refreshing language", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("Update complete, Refreshing language", log: self.contentControllerLog, type: .debug)
        
        isCheckingForUpdates = false
        
        if isBackgroundUpdate, UIApplication.shared.applicationState == .background {
            baymax_log("Content downloaded in background, setting `newContentAvailableOnNextForeground` to true", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
            os_log("Content downloaded in background, setting `newContentAvailableOnNextForeground` to true", log: self.contentControllerLog, type: .debug)
            newContentAvailableOnNextForeground = true
        }
        
        StormLanguageController.shared.reloadLanguagePack()
        callProgressHandlers(with: .finished, error: nil)
        
        indexAppContent { (error) -> (Void) in
            
            if let error = error {
                baymax_log("Failed to re-index content: \(error.localizedDescription)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
                os_log("Failed to re-index content: %@", log: self.contentControllerLog, type: .error, error.localizedDescription)
            } else {
                baymax_log("Re-indexed content", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
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
        
        baymax_log("Beginning excluding from backup files in directory: \(directory.path)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("Beginning excluding from backup files in directory: %@", log: contentControllerLog, type: .debug, directory.path)
        
        let fm = FileManager.default
        
        fm.subpaths(atPath: directory.path)?.forEach({ (subFile) in
            
            // No baymax log to reduce log file sizes!
            os_log("Excluding: %@", log: contentControllerLog, type: .debug, subFile)
            do {
                var fileURL = directory.appendingPathComponent(subFile)
                if fm.fileExists(atPath: fileURL.path) {
                    var resourceValues = URLResourceValues()
                    resourceValues.isExcludedFromBackup = true
                    try fileURL.setResourceValues(resourceValues)
                }
            } catch let error {
                baymax_log("Error excluding \(subFile) from backup\nError: \(error.localizedDescription)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
                os_log("Error excluding %@ from backup\nError: %@", log: self.contentControllerLog, type: .error, subFile, error.localizedDescription)
            }
        })
    }
    
    private func checkForAppUpgrade() {
        
        baymax_log("Checking for app upgrade", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
        os_log("Checking for app upgrade", log: contentControllerLog, type: .debug)
        // App versioning
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let previousVersion = UserDefaults.standard.string(forKey: "TSCLastVersionNumber")
        
        if let current = currentVersion, let previous = previousVersion, current != previous {
            
            baymax_log("New app version detected, delta updates will now be removed", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
            os_log("New app version detected, delta updates will now be removed", log: contentControllerLog, type: .debug)
            cleanoutCache()
        }
        
        UserDefaults.standard.set(currentVersion, forKey: "TSCLastVersionNumber")
    }
    
    /// Removes ALL Storm content, from the delta bundle, temporary update directory and the bundle directory
    ///
    /// - Warning: Proceed with caution, this will delete all storm content which there is no going back from this
    /// make sure if calling, you know how you will fetch the content needed to display your app again!
    public func removeAllContentBundles() {
        
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
        
        // Remove initial bundle timestamp as we've now cleared out all evidence of any bundles!
        initialBundleTimestamp = nil
    }
    
    /// Removes all cached (delta) data in `deltaDirectory`
    public func cleanoutCache() {
        
        let fm = FileManager.default
        
        guard Bundle.main.path(forResource: "Bundle", ofType: "") != nil else {
            baymax_log("Did not clear delta updates due to app not using an embedded Storm Bundle", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
            os_log("Did not clear delta updates due to app not using an embedded Storm Bundle")
            return
        }
        
        guard let deltaDirectory = deltaDirectory else {
            baymax_log("Did not clear delta updates for upgrade due to delta directory not existing", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
            os_log("Did not clear delta updates for upgrade due to delta directory not existing", log: self.contentControllerLog, type: .debug)
            return
        }
        
        ["app.json", "manifest.json", "pages", "content", "languages", "data"].forEach { (file) in
            
            do {
                try fm.removeItem(at: deltaDirectory.appendingPathComponent(file))
            } catch {
                baymax_log("Failed to remove \(file) in cache directory: \(error.localizedDescription)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
                os_log("Failed to remove %@ in cache directory: %@", log: self.contentControllerLog, type: .debug, file, error.localizedDescription)
            }
        }
        
        baymax_log("Delta updates removed", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
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
                baymax_log("Delta timestamp not updated in settings: Delta bundle does not exist or it's manifest.json cannot be read", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
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
                baymax_log("Error updating bundle timestamp in settings", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
                os_log("Error updating bundle timestamp in settings", log: self.contentControllerLog, type: .error)
            }
        }
    }
    
    internal func showFeedback(title: String, message: String) {
        
        guard ContentController.showFeedback else { return }
        
        if UIApplication.shared.applicationState == .active {
            OperationQueue.main.addOperation {
                ToastNotificationController.shared.displayToastWith(title: title, message: message)
            }
        }
        
        guard ContentController.showFeedbackInBackground, UIApplication.shared.applicationState != .active else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let notification = UNNotificationRequest(identifier: "contentcontroller_\(title)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(notification, withCompletionHandler: nil)
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
                baymax_log("No files exist in streamed bundle directory subfolder: \(inDirectory)\nError: \(error.localizedDescription)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
                os_log("No files exist in streamed bundle directory subfolder: %@\nError: %@", log: self.contentControllerLog, type: .debug, inDirectory, error.localizedDescription)
            }
        }
        
        if let deltaDirectory = deltaDirectory {
            
            let filePathURL = deltaDirectory.appendingPathComponent(inDirectory)
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: filePathURL.path)
                contents.forEach({ files.insert($0) })
            } catch let error {
                baymax_log("No files exist in delta directory subfolder: \(inDirectory)\nError: \(error.localizedDescription)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
                os_log("No files exist in delta directory subfolder: %@\nError: %@", log: self.contentControllerLog, type: .debug, inDirectory, error.localizedDescription)
            }
        }
        
        if let bundleDirectory = bundleDirectory {
            
            let filePathURL = bundleDirectory.appendingPathComponent(inDirectory)
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: filePathURL.path)
                contents.forEach({ files.insert($0) })
            } catch let error {
                baymax_log("No files exist in bundle directory subfolder: \(inDirectory)\nError: \(error.localizedDescription)", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .debug)
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
                    baymax_log("CoreSpotlight indexing tried to index a storm object of class \(pageClass) which cannot be allocated on the main thread.\nTo enable it for indexing please make sure any view code is moved out of the init(dictionary:) method", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
                    os_log("CoreSpotlight indexing tried to index a storm object of class %@ which cannot be allocated on the main thread.\nTo enable it for indexing please make sure any view code is moved out of the init(dictionary:) method", log: self.contentControllerLog, type: .error, pageClass)
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
                    baymax_log("CoreSpotlight indexing tried to index a native page of name \(pageName) which cannot be allocated on the main thread.\nTo enable it for indexing please make sure any view code is moved out of the init method", subsystem: Logger.stormSubsystem, category: ContentController.logCategory, type: .error)
                    os_log("CoreSpotlight indexing tried to index a native page of name %@ which cannot be allocated on the main thread.\nTo enable it for indexing please make sure any view code is moved out of the init method", log: self.contentControllerLog, type: .error, pageName)
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
    case gunzipFailed
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
        case .gunzipFailed:
            return "Gunzipping bundle failed"
        }
    }
}
