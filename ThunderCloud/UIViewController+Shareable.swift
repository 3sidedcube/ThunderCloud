//
//  UIViewController+Shareable.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 16/03/2021.
//  Copyright © 2021 threesidedcube. All rights reserved.
//

import Foundation
import UIKit

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
    ///   - shareable: `Shareable` entity to share
    ///   - defaultShareMessage: Message to share if `badge.shareMessage` is `nil`
    ///   - sourceView: `ShareSourceView`
    ///   - completionHandler: Handle completion on `UIActivityViewController`
    func presentShare(
        _ shareable: Shareable,
        defaultShareMessage: String,
        sourceView: ShareSourceView,
        completionHandler: UIActivityViewController.CompletionWithItemsHandler? = nil
    ) {
        // Get `ShareItem`s to share
        let shareItems = shareable.shareItems(defaultMessage: defaultShareMessage)

        // Only present if there is something to share
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
