//
//  EditLocalisationRow.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 06/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// A table view row for allowing a user to edit a localisation for a specific language
class EditLocalisationRow: InputTextViewRow {
	
	private let localisation: LocalisationKeyValue

	/// Initialises a new row for editing a particular localisation
	///
	/// - Parameter localisation: The localisation key value pair that this row is for editing
	init(localisation: LocalisationKeyValue) {
		
		self.localisation = localisation
				
		super.init(title: localisation.language?.languageName ?? localisation.locale?.languageName, placeholder: nil, id: localisation.languageCode, required: true)
		language = localisation.language
        locale = localisation.locale
		value = localisation.localisedString
	}
	
	var language: LocalisationLanguage?
    
    var locale: LocalisationLocale?
	
	override var cellClass: UITableViewCell.Type? {
		return EditLocalisationTableViewCell.self
	}
	
	override var textViewHeight: CGFloat {
		get {
			return 89
		}
		set {
			super.textViewHeight = newValue
		}
	}
	
	override func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		
		guard let editLocalisationCell = cell as? EditLocalisationTableViewCell, let languageCode = language?.languageCode ?? locale?.languageCode else { return }
		
		let languageDirection = Locale.characterDirection(forLanguage: languageCode)
		editLocalisationCell.textView.textAlignment = languageDirection == .rightToLeft ? .right : .left
	}
	
	override var selectionStyle: UITableViewCell.SelectionStyle? {
		get {
			return UITableViewCell.SelectionStyle.none
		}
		set {}
	}
	
	override var accessoryType: UITableViewCell.AccessoryType? {
		get {
			return UITableViewCell.AccessoryType.none
		}
		set {}
	}
	
	override var displaySeparators: Bool {
		get {
			return false
		}
		set {}
	}
}
