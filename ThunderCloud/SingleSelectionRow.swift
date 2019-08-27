//
//  SingleSelectionRow.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 08/09/2017.
//  Copyright © 2017 3sidedcube. All rights reserved.
//

import UIKit
import ThunderTable

open class SingleSelectionRow: InputTableRow {
	
    override open var cellClass: UITableViewCell.Type? {
		return SingleSelectionTableViewCell.self
	}
	
	var checkCornerRadius: CGFloat = 14.0
	
	private var indexPath: IndexPath?
	
	private var tableView: UITableView?
	
	init(title: String?, id: String, required: Bool = false) {
		super.init(id: id, required: required)
		self.title = title
		
		selectionHandler = {  (row, selected, indexPath, tableView) -> Void in
			guard let cell = tableView.cellForRow(at: indexPath) as? SingleSelectionTableViewCell else { return }
            cell.checkView.image = ((selected ? #imageLiteral(resourceName: "check-on") : #imageLiteral(resourceName: "check-off")) as StormImageLiteral).image
			self.set(value: selected, sender: nil)
		}
		
		value = false
	}
	
	override init(id: String, required: Bool) {
		super.init(id: id, required: required)
		value = false
	}
	
    override open func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		self.indexPath = indexPath
		self.tableView = tableViewController.tableView
		
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		
		guard let selectionCell = cell as? SingleSelectionTableViewCell else { return }
				
		guard let boolValue = value as? Bool else {
			selectionCell.checkView.image = (#imageLiteral(resourceName: "check-on") as StormImageLiteral).image
			return
		}
        selectionCell.checkView.image = ((boolValue ? #imageLiteral(resourceName: "check-on") : #imageLiteral(resourceName: "check-off")) as StormImageLiteral).image
	}
	
    override open var accessoryType: UITableViewCell.AccessoryType? {
		get {
			return UITableViewCell.AccessoryType.none
		}
		set {}
	}
	
    override open var selectionStyle: UITableViewCell.SelectionStyle? {
		get {
			return UITableViewCell.SelectionStyle.none
		}
		set {}
	}
	
    override open var remainSelected: Bool {
		return true
	}
}
