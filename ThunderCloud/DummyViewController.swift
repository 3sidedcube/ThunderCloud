//
//  DummyViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 30/10/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// The dummy view controller is used as the placeholder view on iPad for the right hand side view controller when no item has been selected in the main view
public class DummyViewController: UIViewController {
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = ThemeManager.shared.theme.backgroundColor
	}
}
