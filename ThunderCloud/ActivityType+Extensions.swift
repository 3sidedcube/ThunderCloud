//
//  ActivityType+Extensions.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 23/03/2021.
//  Copyright © 2021 threesidedcube. All rights reserved.
//

import Foundation
import UIKit

extension UIActivity.ActivityType {

    /// Some social media platforms do not support sharing image, text, and a link.
    /// For some, if we attempt to share all 3, it would only pick up 1, e.g. the text.
    ///
    /// Handle the popular social media platforms which do not work with all 3 here.
    func isImageOnly() -> Bool {
        let imageOnlyActivityTypes: [UIActivity.ActivityType] = [
            .postToFacebook,
            .fbMessenger,
            .whatsApp,
            .slack
        ]
        return imageOnlyActivityTypes.contains(self)
    }
}
