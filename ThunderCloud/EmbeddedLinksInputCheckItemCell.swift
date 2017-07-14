//
//  EmbeddedLinksInputCheckItemCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 07/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// `EmbeddedLinksInputCheckItemCell` is an `EmbeddedLinksListItemCell` that has a checkView for ticking on and off items
class EmbeddedLinksInputCheckItemCell: EmbeddedLinksListItemCell {

	/// The check view for toggling on and off this item
	@IBOutlet weak var checkView: TSCCheckView!
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}
	
	func setup() {
		
		separatorInset = .zero
		layoutMargins = .zero
		preservesSuperviewLayoutMargins = true
		
		let tapGesture = UITapGestureRecognizer(target: self.checkView, action: #selector(TSCCheckView.handleTap(_:)))
		self.checkView.addGestureRecognizer(tapGesture)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}
