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
    
    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return isSelected ? [.selected, .button] : [.button]
        }
        set { }
    }
    
    override var isAccessibilityElement: Bool {
        get {
            return true
        }
        set { }
    }
    
    override var accessibilityLabel: String? {
        get {
            return cellTextLabel?.text
        }
        set { }
    }
    
    override var accessibilityHint: String? {
        get {
            return isSelected ?
                "Selectable. Double tap to de-select".localised(with: "_QUIZ_VOICEOVER_TEXTITEM_HINT_SELECTED") :
                "Selectable. Double tap to select".localised(with: "_QUIZ_VOICEOVER_TEXTITEM_HINT_UNSELECTED")
        }
        set { }
    }
}
