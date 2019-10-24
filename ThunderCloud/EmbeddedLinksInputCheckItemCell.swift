//
//  EmbeddedLinksInputCheckItemCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 07/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// `EmbeddedLinksInputCheckItemCell` is an `StormTableViewCell` that has a checkView for ticking on and off items
open class EmbeddedLinksInputCheckItemCell: StormTableViewCell {

	/// The check view for toggling on and off this item
	@IBOutlet weak var checkView: CheckView!
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}
	
    override open func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}
	
	func setup() {
		
		separatorInset = .zero
		layoutMargins = .zero
		preservesSuperviewLayoutMargins = true
		
		let tapGesture = UITapGestureRecognizer(target: self.checkView, action: #selector(CheckView.handleTap(sender:)))
		self.contentView.addGestureRecognizer(tapGesture)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
    
    override open var accessibilityTraits: UIAccessibilityTraits {
        get {
            return checkView.isSelected ? [.selected, .button] : [.button]
        }
        set { }
    }
    
    override open var isAccessibilityElement: Bool {
        get {
            return true
        }
        set { }
    }
    
    override open var accessibilityLabel: String? {
        get {
            return cellTextLabel?.text
        }
        set { }
    }
    
    override open var accessibilityHint: String? {
        get {
            return checkView.isSelected ?
                "Selectable. Double tap to de-select".localised(with: "_CHECKITEM_VOICEOVER_HINT_SELECTED") :
                "Selectable. Double tap to select".localised(with: "_CHECKITEM_VOICEOVER_HINT_UNSELECTED")
        }
        set { }
    }
}
