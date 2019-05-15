//
//  StreamingContentController.swift
//  ThunderCloud
//
//  Created by Matthew Cheetham on 05/10/2016.
//  Copyright © 2016 threesidedcube. All rights reserved.
//

import Foundation
import ThunderRequest

@objc(TSCStreamingPagesController)
public class StreamingPagesController: NSObject {
    
    /**
     The request controller used to perform API requests.
     */
    var requestController: RequestController?
    
    let downloadQueue = OperationQueue()
    
    var streamingCacheURL: URL?
    
    override init() {
        
        let baseString = Bundle.main.infoDictionary?["TSCStreamingBaseURL"] as? String
        let appId = UserDefaults.standard.string(forKey: "TSCAppId") ?? Storm.API.AppID

        if let _baseString = baseString, let _appId = appId {
            requestController = RequestController(baseAddress: "\(_baseString)/bundles/\(_appId)/live/unpacked")
        }

        super.init()

        downloadQueue.name = "Streaming Files"
        downloadQueue.maxConcurrentOperationCount = 5
    }
    
    func setupDirectories() {
        
        let fileManager = FileManager.default
        if let tmpURL = try? fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            
            let finalURL = tmpURL.appendingPathComponent("Streaming")
            let pagesURL = finalURL.appendingPathComponent("pages")
            let contentURL = finalURL.appendingPathComponent("content")
            let languageURL = finalURL.appendingPathComponent("languages")
            
            try? fileManager.createDirectory(at: finalURL, withIntermediateDirectories: true, attributes: nil)
            try? fileManager.createDirectory(at: pagesURL, withIntermediateDirectories: true, attributes: nil)
            try? fileManager.createDirectory(at: contentURL, withIntermediateDirectories: true, attributes: nil)
            try? fileManager.createDirectory(at: languageURL, withIntermediateDirectories: true, attributes: nil)
            
            streamingCacheURL = finalURL
        }
    }
    
    /// Generates a fully resolvable URL that can be used to access the storm resource on Cloudfront
    ///
    /// - parameter stormURI: A storm URL for a file taken from the app.json. Looks something like "//content/1234.jpg"
    ///
    /// - returns: An optional URL if it was able to generate a fully resolvable URL
    func fullURL(from stormURI: String) -> URL? {
        
        guard let sharedBaseURL = requestController?.sharedBaseURL else { return nil }
        let fullURLString = stormURI.replacingOccurrences(of: "//", with: sharedBaseURL.absoluteString)
        return URL(string: fullURLString)
    }
    
    
    /// Checks whether a file should be excluded from download based on it's scale. We get the device scale and only download the ones matching our scale
    ///
    /// - parameter fileURLString: The cache URL of the file to download
    ///
    /// - returns: True if the file should be excluded from download. False if we need the file on this device.
    func isExcluded(fileURLString: String) -> Bool{
        
        var unwantedSizes = ["x0.75.", "x1.", "x1.5.", "x2."]
        let myScale = UIScreen.main.scale;
        var myScaleIdentifier = "x2."
        if myScale == 1.0 {
            myScaleIdentifier = "x1."
        }
        
        unwantedSizes = unwantedSizes.filter({$0 != myScaleIdentifier})
        
        for suffix in unwantedSizes {
            if fileURLString.contains(suffix) {
                return true
            }
        }
        return false
    }
    
    /// Calculates the list of required file URL's for displaying a page to the user as a streaming page
    ///
    /// - parameter json:           A full JSON object of the app.json from the remote server
    /// - parameter pageIdentifier: The page which the user wants to display so that we can check file availability
    ///
    /// - returns: An optional array of URL's containing the files to download
    func fileList(from json: [AnyHashable: Any], for pageIdentifier: String) -> [URL]? {
        
        if let fileMap = json["map"] as? [[AnyHashable: Any]] {
            
            let pageArray = fileMap.filter({ (entry: [AnyHashable : Any]) -> Bool in
                
                if let entryId = entry["id"] as? String, entryId == pageIdentifier {
                    return true
                }
                
                return false
            })
            
            if let fileEntry = pageArray.first, let fileArray = fileEntry["files"] as? [[AnyHashable: Any]] {
                
                return fileArray.compactMap({ (fileDictionary: [AnyHashable : Any]) -> URL? in
                    
                    if let urlString = fileDictionary["src"] as? String {
                        if (isExcluded(fileURLString: urlString)){
                            return nil
                        }
                        return fullURL(from: urlString)
                    }
                    return nil
                })
            }
        }
        
        return nil
    }
    
    
    
    /// Converts a cache URL to just a page identifier so we can use it
    ///
    /// - parameter cacheURL: A storm cache url like "cache://pages/1234.json"
    ///
    /// - returns: The identifier of the page such as "1234"
    private func pageId(for cacheURL: String) -> String? {
        
        let lastComponent = cacheURL.components(separatedBy: "/").last
        
        if let _lastComponent = lastComponent {
            
            return _lastComponent.replacingOccurrences(of: ".json", with: "")
        }
        return nil
    }
    
    /// Requests a streaming page to be displayed and will return the view controller once everything is ready
    ///
    /// - parameter identifier: The page ID to display to the user once downloaded
    /// - parameter completion: The completion block to call with the finished view controller or download page
    public func fetchStreamingPage(cacheURLString: String, completion: @escaping (_ stormView: UIViewController?, _ downloadError: Error?) -> ()) {
        
        guard let identifier = pageId(for: cacheURLString) else {
            completion(nil, streamingError.invalidPageURL)
            return
        }
        
        setupDirectories()
        
        requestController?.request("app.json", method: .GET) { (response: RequestResponse?, error: Error?) in
            
            guard error == nil, let appJSON = response?.dictionary else {
                completion(nil, error)
                return
            }
            
            let files = self.fileList(from: appJSON, for: identifier)
            
            var fileOperations = [StreamingContentFileOperation]()
            
            if let _files = files, let _toDirectory = self.streamingCacheURL {
                
                for file in _files {
                    
                    let fileName = file.absoluteString.replacingOccurrences(of: self.requestController?.sharedBaseURL.absoluteString ?? "", with: "")
                    
                    let newOperation = StreamingContentFileOperation(with: file.absoluteString, targetFolder: _toDirectory, fileNameComponentString: fileName)
                    fileOperations.append(newOperation)
                }
            }
            
            if let _toDirectory = self.streamingCacheURL {
                
                //Get language
                if let _languageString = StormLanguageController.shared.currentLanguage {
                    let languageOperation = StreamingContentFileOperation(with: "\(self.requestController?.sharedBaseURL.absoluteString ?? "")languages/\(_languageString).json", targetFolder: _toDirectory, fileNameComponentString: "languages/\(_languageString).json")
                    languageOperation.completionBlock = {
                        StormLanguageController.shared.loadLanguageFile(fileURL: _toDirectory.appendingPathComponent("languages/\(_languageString).json"))
                    }
                    
                    fileOperations.append(languageOperation)
                }
                
                //Get page
                let pageOperation = StreamingContentFileOperation(with: "\(self.requestController?.sharedBaseURL.absoluteString ?? "")pages/\(identifier).json", targetFolder: _toDirectory, fileNameComponentString: "pages/\(identifier)-streamed.json")
                for operation in fileOperations {
                    pageOperation.addDependency(operation)
                }
                
                pageOperation.completionBlock = {
                    
                    let pageData = try? Data(contentsOf: _toDirectory.appendingPathComponent("pages/\(identifier)-streamed.json"))
                    if pageData == nil {
                        completion(nil, streamingError.failedToLoadRemoteData)
                        return
                    }
                    
                    if let _pageData = pageData {
                        let pageObject = try? JSONSerialization.jsonObject(with: _pageData, options: []) as? [AnyHashable: Any]
                        
                        if let pageResult = pageObject, let _pageObject = pageResult {
                            
                            OperationQueue.main.addOperation({
								
								guard let viewController = StormObjectFactory.shared.stormObject(with: _pageObject) as? UIViewController else {
									completion(nil, streamingError.pageNotAllocatedAsViewController)
									return
								}
                                completion(viewController, nil)
                            })
                        } else {
                            completion(nil, streamingError.pageDoesNotExistOrGaveBadData)
                            return
                        }
                    } else {
                        
                        completion(nil, streamingError.failedToLoadRemoteData)
                        return
                    }
                    
                }
                
                self.downloadQueue.addOperation(pageOperation)
                self.downloadQueue.addOperations(fileOperations, waitUntilFinished: false)
            }
            
        }
    }
    
    public class func cleanUp() {
        
        if let tmpURL = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            let finalURL = tmpURL.appendingPathComponent("Streaming")
            
            try? FileManager.default.removeItem(at: finalURL)
            StormLanguageController.shared.reloadLanguagePack()
        }
    }
}

