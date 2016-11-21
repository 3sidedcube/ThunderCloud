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
    
    /// How
    var smoothingFactor: Float = 0.66
    
    var totalBytes: Int
    
    var bytesDownload: Int = 0
    
    let startTime: Int64
    
    init(totalBytes: Int) {
        
        self.totalBytes = totalBytes
        startTime = mach_absolute_time()
    }
    
    func updateDownloaded(with newCount: Int) {
        
        print("time is \(mach_absolute_time())")
    }
}


class DownloadingStormBundleViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    var downloadProgress: DownloadProgress?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startDownloading() {
        
        DeveloperModeController.shared.switchToDev { [weak self] (stage, amountDownloaded, totalToDownload, error) -> (Void) in
            
            print("Download progress:")
            
            if self?.downloadProgress == nil {
                self?.downloadProgress = Progress(totalUnitCount: Int64(totalToDownload))
                self?.downloadProgress?.kind = .file
            } else if let progress = self?.downloadProgress, stage == .downloading {
                
                progress.completedUnitCount = Int64(amountDownloaded)
                print("Progress: \(progress.localizedDescription)")
            }
            
//            print("Amount: \(amountDownloaded)")
//            print("Total: \(totalToDownload)")
            print("Error: \(error?.localizedDescription)")
        }
    }

}
