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

    /// Map `shareable` to `[ShareItems]` and share using `UIActivityViewController`
    ///
    /// - Parameters:
    ///   - shareable: `Shareable` entity to share
    ///   - defaultShareMessage: Default message to share. (Required for legacy)
    ///   - sourceView: `ShareSourceView`
    ///   - completionHandler: Handle completion on `UIActivityViewController`
    func presentShare(
        _ shareable: Shareable,
        defaultShareMessage: String,
        sourceView: ShareSourceView,
        completionHandler: UIActivityViewController.CompletionWithItemsHandler? = nil
    ) {
        presentShare(
            shareable.shareItems(defaultMessage: defaultShareMessage),
            sourceView: sourceView,
            completionHandler: completionHandler
        )
    }

    /// Share the given `shareItems` using `UIActivityViewController`
    ///
    /// - Parameters:
    ///   - shareable: `Shareable` entity to share
    ///   - defaultShareMessage: Default message to share. (Required for legacy)
    ///   - sourceView: `ShareSourceView`
    ///   - completionHandler: Handle completion on `UIActivityViewController`
    func presentShare(
        _ shareItems: [ShareItem],
        sourceView: ShareSourceView,
        completionHandler: UIActivityViewController.CompletionWithItemsHandler? = nil
    ) {
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

// MARK: - ShareSourceView + Extensions

public extension UIViewController.ShareSourceView {

    /// Initialize with an `Any` sender
    ///
    /// - Warning:
    /// It is preferred to just instantiate a case, this is created for legacy reasons
    ///
    /// - Parameter sender: `Any` action sender
    init?(sender: Any) {
        if let barButtonItem = sender as? UIBarButtonItem {
            self = .barButtonItem(barButtonItem)
        } else if let view = sender as? UIView {
            self = .view(view)
        } else {
            return nil
        }
    }
}
