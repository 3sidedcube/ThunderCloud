//
//  InlineButtonView.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/09/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderBasics
import ThunderTable

/// InlineButtonView is a `TSCButton` that is used inside of cells to display embedded links.
open class InlineButtonView: TSCButton {
    
    /// The `TSCLink` to determine what action is performed when the button is pressed
    open var link: StormLink?
    
    /// An image view which is used to render the timer progress for timer buttons
    open var progressView: UIImageView?
    
    /// A Bool to disable and enable the button
    open var isAvailable: Bool = false {
        didSet {
            style()
        }
    }
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        cornerRadius = 8.0
        titleLabel?.textAlignment = .center
        style()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        style()
    }
    
    override open var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        return CGSize(width: superSize.width, height: max(superSize.height, 44))
    }
    
    open func style() {
        
        borderWidth = 1.0
        let mainColor = ThemeManager.shared.theme.mainColor
        
        if !isAvailable {
            primaryColor = mainColor.withAlphaComponent(0.2)
            secondaryColor = mainColor.withAlphaComponent(0.2)
            isUserInteractionEnabled = false
        } else {
            primaryColor = mainColor
            secondaryColor = mainColor
            isUserInteractionEnabled = true
        }
    }
    
    open func stopTimer() {
        
        if let borderColor = layer.borderColor {
            setTitleColor(UIColor(cgColor: borderColor), for: .normal)
        }
        
        UIView.transition(with: self, duration: 0.15, options: .transitionCrossDissolve, animations: { [weak self] in
            self?.progressView?.removeFromSuperview()
            self?.setTitle("Start Timer".localised(with: "_STORM_TIMER_START_TITLE"), for: .normal)
            }, completion: nil)
    }
    
    open func startTimer() {
        
        let bundle = Bundle(for: InlineButtonView.self)
        let backgroundTrackImage = UIImage(named: "trackImage", in: bundle, compatibleWith: nil)?.stretchableImage(withLeftCapWidth: 5, topCapHeight: 6)
        let completionOverlayImage = UIImage(named: "progress", in: bundle, compatibleWith: nil)?.stretchableImage(withLeftCapWidth: 5, topCapHeight: 6)
        
        progressView = UIImageView(image: completionOverlayImage)
        progressView?.tintColor = ThemeManager.shared.theme.mainColor
        layer.masksToBounds = true
        
        UIView.transition(with: self, duration: 0.15, options: .transitionCrossDissolve, animations: { [weak self] in
            self?.setBackgroundImage(backgroundTrackImage, for: .normal)
            }, completion: nil)
        
        guard let progressView = progressView else { return }
        addSubview(progressView)
        sendSubviewToBack(progressView)
    }
    
    open func setTimeRemaining(_ remaining: TimeInterval, totalCountdown: TimeInterval) {
        
        guard remaining > 0 else {
            stopTimer()
            return
        }
        
        // Update progress of track image
        let mins = floor(remaining/60)
        let secs = round(remaining - (mins*60))
        
        setTitle(String(format:"%02i:%02i", Int(mins), Int(secs)), for: .normal)
        
        let width = frame.width * CGFloat((totalCountdown - remaining) / totalCountdown)
        progressView?.frame = CGRect(x: 0, y: 0, width: width, height: frame.height)
        
        if let titleLabel = titleLabel, width >= titleLabel.frame.origin.x {
            setTitleColor(.black, for: .normal)
        }
    }
}