class CustomOperationBase: Operation {
    
    private var _isExecuting: Bool = false
    override var isExecuting: Bool {
        get {
            return _isExecuting
        }
        set {
            if _isExecuting != newValue {
                willChangeValue(forKey: "isExecuting")
                _isExecuting = newValue
                didChangeValue(forKey: "isExecuting")
            }
        }
    }
    
    private var _isFinished: Bool = false;
    override var isFinished: Bool {
        get {
            return _isFinished
        }
        set {
            if _isFinished != newValue {
                willChangeValue(forKey: "isFinished")
                _isFinished = newValue
                didChangeValue(forKey: "isFinished")
            }
        }
    }
}

class StreamingContentFileOperation: CustomOperationBase {
    
    let fileRequestController: RequestController?
    
    let fileDownloadURLString: String
    
    let targetFolderURL: URL
    
    let fileNameComponent: String
    
    init(with fileURLString: String, targetFolder: URL, fileNameComponentString: String) {
        fileRequestController = RequestController(baseAddress: fileURLString)
        fileDownloadURLString = fileURLString
        targetFolderURL = targetFolder
        fileNameComponent = fileNameComponentString
    }
    
    override func main() {
        
        if self.isCancelled {
            return
        }
        
        guard let fileRequestController = fileRequestController else {
            return
        }
        
        // `init` method requires a full path to the file to be downloaded so we don't provide a further path here!
        fileRequestController.download("", progress: nil) { (response, fileLocation, error) in
            if let fromLocation = fileLocation {
                
                let toLocation = self.targetFolderURL.appendingPathComponent(self.fileNameComponent)
                try? FileManager.default.moveItem(at: fromLocation, to: toLocation)
            }
            
            self.isExecuting = false
            self.isFinished = true
        }
    }
}

enum streamingError: Error {
    case failedToLoadRemoteData
    case pageDoesNotExistOrGaveBadData
    case invalidPageURL
	case pageNotAllocatedAsViewController
}
