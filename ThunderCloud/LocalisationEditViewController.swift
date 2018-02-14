//
//  LocalisationEditViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 07/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// A protocol used to communicate changes made in an instance of `LocalisationEditViewController`
@objc(TSCLocalisationEditViewControllerDelegate)
public protocol LocalisationEditViewControllerDelegate {
	
	/// Method is called when the user cancels editing a storm localisation
	///
	/// - Parameter viewController: The view controller in which the editing was cancelled
	func editingCancelled(in viewController: LocalisationEditViewController)
	
	/// This method is called when the user has requested the changes they made to a localisation be saved
	///
	/// - Parameter viewController: The view controller in which the editing occured
	func editingSaved(in viewController: LocalisationEditViewController?)
}

/// Used to display and allow editing of CMS localisation values
@objc(TSCLocalisationEditViewController)
public class LocalisationEditViewController: TableViewController {

    //MARK: -
	//MARK: Public API
	//MARK: -
	
	/// The localisation that is being edited
	public var localisation: Localisation?
	
	/// The delegate which will be notified of the user editing or cancelling editing of the localisation
	@objc public var delegate: LocalisationEditViewControllerDelegate?
	
	/// Whether is a new localisation
	private var isNewLocalisation = false
	
	/// Creates a new instance with a localisation to be edited.
	///
	/// This method should be used if the localisation is already set in the CMS and has been allocated as an instance of `Localisation`
	///
	/// - Parameter localisation: The localisation to be edited
	@objc public init(withLocalisation localisation: Localisation) {
		
		self.localisation = localisation
		super.init(style: .grouped)
		
		title = "Edit"
	}
	
	/// Creates a new instance with a localisation key.
	///
	/// This method should be used if the localisation isn't set on the CMS, it creates a new `Localisation` object with all the available languages for the app.
	///
	/// - Parameter localisationKey: The key to save the localisation as in the CMS
	@objc public init(withKey localisationKey: String) {
		
		guard let languages = LocalisationController.shared.availableLanguages else {
			super.init(style: .grouped)
			return
		}
		
		localisation = Localisation(availableLanguages: languages, key: localisationKey)
		super.init(style: .grouped)
		
		isNewLocalisation = true
		title = "Edit"
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	private var cancelButton: UIButton?
	
	private var saveButton: UIButton?
	
	//MARK: -
	//MARK: View LifeCycle
	//MARK: -
	override public func viewDidLoad() {
		
		super.viewDidLoad()
		
		view.backgroundColor = UIColor(hexString: "E2E9F0")
		
		navigationController?.navigationBar.barTintColor = .white
		navigationController?.navigationBar.tintColor = .white
		navigationController?.navigationBar.titleTextAttributes = [
			.foregroundColor: UIColor.black,
			.font: UIFont.systemFont(ofSize: 17)
		]
		
		saveButton = UIButton(frame: CGRect(x: 0, y: 0, width: 53, height: 27))
		saveButton?.addTarget(self, action: #selector(handleSave(sender:)), for: .touchUpInside)
		saveButton?.setTitle("Save", for: .normal)
		saveButton?.layer.backgroundColor = UIColor(hexString: "72D33B").cgColor
		saveButton?.titleLabel?.font = UIFont.systemFont(ofSize: 13)
		saveButton?.layer.cornerRadius = 2.0
		saveButton?.alpha = 0.5
		saveButton?.isUserInteractionEnabled = false
		
		cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 67, height: 27))
		cancelButton?.addTarget(self, action: #selector(handleCancel(sender:)), for: .touchUpInside)
		cancelButton?.setTitle("Cancel", for: .normal)
		cancelButton?.layer.backgroundColor = UIColor(hexString: "FF3B39").cgColor
		cancelButton?.titleLabel?.font = UIFont.systemFont(ofSize: 13)
		cancelButton?.layer.cornerRadius = 2.0
		
		navigationController?.navigationBar.addSubview(saveButton!)
		navigationController?.navigationBar.addSubview(cancelButton!)
		
		reload()
	}
	
	override public func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		saveButton?.frame = CGRect(x: view.bounds.width - 53 - 6, y: 44 - 27 - 12, width: 53, height: 27)
		cancelButton?.frame = CGRect(x: 6, y: 44 - 27 - 12, width: 67, height: 27)
	}
	
	override public var preferredStatusBarStyle: UIStatusBarStyle {
		return .default
	}
	
	func reload() {
		
		guard let localisation = localisation else {
			data = []
			return
		}
		
		let rows = localisation.localisationValues.map { (keyValue) -> Row in
			let editRow = EditLocalisationRow(localisation: keyValue)
			editRow.valueChangeHandler = { [weak self] (value, sender) -> Void in
				
				if let missingInputRows = self?.missingRequiredInputRows, missingInputRows.count > 0 {
					
					self?.saveButton?.alpha = 0.5
					self?.saveButton?.isUserInteractionEnabled = false
					
				} else {
					
					self?.saveButton?.alpha = 1.0
					self?.saveButton?.isUserInteractionEnabled = true
				}
			}
			return editRow
		}
		
		data = [
			TableSection(rows: rows, header: localisation.localisationKey, footer: isNewLocalisation ? "This string is not currently in the CMS, saving it will add it." : nil, selectionHandler: nil)
		]
	}
	
	//MARK: -
	//MARK: Actions handlers
	//MARK:
	@objc private func handleSave(sender: UIButton) {
		
		guard let inputDictionary = inputDictionary as? [String : String] else {
			dismissAnimated()
			return
		}
		inputDictionary.forEach { (keyValue) in
			
			guard let localisation = localisation else { return }
			localisation.set(localisedString: keyValue.value, for: keyValue.key)
			LocalisationController.shared.add(editedLocalisation: localisation)
		}
		
		if let selectedIndex = selectedIndexPath, let cell = tableView.cellForRow(at: selectedIndex) as? EditLocalisationTableViewCell {
			cell.setEditing(false, animated: true)
		}
		
		dismissAnimated()
		delegate?.editingSaved(in: self)
	}
	
	@objc private func handleCancel(sender: UIButton) {
		
		if let selectedIndex = selectedIndexPath, let cell = tableView.cellForRow(at: selectedIndex) as? EditLocalisationTableViewCell {
			cell.setEditing(false, animated: true)
		}
		
		dismissAnimated()
		delegate?.editingCancelled(in: self)
	}
}
