//
//  ToggleableListItemCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 05/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// `ToggleableListItemCell` is a subclass of `StormTableViewCell` which when selected opens up to reveal the detail text label.
open class ToggleableListItemCell: StormTableViewCell {

	/// Boolean to determine whether the cell is displaying the detail text label
	open var isFullyVisible: Bool = false {
		didSet {
			let bundle = Bundle(for: ToggleableListItemCell.self)
			if isFullyVisible {
				cellDetailLabel?.isHidden = false
				embeddedLinksStackView.isHidden = false
				chevronImageView.image = UIImage(named: "chevron-up", in: bundle, compatibleWith: nil)
			} else {
				cellDetailLabel?.isHidden = true
				embeddedLinksStackView.isHidden = true
				chevronImageView.image = UIImage(named: "chevron-down", in: bundle, compatibleWith: nil)
			}
		}
	}
    
    override open class func awakeFromNib() {
        super.awakeFromNib()
        setIsAccessibilityElement(true)
    }
    
    override open var accessibilityLabel: String? {
        get {
            return isFullyVisible ? [cellTextLabel?.text, cellDetailLabel?.text].compactMap({ $0 }).joined(separator: ".") : cellTextLabel?.text
        }
        set { }
    }

    override open var accessibilityHint: String? {
        get {
            return isFullyVisible ?
                "Collapsable. Double tap to collapse.".localised(with: "_VOICEOVER_TOGGLEABLELISTITEM_HINT_EXPANDED")
                : "Collapsable. Double tap to expand.".localised(with: "_VOICEOVER_TOGGLEABLELISTITEM_HINT_COLLAPSED")
        }
        set { }
    }
	
	@IBOutlet weak public var chevronImageView: UIImageView!
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}
