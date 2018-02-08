//
//  IdentifiableViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 02/11/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation
import ObjectiveC

public extension UIViewController {
	
	private struct AssociatedKeys {
		static var pageIdentifier = "tsc_pageIdentifier"
	}
	
	var pageIdentifier: String? {
		get {
			return objc_getAssociatedObject(self, &AssociatedKeys.pageIdentifier) as? String
		}
		set {
			if let newValue = newValue {
				objc_setAssociatedObject(self, &AssociatedKeys.pageIdentifier, newValue as NSString, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			} else {
				objc_setAssociatedObject(self, &AssociatedKeys.pageIdentifier, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			}
		}
	}
}
