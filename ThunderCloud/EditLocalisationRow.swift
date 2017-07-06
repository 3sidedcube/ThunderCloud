//
//  EditLocalisationRow.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 06/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// A table view row for allowing a user to edit a localisation for a specific language
class EditLocalisationRow: InputTextViewRow {
	
	private let localisation: LocalisationKeyValue

	/// Initialises a new row for editing a particular localisation
	///
	/// - Parameter localisation: The localisation key value pair that this row is for editing
	init(localisation: LocalisationKeyValue) {
		
		self.localisation = localisation
		super.init(title: TSCLocalisationController.shared().localisedLanguageName(forLanguageKey: localisation.languageCode), placeholder: nil, id: localisation.languageCode, required: true)
		language = localisation.language
		value = localisation.localisedString
	}
	
	var language: LocalisationLanguage?
	
	override var cellClass: AnyClass? {
		return EditLocalisationTableViewCell.self
	}
}
