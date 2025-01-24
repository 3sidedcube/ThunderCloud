//
//  StormImageLiteral.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 15/08/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import UIKit

private class StormClassForBundle {
    
}

/// A wrapper for Image Literals which allow them being pulled from `StormAssets.xcassets`
struct StormImageLiteral: _ExpressibleByImageLiteral {
    
    /// The final image which was found in the storm assets
    let image: UIImage?
    
    init(imageLiteralResourceName name: String) {
        let bundle = Bundle(for: StormClassForBundle.self)
        image = UIImage(named: name, in: bundle, compatibleWith: nil)
    }
}
