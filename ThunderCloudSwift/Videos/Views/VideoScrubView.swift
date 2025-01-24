//
//  VideoControlsView.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 03/05/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// The bar that is shown at the top of the screen when playing a storm video.
///
/// This is responsible for showing the length of the video and the current position of the video
class VideoScrubView: UIView {

    /// A label that displays the seconds and minutes that the video on screen has progressed through
    let currentTimeLabel: UILabel = UILabel(frame: .zero)
    
    /// A label that displays the total length of the video
    let endTimeLabel: UILabel = UILabel(frame: .zero)
    
    /// A slider representing the progress of the currently playing video
    let videoProgressSlider: UISlider = UISlider(frame: .zero)
    
    init() {
        
        super.init(frame: .zero)
        
        currentTimeLabel.textAlignment = .left
        currentTimeLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 14, textStyle: .caption1, weight: .bold)
        currentTimeLabel.textColor = .white
        currentTimeLabel.backgroundColor = .clear
        
        currentTimeLabel.text = "0:00"
        
        addSubview(currentTimeLabel)
        
        endTimeLabel.textAlignment = .right
        endTimeLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 14, textStyle: .caption1, weight: .bold)
        endTimeLabel.textColor = .white
        endTimeLabel.backgroundColor = .clear
        
        endTimeLabel.text = "0:00"
        
        addSubview(endTimeLabel)
        
        videoProgressSlider.setThumbImage(
            UIImage(
                named: "smallSlider",
                in: Bundle(for: VideoScrubView.self),
                compatibleWith: nil
            ),
            for: .normal
        )
        
        addSubview(videoProgressSlider)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        currentTimeLabel.frame = CGRect(x: 5, y: 12, width: bounds.width, height: 22)
        endTimeLabel.frame = CGRect(x: 0, y: 12, width: bounds.width - 5, height: 22)
        videoProgressSlider.frame = CGRect(x: 44, y: 11, width: bounds.width - 88, height: 22)
    }
}
