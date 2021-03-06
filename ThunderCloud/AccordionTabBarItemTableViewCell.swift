//
//  AccordionTabBarItemTableViewCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 27/10/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

class AccordionTabBarItemTableViewCell: TableViewCell {

	@IBOutlet weak var customTitleView: UIView!
	
	@IBOutlet weak var topConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var customTitleHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var viewControllerView: UIView!
	    
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    
    override func prepareForReuse() {
		customTitleView.subviews.forEach({$0.removeFromSuperview()})
		viewControllerView.subviews.forEach({$0.removeFromSuperview()})
	}
}
