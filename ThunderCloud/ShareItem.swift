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

/// `UIActivityItemSource` wrapping `shareObject` to act as a proxy for the corresponding
/// data in situations where you do not want to provide that data until it is needed.
///
/// This class is motivated by not being able to share multiple items (such as both an image and text)
/// to other applications. For example, at time of writing, you could not share both an image and a caption
/// with Facebook. It would take only one or the other, but not both. So this class allows us to define a primary item
/// which we choose to share if we are bounded by such limitations.
///
/// - Note:
/// I believe, when creating an `UIActivityViewController` the `activityItems` must each conform
/// to `UIActivityItemSource` opposed to a single `UIActivityItemSource` with many items.
/// So, to handle `LPLinkMetadata` etc we track the item with the `isPrimaryItem` flag.
open class ShareItem: NSObject, UIActivityItemSource {

    /// Object to share
    public let shareObject: Any

    /// Implementation of `UIActivityItemSource` should contribute to the header (UI) of
    /// `UIActivityViewController` when sharing.
    ///
    /// When `false`, this implementation effectively only includes the `shareObject` as an item
    /// and makes no attempt to contribute to the `UIActivityViewController` UI.
    /// E.g. when sharing an `[ShareItem]` have only 1 where this is `true` to define the
    /// UI of the header.
    public let isPrimaryItem: Bool

    /// `ShareProvider`
    public let shareProvider: ShareProvider

    /// Default memberwise initializer
    ///
    /// - Parameters:
    ///   - shareObject: `Any`
    ///   - isPrimaryItem: `Bool`
    ///   - shareProvider: `ShareProvider`
    public init (
        shareObject: Any,
        isPrimaryItem: Bool,
        shareProvider: ShareProvider
    ) {
        self.shareObject = shareObject
        self.isPrimaryItem = isPrimaryItem
        self.shareProvider = shareProvider
    }

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
        return shareProvider.subjectForShareItem(self, for: activityType)
    }

    open func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        // Do not guard `isPrimaryItem` here
        guard shareProvider.shouldShareItem(self, for: activityType) else { return nil }
        return shareObject
    }

    @available(iOS 13, *)
    open func activityViewControllerLinkMetadata(
        _ activityViewController: UIActivityViewController
    ) -> LPLinkMetadata? {
        guard isPrimaryItem else { return nil }
        return shareProvider.linkMetadata()
    }
}
