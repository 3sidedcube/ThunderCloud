//
//  UIViewController+BadgeShare.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 16/03/2021.
//  Copyright © 2021 threesidedcube. All rights reserved.
//

import Foundation
import UIKit
import LinkPresentation

public extension UIViewController {

    /// Source view to set `popoverPresentationController` when using iPad
    enum ShareSourceView {

        /// A `UIView`
        case view(UIView)

        /// A `UIBarButtonItem`
        case barButtonItem(UIBarButtonItem)
    }

    /// Share the given `badge` using `UIActivityViewController`
    ///
    /// - Parameters:
    ///   - badge: `Badge` to share
    ///   - defaultShareMessage: Message to share if `badge.shareMessage` is `nil`
    ///   - sourceView: `ShareSourceView`
    ///   - completionHandler: Handle completion on `UIActivityViewController`
    func shareBadge(
        _ badge: Badge,
        defaultShareMessage: String,
        sourceView: ShareSourceView,
        completionHandler: UIActivityViewController.CompletionWithItemsHandler? = nil
    ) {
        // `String` message to share
        let message: String = badge.shareMessage ?? defaultShareMessage

        // `UIImage` of badge to share
        let badgeImage = badge.icon?.image

        // Map parts to `ShareItem`
        let shareItems = [message, badgeImage as Any]
            .compactMap { $0 }
            .map {
                BadgeShareItem(
                    shareObject: $0,
                    isPrimaryItem: $0 is UIImage,
                    metadataTitle: message
                )
            }

        // Ensure there is something to share
        guard !shareItems.isEmpty else { return }

        // Create a `UIActivityViewController`
        let shareViewController = UIActivityViewController(
            activityItems: shareItems,
            applicationActivities: nil
        )
        shareViewController.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .copyToPasteboard,
            .openInIBooks,
            .print,
            .saveToCameraRoll
        ]

        // Handle iPad source view
        if UIDevice.current.userInterfaceIdiom == .pad {
            let popoverController = shareViewController.popoverPresentationController

            switch sourceView {
            case let .barButtonItem(barButtonItem):
                popoverController?.barButtonItem = barButtonItem
            case let .view(view):
                popoverController?.sourceView = view
            }
        }

        // Present the `UIActivityViewController`
        shareViewController.completionWithItemsHandler = completionHandler
        present(shareViewController, animated: true, completion: nil)
    }
}

// MARK: - BadgeShareItem

/// `ShareItem` for `Badge`s
class BadgeShareItem: ShareItem {

    /// Title for `LPLinkMetadata`
    private let metadataTitle: String

    // MARK: - Init

    init(
        shareObject: Any,
        isPrimaryItem: Bool,
        metadataTitle: String
    ) {
        self.metadataTitle = metadataTitle
        super.init(shareObject: shareObject, isPrimaryItem: isPrimaryItem)
    }

    // MARK: - UIActivityViewController

    override func activityViewController(
        _ activityViewController: UIActivityViewController,
        subjectForActivityType activityType: UIActivity.ActivityType?
    ) -> String {
        return "Share Badge".localised(with: "_BADGE_SHARE")
    }

    @available(iOS 13, *)
    override func activityViewControllerLinkMetadata(
        _ activityViewController: UIActivityViewController
    ) -> LPLinkMetadata? {
        let metadata = super.activityViewControllerLinkMetadata(activityViewController)
        metadata?.title = metadataTitle
        return metadata
    }
}
