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
    let requestController: TSCRequestController = TSCRequestController(baseAddress: "https://d172sw9rejup1e.cloudfront.net/bundles/1/live/unpacked")
    
    let downloadQueue = OperationQueue()
    
    var streamingCacheURL: URL?
    
    override init() {
        super.init()
        downloadQueue.name = "Streaming Files"
        downloadQueue.maxConcurrentOperationCount = 5
        
        let fileManager = FileManager.default
        if let tmpURL = try? fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            
            let finalURL = tmpURL.appendingPathComponent("Streaming")
            let pagesURL = finalURL.appendingPathComponent("pages")
            let contentURL = finalURL.appendingPathComponent("content")
            let languageURL = finalURL.appendingPathComponent("languages")
            do {
                try fileManager.createDirectory(at: finalURL, withIntermediateDirectories: true, attributes: nil)
                try fileManager.createDirectory(at: pagesURL, withIntermediateDirectories: true, attributes: nil)
                try fileManager.createDirectory(at: contentURL, withIntermediateDirectories: true, attributes: nil)
                try fileManager.createDirectory(at: languageURL, withIntermediateDirectories: true, attributes: nil)
            } catch let _ {
                //Nope
            }
            
            streamingCacheURL = finalURL
        }

    }
    
    /// Generates a fully resolvable URL that can be used to access the storm resource on Cloudfront
    ///
    /// - parameter stormURI: A storm URL for a file taken from the app.json. Looks something like "//content/1234.jpg"
    ///
    /// - returns: An optional URL if it was able to generate a fully resolvable URL
    func fullURL(from stormURI: String) -> URL? {
        
        let fullURLString = stormURI.replacingOccurrences(of: "//", with: requestController.sharedBaseURL.absoluteString)
        return URL(string: fullURLString)
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
                
                return fileArray.flatMap({ (fileDictionary: [AnyHashable : Any]) -> URL? in
                    
                    if let urlString = fileDictionary["src"] as? String {
                        return fullURL(from: urlString)
                    }
                    return nil
                })
            }
        }
        
        return nil
    }
    
    /// Requests a streaming page to be displayed and will return the view controller once everything is ready
    ///
    /// - parameter identifier: The page ID to display to the user once downloaded
    /// - parameter completion: The completion block to call with the finished view controller or download page
    public func fetchStreamingPage(identifier: String, completion: @escaping (_ stormView: TSCStormViewController?, _ downloadError: Error?) -> ()) {
        
        requestController.get("app.json") { (response: TSCRequestResponse?, error: Error?) in
            
            guard error == nil, let appJSON = response?.dictionary else {
                return
            }
            
            let files = self.fileList(from: appJSON, for: "3")
            
            var fileOperations = [StreamingContentFileOperation]()
            
            if let _files = files, let _toDirectory = self.streamingCacheURL {
                
                for file in _files {
                    
                    let fileName = file.absoluteString.replacingOccurrences(of: self.requestController.sharedBaseURL.absoluteString, with: "")
                    
                    let newOperation = StreamingContentFileOperation(with: file.absoluteString, targetFolder: _toDirectory, fileNameComponentString: fileName)
                    fileOperations.append(newOperation)
                }
            }
            
            if let _toDirectory = self.streamingCacheURL {
                
                //Get language
                if let _languageString = TSCLanguageController.shared().currentLanguage {
                    let languageOperation = StreamingContentFileOperation(with: "\(self.requestController.sharedBaseURL.absoluteString)languages/\(_languageString).json", targetFolder: _toDirectory, fileNameComponentString: "languages/\(_languageString).json")
                    languageOperation.completionBlock = {
                        TSCStormLanguageController.shared().loadLanguageFile(_toDirectory.appendingPathComponent("languages/\(_languageString).json").path)
                    }
                    
                    fileOperations.append(languageOperation)
                }

                //Get page
                let pageOperation = StreamingContentFileOperation(with: "\(self.requestController.sharedBaseURL.absoluteString)pages/\(identifier).json", targetFolder: _toDirectory, fileNameComponentString: "pages/\(identifier).json")
                for operation in fileOperations {
                    pageOperation.addDependency(operation)
                }
                
                pageOperation.completionBlock = {
                    
                    let pageData = try? Data(contentsOf: _toDirectory.appendingPathComponent("pages/\(identifier).json"))
                    
                    if let _pageData = pageData {
                        print(String(data: _pageData, encoding: .utf8))
                        let pageObject = try? JSONSerialization.jsonObject(with: _pageData, options: []) as? [AnyHashable: Any]
                        
                                    if let pageResult = pageObject, let _pageObject = pageResult {
                        
                                        OperationQueue.main.addOperation({
                                            let stormPage = TSCStormViewController(dictionary: _pageObject)
                                            completion(stormPage, nil)
                                        })
                                    }
                    }
                    
                }
                
                self.downloadQueue.addOperation(pageOperation)
                self.downloadQueue.addOperations(fileOperations, waitUntilFinished: false)
            }

        }
    }
    
    public class func cleanup() {
        
        //Delete all files
        //Reload the language pack
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

    let fileRequestController = TSCRequestController()
    let fileDownloadURLString: String
    let targetFolderURL: URL
    let fileNameComponent: String
    
    init(with fileURLString: String, targetFolder: URL, fileNameComponentString: String) {
        print("Creating content operation")
        fileDownloadURLString = fileURLString
        targetFolderURL = targetFolder
        fileNameComponent = fileNameComponentString
    }
    
    override func main() {
        
        if self.isCancelled {
            return
        }
        
        print("Starting content operation")
        
        fileRequestController.downloadFile(withPath: fileDownloadURLString, progress: { (progress: CGFloat, totalBytes: Int, bytesTransferred: Int) in
            
        }) { (fileLocation: URL?, downloadError: Error?) in
            
            print("Downloaded from:\(self.fileDownloadURLString)")
            if let fromLocation = fileLocation {
                
                let toLocation = self.targetFolderURL.appendingPathComponent(self.fileNameComponent)
                do {
                    try FileManager.default.moveItem(at: fromLocation, to: toLocation)
                    print(toLocation)
                } catch let _ {
                    
                }
                
            }
            print("Finished content operation")
            self.isExecuting = false
            self.isFinished = true
        }
    }
}
