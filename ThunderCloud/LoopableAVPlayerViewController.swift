//
//  LoopableAVPlayerViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 03/05/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import UIKit
import AVKit

/// The view controller used to play standard videos in storm content
public class LoopableAVPlayerViewController: AVPlayerViewController {

    /// Whether to loop the playing video
    var loopVideo: Bool = false {
        didSet {
            switch (oldValue, loopVideo) {
            case (false, true):
                player?.actionAtItemEnd = .none
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(playerItemDidReachEnd(_:)),
                    name: .AVPlayerItemDidPlayToEndTime,
                    object: player?.currentItem
                )
            case (true, false):
                player?.actionAtItemEnd = .pause
                NotificationCenter.default.removeObserver(
                    self,
                    name: .AVPlayerItemDidPlayToEndTime,
                    object: nil
                )
            default:
                break
            }
        }
    }
    
    @objc func playerItemDidReachEnd(_ notification: Notification) {
        
        guard let playerItem = notification.object as? AVPlayerItem else { return }
        playerItem.seek(to: .zero, completionHandler: nil)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard loopVideo else { return }
        NotificationCenter.default.removeObserver(
            self,
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }
}
