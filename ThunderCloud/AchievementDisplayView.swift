//
//  AchievementDisplayView.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// A protocol to adhere to in order to be displayed when an achievement has been earned
public protocol AchievementDisplayable {
    /// A custom init method which AchievementDisplayable must conform to
    ///
    /// - Parameters:
    ///   - frame: The frame of the view
    ///   - image: The image to be displayed in the view
    ///   - subtitle: The subtitle to be shown in the view
    init(frame: CGRect, image: StormImage?, subtitle: String?)
}

extension CircleProgressView {
    
    /// Provide default configuration for `CircleProgressView` when representing a badge
    func badgeConfigure() {
        backgroundColor = .clear
        circleProgressLayer.backgroundColor = UIColor.clear.cgColor
        circleProgressLayer.pathColor = ThemeManager.shared.theme.mainColor
        circleProgressLayer.backgroundPathColor = .white
        circleProgressLayer.radiusScale = 0.95
        circleProgressLayer.clockwise = true
        progress = 0
    }
}

/// A base view conforming to `AchievementDisplayable` which is used for
/// displaying an image and subtitle as a pop up, generally used for displaying
/// earned badges
open class AchievementDisplayView: UIView, AchievementDisplayable {
    
    /// Interface configuration options for AchievementDisplayView
    struct InterfaceOptions {
        
        /// Whether the achievement display view should be centered vertically or otherwise
        var centerVertically: Bool
        
        /// Public memberwise initialiser
        /// - Parameter centerVertically: Whether the achievement display view should be centered vertically
        /// or inset from the top of it's parent view
        public init(centerVertically: Bool = true) {
            self.centerVertically = centerVertically
        }
    }
    
    static var interfaceOptions: InterfaceOptions = InterfaceOptions()
    
    /// Fixed constants
    private struct Constants {
        
        /// Width of  `UIImageView` relative to `progressView`
        static let imageViewWidthScale: CGFloat = 1
        
        /// Width of  `stackView` relative to `self`
        static let stackViewWidthScale: CGFloat = 0.85
        
        /// Vertical spacing between `stackView` top and `self` top
        static let stackViewVerticalSpacing: CGFloat = 40
        
        /// Width of `progressView` relative to `stackView`
        static let progressViewWidthScale: CGFloat = 0.6
        
        /// Insets for `expiryDateLabel` `InsetLabel`
        static let labelInsets = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
    }
    
    /// Set an `expirableAchievement` to drive a UI components which would be hidden otherwise
    public var expirableAchievement: ExpirableAchievement? {
        didSet {
            didUpdateExpirableAchievement(animated: true)
        }
    }
    
