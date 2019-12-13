//
//  PopupView.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 13/12/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import UIKit

// MARK: - Space

/// A `UIView` to act as a space
fileprivate enum Space: Int, CaseIterable {
    
    /// Top of the `stackView`
    case top = 0
    
    /// Separating `imageView` and `titleLabel`
    case imageViewTitleLabel = 1
    
    /// Separating `subtitleLabel` and `detailLabel`
    case subtitleLabelDetailLabel = 2
    
    /// Separating `detailLabel` and `confirmButton`
    case detailLabelConfirmButton = 3
    
    /// Height of the `Space`
    var height: CGFloat {
        switch self {
        case .top: return 22
        case .imageViewTitleLabel: return 5
        case .subtitleLabelDetailLabel: return 15
        case .detailLabelConfirmButton: return 22
        }
    }
}

// MARK: - PopupViewDelegate

/// Delegate methods on the `PopupView`
protocol PopupViewDelegate: class {
    
    /// `PopupView` `confirmButton`  `.touchUpInside`
    func popupView(_ view: PopupView, confirmButtonTouchUpInside sender: UIButton)
    
    /// `PopupView` `cancelButton`  `.touchUpInside`
    func popupView(_ view: PopupView, cancelButtonTouchUpInside sender: UIButton)
}

// MARK: - PopupViewConfig

/// Configure the UI of the `PopupView`
struct PopupViewConfig {
    
    /// `UIImage` for `PopupView` `imageView` `image`
    var image: UIImage?
    
    /// `String` for `PopupView` `titleLabel` `text`
    var title: String
    
    /// `String` for `PopupView` `subtitleLabel` `text`
    var subtitle: String
    
    /// `String` for `PopupView` `detailLabel` `text`
    var detail: String
    
    /// `String` for `PopupView` `confirmButton` `title(for: .normal)`
    var confirmText: String
    
    /// `String` for `PopupView` `cancelButton` `title(for: .normal)`
    var cancelText: String
}

// MARK: - PopupView

/// Simple popup
/// Could be considered similar to a `UIAlertController` which an enhanced UI
class PopupView: UIView {
    
    /// Fixed constants
    private struct Constants {
        
        /// Corner radius of the `PopupView`
        static let cornerRadius: CGFloat = 8
        
        /// Corner radius of the `UIButton`s
        static let buttonCornerRadius: CGFloat = 6
        
        /// Width of the `stackView` releative to the `PopupView` width
        static let stackViewWidthScale: CGFloat = 0.9
        
        /// Height of the `stackView` releative to the `PopupView` height
        static let stackViewHeightScale: CGFloat = 0.9
        
        /// Spacing of the `stackView`
        static let stackViewSpacing: CGFloat = 10
        
        /// Width of the `imageView` relative to the `stackView` width
        static let imageViewWidthScale: CGFloat = 0.45
        
        /// Height of the `UIButton`s
        static let buttonHeight: CGFloat = 50
    }
    
    /// `PopupViewDelegate`
    weak var delegate: PopupViewDelegate?
    
    /// `PopupViewConfig`
    public var config = PopupViewConfig(
        image: .tick,
        title: "Well done!",
        subtitle: "You have completed all of the tests.",
        detail: "You’re invited to book a course with us.",
        confirmText: "Book a course",
        cancelText: "Close") {
        didSet {
            didUpdatePopupConfig()
        }
    }
    
