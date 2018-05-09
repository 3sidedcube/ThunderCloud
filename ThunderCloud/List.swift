//
//  List.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// `List` is a `StormObject` that represents a `TableSection` and conforms to `Section`. Each section in a storm generated table view will be represented as a `List`
open class List: StormObject, Section {
    
    /// The closure to edit the section
    public var editHandler: EditHandler?

	/// The table section's header
	open var header: String?
	
	/// The table section's footer
	open var footer: String?
	
	/// The table section's rows
	open var rows: [Row] = []
	
	required public init(dictionary: [AnyHashable : Any]) {
		
		if let headerDict = dictionary["header"] as? [AnyHashable : Any] {
			header = StormLanguageController.shared.string(for: headerDict)
		}
		
		if let footerDict = dictionary["footer"] as? [AnyHashable : Any] {
			footer = StormLanguageController.shared.string(for: footerDict)
		}
		
		if let children = dictionary["children"] as? [[AnyHashable : Any]] {
			
			rows = children.compactMap({ (child) -> Row? in
				return StormObjectFactory.shared.stormObject(with: child) as? Row
			})
		}
		
		super.init(dictionary: dictionary)
	}
}
