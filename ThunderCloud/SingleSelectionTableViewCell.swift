//
//  SingleSelectionTableViewCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 07/08/2017.
//  Copyright © 2017 3sidedcube. All rights reserved.
//

import UIKit
import ThunderBasics
import ThunderTable

class SingleSelectionTableViewCell: TableViewCell {

    @IBOutlet weak var checkView: UIImageView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        checkView.image = ((selected ? #imageLiteral(resourceName: "check-on") : #imageLiteral(resourceName: "check-off")) as StormImageLiteral).image
    }
}
