//
//  EditLocalisationTableViewCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 06/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderBasics
import ThunderTable

/// A cell for allowing the user to edit a localisation for a certain language
class EditLocalisationTableViewCell: InputTextViewCell {

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}
	
	private var separatorView: TSCView?
	
	private func setup() {
		
		contentView.backgroundColor = .clear
		backgroundColor = .clear
		
		backgroundView = TSCView()
		backgroundView?.backgroundColor = .white
		backgroundView?.borderWidth = 1/UIScreen.main.scale
		backgroundView?.borderColor = UIColor(hexString: "9B9B9B")
		backgroundView?.cornerRadius = 2.0
		
		contentView.addSubview(backgroundView!)
		contentView.sendSubview(toBack: backgroundView!)
		
		separatorView = TSCView()
		separatorView?.backgroundColor = UIColor(hexString: "9B9B9B")
		backgroundView!.addSubview(separatorView!)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		backgroundView?.frame = CGRect(x: 8, y: 8, width: contentView.bounds.width-16, height: contentView.bounds.height - 8)
		guard let cellTextLabel = cellTextLabel else {
			separatorView?.frame = .zero
			return
		}
		separatorView?.frame = CGRect(x: cellTextLabel.frame.maxX, y: 0, width: 1/UIScreen.main.scale, height: backgroundView?.frame.height ?? 0)
	}
}
