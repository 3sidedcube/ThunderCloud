//
//  DownloadingStormBundleViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 21/11/2016.
//  Copyright © 2016 threesidedcube. All rights reserved.
//

import UIKit


/// A class for measuring the download process of a file or data
class DownloadProgress {
    
    /// How many seconds of data should be used in rolling average for speed
    var averageTimeWindow: TimeInterval = 4
    
    var sampleSpacing: TimeInterval = 0.5
    
    var totalBytes: Int
    
    private func fileSizeDisplay(_ fromBytes:Int) -> String {
        
        let display = ["bytes","KB","MB","GB","TB","PB"]
        var value:Double = Double(fromBytes)
        var type = 0
        while (value > 1024){
            value /= 1024
            type = type + 1
            
        }
        return "\(String(format:"%g", value)) \(display[type])"
    }
    
    var progressString: String {
        get {
            
            let display = ["bytes", "KB", "MB", "GB", "TB", "PB"]
            var totalValue: Double = Double(totalBytes)
            var downloadedValue: Double = Double(_bytesDownloaded)
            
            var type = 0
            
            while (totalValue > 1024) {
                totalValue /= 1024
                downloadedValue /= 1024
                type = type + 1
            }
            
            return "\(String(format:"%.2f", downloadedValue))/\(String(format:"%.2f", totalValue)) \(display[type]) downloaded"
        }
    }
    
    private var _bytesDownloaded = 0
    
    var bytesDownloaded: Int {
        set {
            
            _bytesDownloaded = newValue
            
            let t = Date().timeIntervalSince1970
            let dt = t - lastReading.timeStamp
            let db = newValue - lastReading.downloaded
            
            if (dt > sampleSpacing && db > 0) {
                
                speeds.append((speed: Double(db)/dt, timeStamp: t))
                speeds = speeds.filter({ (result) -> Bool in
                    return t - result.timeStamp < averageTimeWindow
                })
                
                downloadSpeed = speeds.reduce(0.0, { (total, result) -> Double in
                    return total + result.speed
                }) / Double(speeds.count)
                
                timeRemaining = Double(totalBytes - newValue) / downloadSpeed!
                lastReading = (downloaded: newValue, timeStamp: t)
            }
            
        }
        get {
            return _bytesDownloaded
        }
    }
    
    let startTime: TimeInterval
    
    var timeRemaining: TimeInterval?
    
    var downloadSpeed: Double?
    
    private var lastReading: (downloaded: Int, timeStamp: TimeInterval)
    
    private var speeds: [(speed: Double, timeStamp: TimeInterval)] = []
    
    init(totalBytes: Int) {
        
        self.totalBytes = totalBytes
        startTime = Date().timeIntervalSince1970
        self.totalBytes = totalBytes
        self.lastReading = (downloaded: 0, timeStamp: startTime)
    }
}


class DownloadingStormBundleViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var retryButton: TSCButton!
    
    @IBOutlet weak var preparingIndicator: TSCView!
    @IBOutlet weak var downloadingIndicator: TSCView!
    @IBOutlet weak var unpackingIndicator: TSCView!
    @IBOutlet weak var verifyingIndicator: TSCView!
    @IBOutlet weak var copyingIndicator: TSCView!
    @IBOutlet weak var cleaningUpIndicator: TSCView!
    
    var downloadProgress: DownloadProgress?
    
    var currentStage: UpdateStage = .preparing {
        didSet {
            switch currentStage {
                
            case .downloading, .preparing, .checking:
                
                preparingIndicator.backgroundColor = UIColor(hexString: doneFillHex)
                preparingIndicator.borderColor = UIColor(hexString: doneBorderHex)
                downloadingIndicator.backgroundColor = UIColor(hexString: inProgressFillHex)
                downloadingIndicator.borderColor = UIColor(hexString: inProgressBorderHex)
            
            case .unpacking:
                
                downloadingIndicator.backgroundColor = UIColor(hexString: doneFillHex)
                downloadingIndicator.borderColor = UIColor(hexString: doneBorderHex)
                unpackingIndicator.backgroundColor = UIColor(hexString: inProgressFillHex)
                unpackingIndicator.borderColor = UIColor(hexString: inProgressBorderHex)
            
            case .verifying:
                
                unpackingIndicator.backgroundColor = UIColor(hexString: doneFillHex)
                unpackingIndicator.borderColor = UIColor(hexString: doneBorderHex)
                verifyingIndicator.backgroundColor = UIColor(hexString: inProgressFillHex)
                verifyingIndicator.borderColor = UIColor(hexString: inProgressBorderHex)
                
            case .copying:
                
                verifyingIndicator.backgroundColor = UIColor(hexString: doneFillHex)
                verifyingIndicator.borderColor = UIColor(hexString: doneBorderHex)
                copyingIndicator.backgroundColor = UIColor(hexString: inProgressFillHex)
                copyingIndicator.borderColor = UIColor(hexString: inProgressBorderHex)
            
            case .cleaning:
                
                copyingIndicator.backgroundColor = UIColor(hexString: doneFillHex)
                copyingIndicator.borderColor = UIColor(hexString: doneBorderHex)
                cleaningUpIndicator.backgroundColor = UIColor(hexString: inProgressFillHex)
                cleaningUpIndicator.borderColor = UIColor(hexString: inProgressBorderHex)
            
            case .finished:
                
                print("FINISHED")
            }
        }
    }
    
    var error: Error? {
        didSet {
            if error != nil {
                
                switch currentStage {
                    
                case .preparing, .checking:
                    
                    preparingIndicator.backgroundColor = UIColor(hexString: failedFillHex)
                    preparingIndicator.borderColor = UIColor(hexString: failedBorderHex)
                    
                case .downloading:
                    
                    downloadingIndicator.backgroundColor = UIColor(hexString: failedFillHex)
                    downloadingIndicator.borderColor = UIColor(hexString: failedBorderHex)
                    
                case .unpacking:
                    
                    unpackingIndicator.backgroundColor = UIColor(hexString: failedFillHex)
                    unpackingIndicator.borderColor = UIColor(hexString: failedBorderHex)
                    
                case .verifying:
                    
                    verifyingIndicator.backgroundColor = UIColor(hexString: failedFillHex)
                    verifyingIndicator.borderColor = UIColor(hexString: failedBorderHex)
                    
                case .copying:
                    
                    copyingIndicator.backgroundColor = UIColor(hexString: failedFillHex)
                    copyingIndicator.borderColor = UIColor(hexString: failedBorderHex)
                    
                case .cleaning:
                    
                    cleaningUpIndicator.backgroundColor = UIColor(hexString: failedFillHex)
                    cleaningUpIndicator.borderColor = UIColor(hexString: failedBorderHex)
                    
                default:
                    print("Failed on finish!")
                }
                
                titleLabel.text = "Dev Mode Failed ⚠️"
                retryButton.isHidden = false
                statusLabel.isHidden = true
            }
        }
    }
    
    func startDownloading() {
        
        DeveloperModeController.shared.switchToDev { [weak self] (stage, amountDownloaded, totalToDownload, error) -> (Void) in
            
            if self?.downloadProgress == nil, totalToDownload > 0 {
                
                self?.downloadProgress = DownloadProgress(totalBytes: totalToDownload)
                self?.downloadProgress?.bytesDownloaded = amountDownloaded
                
            } else if let progress = self?.downloadProgress {
                
                if (stage == .downloading) {
                    
                    OperationQueue.main.addOperation {
                        
                        progress.bytesDownloaded = amountDownloaded
                        self?.statusLabel.text = progress.progressString

                        guard let remaining = progress.timeRemaining, !remaining.isNaN, !remaining.isInfinite else {
                            
                            self?.titleLabel.text = "Beginning Download"
                            return
                        }
                        self?.titleLabel.text = "\(Int(remaining))s remaining"
                    }
                }
            }
            
            if stage != self?.currentStage {
                
                OperationQueue.main.addOperation {
                    self?.currentStage = stage
                }
            }
            
            if let error = error {
                
                OperationQueue.main.addOperation {
                    self?.error = error
                }
            }
        }
    }
    
    @IBAction func handleRetry(_ sender: Any) {
        
        downloadingIndicator.backgroundColor = UIColor.clear
        downloadingIndicator.borderColor = UIColor.lightGray
        unpackingIndicator.backgroundColor = UIColor.clear
        unpackingIndicator.borderColor = UIColor.lightGray
        verifyingIndicator.backgroundColor = UIColor.clear
        verifyingIndicator.borderColor = UIColor.lightGray
        copyingIndicator.backgroundColor = UIColor.clear
        copyingIndicator.borderColor = UIColor.lightGray
        cleaningUpIndicator.backgroundColor = UIColor.clear
        cleaningUpIndicator.borderColor = UIColor.lightGray
        
        preparingIndicator.backgroundColor = UIColor(hexString: inProgressFillHex)
        preparingIndicator.borderColor = UIColor(hexString: inProgressBorderHex)
        
        retryButton.isHidden = true
        statusLabel.isHidden = false
        titleLabel.text = "Calculating ETA..."
        statusLabel.text = "Clearing existing bundles..."
        
        startDownloading()
    }
    
    private let inProgressBorderHex = "#D6911D"
    private let inProgressFillHex = "#F5A623"
    
    private let doneBorderHex = "#61b831"
    private let doneFillHex = "#72d33a"
    
    private let failedBorderHex = "#c3201f"
    private let failedFillHex = "#ff3b39"
}
