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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
    
    private var separatorView: UIView?
    
    private func setup() {
        
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        backgroundView = UIView()
        backgroundView?.backgroundColor = .white
        backgroundView?.layer.borderWidth = 1/UIScreen.main.scale
        backgroundView?.layer.borderColor = UIColor(hexString: "9B9B9B")?.cgColor
        backgroundView?.layer.cornerRadius = 2.0
        backgroundView?.layer.masksToBounds = true
        
        contentView.addSubview(backgroundView!)
        contentView.sendSubviewToBack(backgroundView!)
        
        separatorView = UIView()
        separatorView?.backgroundColor = UIColor(hexString: "9B9B9B")
        backgroundView!.addSubview(separatorView!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundView?.frame = CGRect(x: 8, y: 8, width: contentView.bounds.width-16, height: contentView.bounds.height - 8)
        guard let cellTextLabelContainer = cellTextLabel?.superview else {
            separatorView?.frame = .zero
            return
        }
        separatorView?.frame = CGRect(x: cellTextLabelContainer.frame.maxX, y: 0, width: 1/UIScreen.main.scale, height: backgroundView?.frame.height ?? 0)
    }
}
