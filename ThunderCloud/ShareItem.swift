//
//  ShareItem.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 16/03/2021.
//  Copyright © 2021 threesidedcube. All rights reserved.
//

import Foundation
import UIKit
import LinkPresentation

/// Delegate functionality for `ShareItem`
public protocol ShareItemDelegate: AnyObject {

    /// Return the subject for the given `activityType`
    ///
    /// - Parameters:
    ///   - activityType: `UIActivity.ActivityType`
    ///   - activityViewController: `UIActivityViewController`
    func subjectForActivityType(
        _ activityType: UIActivity.ActivityType?,
        activityViewController: UIActivityViewController
    ) -> String

    /// Configure the given `metadata`
    ///
    /// - Parameters:
    ///   - metadata: `LPLinkMetadata`
    ///   - activityViewController: `UIActivityViewController`
    @available(iOS 13, *)
    func configureMetaData(
        _ metadata: LPLinkMetadata,
        activityViewController: UIActivityViewController
    )
}

/// `UIActivityItemSource` wrapping `shareObject` to act as a proxy for the corresponding
/// data in situations where you do not want to provide that data until it is needed.
///
/// This class is motivated by not being able to share multiple items, such as (both) an image and text
/// to other applications. For example, at time of writing, you could not share both an image and a caption
/// with Facebook. It would take only one or the other, but not both. So this class allows us to define a primary item
/// which we choose to share if we are bounded by such limitations.
open class ShareItem: NSObject, UIActivityItemSource {

    /// Object to share
    public let shareObject: Any

    /// Implementation of `UIActivityItemSource` should contribute to the header (UI) of
    /// `UIActivityViewController` when sharing.
    ///
    /// When `false`, this implementation effectively only includes the `shareObject` as an item
    /// and makes no attempt to contribute to the `UIActivityViewController` UI.
    /// E.g. when sharing an `Array<ShareItem>` have only 1 where this is `true` to define the
    /// UI of the header.
    public let isPrimaryItem: Bool

    /// `ShareItemDelegate`
    open weak var delegate: ShareItemDelegate?

    /// Default memberwise initializer
    ///
    /// - Parameters:
    ///   - shareObject: `Any`
    ///   - isPrimaryItem: `Bool`
    public init (shareObject: Any, isPrimaryItem: Bool) {
        self.shareObject = shareObject
        self.isPrimaryItem = isPrimaryItem
    }

    // The placeholder the share sheet will use while metadata loads
    open func activityViewControllerPlaceholderItem(
        _ activityViewController: UIActivityViewController
    ) -> Any {
        guard isPrimaryItem else { return NSNull() }
        return shareObject
    }

    open func activityViewController(
        _ activityViewController: UIActivityViewController,
        subjectForActivityType activityType: UIActivity.ActivityType?
    ) -> String {
        guard isPrimaryItem else { return "" }
        return delegate?.subjectForActivityType(
            activityType,
            activityViewController: activityViewController
        ) ?? ""
    }

    // The item we want the user to act on.
    // In this case, it's the URL to the ARC page
    open func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        // Some social media platforms do not support sharing image,
        // text, and a link. For some, if we attempt to share all 3,
        // it would only pick up 1, e.g. the text.
        //
        // Handle the popular social media platforms which do not work
        // with all 3 here.
        let imageOnlyActivityTypes: [UIActivity.ActivityType] = [
            .postToFacebook,
            .fbMessenger,
            .whatsApp,
            .slack
        ]

        if !isPrimaryItem,
           let activityType = activityType,
           imageOnlyActivityTypes.contains(activityType) {
            return nil
        }

        return shareObject
    }

    @available(iOS 13, *)
    open func activityViewControllerLinkMetadata(
        _ activityViewController: UIActivityViewController
    ) -> LPLinkMetadata? {
        guard isPrimaryItem else { return nil }
        let metadata = LPLinkMetadata()

        // imageProvider
        if let image = shareObject as? UIImage {
            metadata.imageProvider = NSItemProvider(object: image)
        }

        // Configure the metadata
        delegate?.configureMetaData(
            metadata,
            activityViewController: activityViewController
        )

        return metadata
    }
}
