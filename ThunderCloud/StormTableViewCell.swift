//
//  StormTableViewCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 30/06/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation
import ThunderTable

open class StormTableViewCell: TableViewCell {
	
	/// The cells parent view controller (Set in configureCell func within ListItem)
	weak public var parentViewController: TableViewController?
}
