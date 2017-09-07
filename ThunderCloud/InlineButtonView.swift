//
//  InlineButtonView.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/09/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderBasics

/// InlineButtonView is a `TSCButton` that is used inside of cells to display embedded links.
@objc(TSCInlineButtonView)
open class InlineButtonView: TSCButton {

	/// The `TSCLink` to determine what action is performed when the button is pressed
	open var link: TSCLink?
	
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
	
	open override var intrinsicContentSize: CGSize {
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
}
