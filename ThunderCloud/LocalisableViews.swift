//
//  TSCLocalisableViews.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 24/11/2016.
//  Copyright © 2016 threesidedcube. All rights reserved.
//

import Foundation
import ThunderBasics

/// A designable UILabel subclass which is localisable from interface builder
@IBDesignable
open class LocalisableLabel: TSCLabel {
    
    /// The localisation key which should be used to populate the `text` property on this label
    @IBInspectable public var localisationKey: String? {
        didSet {
            updateText()
        }
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        updateText()
    }
    
    private func updateText() {
        
        guard let localisationKey = localisationKey else { return }
        
        if let text = text {
            self.text = text.localised(with: localisationKey)
        } else {
            text = "".localised(with: localisationKey)
        }
    }
}

/// A designable UIButton subclass which is localisable from interface builder
@IBDesignable
open class LocalisableButton: TSCButton {
    
    /// The localisation key which should be used to populate the `text` property on this label
    @IBInspectable public var localisationKey: String? {
        didSet {
            updateText()
        }
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        updateText()
    }
    
    private func updateText() {
        
        guard let localisationKey = localisationKey else { return }
        
        if let title = title(for: .normal) {
            setTitle(title.localised(with: localisationKey), for: .normal)
        } else {
            setTitle("".localised(with: localisationKey), for: .normal)
        }
    }

}