    /// Parent `UIStackView` which drives the layout of this `UIView`
    public private(set) lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = Constants.stackViewSpacing
        return stackView
    }()
    
    /// `UIImageView` at the top of the stackView
    public private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.tick
        imageView.tintColor = .darkGray
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    /// Main title label
    public private(set) lazy var titleLabel: UILabel = {
        return PopupView.createLabel(font: UIFont.systemFont(ofSize: 28, weight: .bold))
    }()
    
    /// Subtitle label under the title
    public private(set) lazy var subtitleLabel: UILabel = {
        return PopupView.createLabel(font: UIFont.systemFont(ofSize: 20, weight: .bold))
    }()
    
    /// Detail label between subtitle and buttons
    public private(set) lazy var detailLabel: UILabel = {
        return PopupView.createLabel(font: UIFont.systemFont(ofSize: 16, weight: .medium))
    }()

    /// Top button to "confirm"
    public private(set) lazy var confirmButton: UIButton = {
        return createButton(
            selector: #selector(confirmButtonTouchUpInside),
            titleColor: .white,
            backgroundColor: .red)
    }()
    
    /// Bottom button to "cancel"
    public private(set) lazy var cancelButton: UIButton = {
        let button = self.createButton(
            selector: #selector(cancelButtonTouchUpInside),
            titleColor: .slateGray,
            backgroundColor: .white)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 2
        return button
    }()
    
    /// `UIView` for `Space` elements
    private lazy var spaceViews: [UIView] = {
        return Space.allCases.map { space in
            let view = UIView()
            view.backgroundColor = .clear
            return view
        }
    }()
    
    // MARK: - Init
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: - Setup
    
    private func setup() {
        backgroundColor = .white
        layer.cornerRadius = Constants.cornerRadius
        clipsToBounds = true
        
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        
        addSubviews()
        constrain()
        
        didUpdatePopupConfig()
    }
    
    private func addSubviews() {
        stackView.addArrangedSubview(spaceViews[Space.top.rawValue])
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(spaceViews[Space.imageViewTitleLabel.rawValue])
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(spaceViews[Space.subtitleLabelDetailLabel.rawValue])
        stackView.addArrangedSubview(detailLabel)
        stackView.addArrangedSubview(spaceViews[Space.detailLabelConfirmButton.rawValue])
        stackView.addArrangedSubview(confirmButton)
        stackView.addArrangedSubview(cancelButton)
        
        addSubview(stackView)
    }
    
    private func constrain() {
        ([stackView, imageView, confirmButton, cancelButton] + spaceViews).forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // StackView
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: Constants.stackViewWidthScale),
            stackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: Constants.stackViewHeightScale),
            
            // BadgeView
            imageView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: Constants.imageViewWidthScale),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
            
        ] + buttonConstraints() + spaceViewConstraints())
    }
    
    /// `NSLayoutConstraint`s for `UIButton`s
    private func buttonConstraints() -> [NSLayoutConstraint] {
        return [confirmButton, cancelButton].flatMap {[
            $0.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            $0.widthAnchor.constraint(equalTo: stackView.widthAnchor),
        ]}
    }
    
    /// `NSLayoutConstraint`s for `spaceView`s
    private func spaceViewConstraints() -> [NSLayoutConstraint] {
        return Space.allCases.flatMap {[
            spaceViews[$0.rawValue].heightAnchor.constraint(equalToConstant: $0.height),
            spaceViews[$0.rawValue].widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ]}
    }
       
    // MARK: - UI
    
    /// `PopupConfig` `didSet`
    private func didUpdatePopupConfig() {
        imageView.image = config.image
        titleLabel.text = config.title
        subtitleLabel.text = config.subtitle
        detailLabel.text = config.detail
        confirmButton.setTitle(config.confirmText, for: .normal)
        cancelButton.setTitle(config.cancelText, for: .normal)
    }
    
    // MARK: - UIControlEvent
    
    /// `confirmButton` `.touchUpInside`
    @objc func confirmButtonTouchUpInside(_ sender: UIButton) {
        delegate?.popupView(self, confirmButtonTouchUpInside: sender)
    }
    
    /// `cancelButton` `.touchUpInside`
    @objc func cancelButtonTouchUpInside(_ sender: UIButton) {
        delegate?.popupView(self, cancelButtonTouchUpInside: sender)
    }
    
    /// Catch any tap gestures
    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        // do nothing
    }
    
    // MARK: - General
    
    private static func createLabel(font: UIFont) -> UILabel {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = font
        return label
    }
    
    private func createButton(selector: Selector, titleColor: UIColor, backgroundColor: UIColor) -> UIButton {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(titleColor, for: .normal)
        button.backgroundColor = backgroundColor
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.clipsToBounds = true
        button.layer.cornerRadius = Constants.buttonCornerRadius
        return button
    }
}

// MARK: - Extensions

extension UIImage {
    
    /// Tick image defined in Storm.xcassets
    static let tick = UIImage(named: "tick", in: Bundle(for: PopupView.self), compatibleWith: nil)
}

extension UIColor {
    
    static let red = UIColor(red: CGFloat(237)/255, green: CGFloat(27)/255, blue: CGFloat(46)/255, alpha: 1)
    static let lightGray = UIColor(red: CGFloat(215)/255, green: CGFloat(215)/255, blue: CGFloat(216)/255, alpha: 1)
    static let slateGray = UIColor(red: CGFloat(109)/255, green: CGFloat(110)/255, blue: CGFloat(112)/255, alpha: 1)
}