    /// Root `UIStackView` to drive vertical layout
    public private(set) lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 20
        return stackView
    }()
    
    /// `UILabel` at the top of the `UIStackView`
    public private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Congratulations".localised(with: "_QUIZ_WIN_CONGRATULATION") // _QUIZ_CONGRATULATION_TITLE
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    /// `CircleProgressView` parent of `badgeImageView` for animating progress, below `titleLabel`
    public private(set) lazy var progressView: CircleProgressView = {
        let view = CircleProgressView()
        if QuizConfiguration.shared.blendedLearningEnabled {
            view.badgeConfigure()
        } else {
            view.alpha = 1
            view.backgroundColor = ThemeManager.shared.theme.whiteColor
            view.progress = 0
            view.circleProgressLayer.backgroundPathColor = .clear
            view.shadow = false
        }
        return view
    }()
    
    /// Single, central `UIImageView` with width scaled relative to parent.
    /// 1:1 aspect ratio.
    public private(set) lazy var badgeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = nil
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    /// `UIStackView` container for `expiresTitleLabel` and `expiryLabel`.
    /// Below `progressView` in `stackView`
    public private(set) lazy var expiryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 6
        return stackView
    }()
    
    /// Top `UILabel` in `expiryStackView`
    public private(set) lazy var expiryTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Expires on".localised(with: "_BADGE_EXPIRES_ON")
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    /// Bottom `UILabel` in `expiryStackView`
    public private(set) lazy var expiryDateLabel: InsetLabel = {
        let label = InsetLabel()
        label.text = ""
        label.backgroundColor = ThemeManager.shared.theme.darkGrayColor
        label.textAlignment = .center
        label.numberOfLines = 1
        label.insets = Constants.labelInsets
        return label
    }()
    
    /// Space `UIView` inbetween `expiryStackView` and `subtitleLabel`
    public private(set) lazy var spaceView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    /// `UILabel` below `expiryStackView`
    public private(set) lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    /// Bottom `UILabel` in `stackView`
    public private(set) lazy var expiryDetailLabel: UILabel = {
        let label = UILabel()
        label.text = "Once the expiry date passes you will need to retake the test."
            .localised(with: "_BADGE_EXPIRY_DESCRIPTION")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    // MARK: - Init
    
    /// Conformance to `AchievementDisplayable`
    ///
    /// - Parameters:
    ///   - frame: The frame of the view
    ///   - image: The image to display
    ///   - subtitle: The subtitle to display
    required public init(frame: CGRect, image: StormImage?, subtitle: String?) {
        super.init(frame: frame)
        
        badgeImageView.image = image?.image
        badgeImageView.accessibilityLabel = image?.accessibilityLabel
        badgeImageView.isAccessibilityElement = image?.accessibilityLabel != nil
        
        subtitleLabel.text = subtitle ?? ""
        
        setup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
  
    // MARK: - Setup
    
    /// Shared init functionality
    private func setup() {
        backgroundColor = ThemeManager.shared.theme.backgroundColor
        
        updateLabels()
        didUpdateExpirableAchievement(animated: false)
        
        addSubviews()
        constrain()
    }
    
    /// Add subviews to view hierarchy
    private func addSubviews() {
        expiryStackView.addArrangedSubview(expiryTitleLabel)
        expiryStackView.addArrangedSubview(expiryDateLabel)
        
        progressView.addSubview(badgeImageView)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(progressView)
        stackView.addArrangedSubview(expiryStackView)
        stackView.addArrangedSubview(spaceView)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(expiryDetailLabel)
        
        addSubview(stackView)
    }
      
    /// Constrain views
    private func constrain() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        badgeImageView.translatesAutoresizingMaskIntoConstraints = false
        spaceView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // StackView
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: Constants.stackViewWidthScale),
            
            // BadgeView
            progressView.widthAnchor.constraint(equalTo: stackView.widthAnchor,
                                                multiplier: Constants.progressViewWidthScale),
            progressView.heightAnchor.constraint(equalTo: progressView.widthAnchor),
            
            // ImageView
            badgeImageView.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),
            badgeImageView.centerYAnchor.constraint(equalTo: progressView.centerYAnchor),
            badgeImageView.widthAnchor.constraint(equalTo: progressView.widthAnchor,
                                             multiplier: Constants.imageViewWidthScale),
            badgeImageView.heightAnchor.constraint(equalTo: badgeImageView.widthAnchor),
            
            // SpaceView
            spaceView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            spaceView.heightAnchor.constraint(equalToConstant: 5),
        ])
        
        if AchievementDisplayView.interfaceOptions.centerVertically {
            NSLayoutConstraint.activate([
                stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
                stackView.topAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.topAnchor, constant: Constants.stackViewVerticalSpacing),
                safeAreaLayoutGuide.bottomAnchor.constraint(greaterThanOrEqualTo: stackView.bottomAnchor, constant: Constants.stackViewVerticalSpacing)
            ])
        } else {
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Constants.stackViewVerticalSpacing),
            ])
        }
    }
    
    // MARK: - Labels
    
    private func updateLabels() {
        updateTitleLabel()
        updateSubtitleLabel()
        updateExpiryTitleLabel()
        updateExpiryDateLabel()
        updateExpiryDetailLabel()
    }
    
    private func updateTitleLabel() {
        titleLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 27, textStyle: .body, weight: .bold)
        titleLabel.textColor = .black
    }
    
    private func updateSubtitleLabel() {
        subtitleLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 20, textStyle: .body, weight: .semibold)
        subtitleLabel.textColor = .black
    }
    
    private func updateExpiryTitleLabel() {
        expiryTitleLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 17, textStyle: .body, weight: .regular)
        expiryTitleLabel.textColor = ThemeManager.shared.theme.grayColor
    }
    
    private func updateExpiryDateLabel() {
        expiryDateLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 17, textStyle: .body, weight: .semibold)
        expiryDateLabel.textColor = ThemeManager.shared.theme.whiteColor
    }
    
    private func updateExpiryDetailLabel() {
        expiryDetailLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 18, textStyle: .body, weight: .regular)
        expiryDetailLabel.textColor = .black
    }
    
    // MARK: - Accessibility
    
    func accessibilitySettingsDidChange() {
        updateLabels()
        setNeedsLayout()
    }
    
    // MARK: - Expiry
    
    /// Called when `expirableAchievement` is set - update appropriate UI
    private func didUpdateExpirableAchievement(animated: Bool) {
        
        guard QuizConfiguration.shared.blendedLearningEnabled else {
            expiryStackView.isHidden = true
            expiryDetailLabel.isHidden = true
            expiryDateLabel.isHidden = true
            return
        }
        
        // Show/hide views
        expiryStackView.isHidden = expirableAchievement == nil
        expiryDetailLabel.isHidden = expiryStackView.isHidden

        // Progress
        let progress = CGFloat(expirableAchievement?.progress ?? 1)
        if animated {
            progressView.animateProgress(to: progress, duration: 1)
        } else {
            progressView.progress = progress
        }
        
        // Date UI
        guard let expirableAchievement = expirableAchievement else {
            return
        }
        expiryDateLabel.text = expirableAchievement.expiryDateString
    }
}
