//
//  VideoPlayerControlsView.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 10/10/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import MediaPlayer

/// The view shown over/below a full screen video that displays video controls
open class VideoPlayerControlsView: UIView {
    
    /// The volume control for adjusting the video volume or switching to an Airplay device
    open var volumeView: MPVolumeView = MPVolumeView()
    
    /// The play/pause button for the video
    open var playButton: UIButton = UIButton()
    
    /// Where multiple languages are available, this button is available for choosing the video in an alternative language
    open var languageButton: UIButton?
    
    public init() {
        
        super.init(frame: .zero)
        
        backgroundColor = UIColor(red: 74.0/255.0, green: 75.0/255.0, blue: 77.0/255.0, alpha: 1.0)
        
        let playImage = UIImage(named: "mediaPauseButton", in: Bundle.init(for: VideoPlayerControlsView.self), compatibleWith: nil)
        playButton.setImage(playImage, for: .normal)
        addSubview(playButton)
        
        if let languagePacks = StormLanguageController.shared.availableLanguagePacks, languagePacks.count > 1 {
            
            languageButton = UIButton()
            let languageImage = UIImage(named: "mediaLanguageButton", in: Bundle.init(for: VideoPlayerControlsView.self), compatibleWith: nil)
            languageButton?.setImage(languageImage, for: .normal)
            addSubview(languageButton!)
        }
        
        addSubview(volumeView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func getBottomSafeAreaInset() -> CGFloat {
        if #available(iOS 11, *) {
            return self.safeAreaInsets.bottom
        } else {
            return 0
        }
    }
    
    override open func layoutSubviews() {
        
        super.layoutSubviews()
        
        let bottomSafeAreaInset = getBottomSafeAreaInset()
        let orientation = UIApplication.shared.appStatusBarOrientation
        
        if orientation.isPortrait {
            
            if let languageButton = languageButton {
                
                playButton.frame = CGRect(x: frame.width/2 - 50, y: 10, width: 24, height: 26)
                languageButton.frame = CGRect(x: frame.width/2 + 20, y: 10, width: 24, height: 26)
                
            } else {
                
                playButton.frame = CGRect(x: frame.width/2 - 12, y: 10, width: 24, height: 26)
            }
            
            volumeView.frame = CGRect(x: 44, y: bounds.height - (30 + bottomSafeAreaInset), width: bounds.width - 88, height: 22)
            
        } else {
            
            if let languageButton = languageButton {
                
                playButton.frame = CGRect(x: center.x, y: 7, width: 24, height: 26)
                languageButton.frame = CGRect(x: frame.width - 45, y: 7, width: 24, height: 26)
                
            } else {
                
                playButton.frame = CGRect(x: center.x - 12, y: 7, width: 24, height: 26)
            }
            
            
            volumeView.frame = CGRect(x: 20, y: bounds.size.height - (30 + bottomSafeAreaInset), width: bounds.width/2 - 50, height: 22)
        }
    }
}
