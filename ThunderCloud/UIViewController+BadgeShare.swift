//
//  UIViewController+BadgeShare.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 16/03/2021.
//  Copyright © 2021 threesidedcube. All rights reserved.
//

import Foundation
import UIKit

public extension UIViewController {

    /// Share the given `badge` using `UIActivityViewController`
    ///
    /// - Parameter badge: `Badge`
    func shareBadge(_ badge: Badge, analyticsFrom: String) {
        // `String` message to share
        let message: String = badge.shareMessage ?? .badgeShareMessage

        // `UIImage` of badge to share
        let badgeImage = badge.icon?.image

        // Map to `ShareItem`
        let shareItems = [message, badgeImage as Any]
            .compactMap { $0 }
            .map { ShareItem(shareObject: $0, isPrimaryItem: $0 is UIImage) }

        // Present a `UIActivityViewController`
        let shareViewController = UIActivityViewController(
            activityItems: shareItems,
            applicationActivities: nil
        )
        shareViewController.excludedActivityTypes = [
            .saveToCameraRoll, .print, .assignToContact
        ]

        shareViewController.completionWithItemsHandler = { (
            activityType,
            completed,
            returnedItems,
            activityError
        ) in
            NotificationCenter.default.sendAnalyticsHook(
                .badgeShare(badge, (
                    from: analyticsFrom,
                    destination: activityType,
                    shared: completed
                ))
            )
        }

        present(shareViewController, animated: true, completion: nil)
    }
}

private extension String {

    /// `String` message when sharing a badge
    static var badgeShareMessage: String {
        return "Badge Earnt".localised(with: "_TEST_COMPLETED_SHARE")
    }
}
