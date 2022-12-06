//
//  ShareItemBuilder.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 23/03/2021.
//  Copyright © 2021 threesidedcube. All rights reserved.
//

import Foundation
import LinkPresentation

/// Create an `[ShareItem]` wrapping an `LPLinkMetadata`
public struct ShareItemBuilder: ShareProvider {

    /// Define the subject when sharing `ShareItem` for `UIActivity.ActivityType`
    public typealias ActivityTypeSubjectClosure = (ShareItem, UIActivity.ActivityType?) -> String?

    /// Define the item when sharing `ShareItem` for `UIActivity.ActivityType`
    public typealias ActivityTypeItemClosure = (ShareItem, UIActivity.ActivityType?) -> Any?

    // MARK: - Share Properties

    /// `UIImage` to share
    public var image: UIImage?

    /// `String` text to share
    public var text: String?

    /// `URL` to share
    public var url: URL?

    /// Other items to share
    public var other: [Any]

    // MARK: - Metadata Properties

    /// `ActivityTypeSubjectClosure` to specify a subject for a `ShareItem`
    public var subjectForActivityType: ActivityTypeSubjectClosure?

    /// `ActivityTypeItemClosure` to map the sharable entity for a `ShareItem`
    public var itemForActivityType: ActivityTypeItemClosure?

    // MARK: - Init

    /// Default memberwise initializer
    ///
    /// - Parameters:
    ///   - image: `UIImage?`
    ///   - text: `String?`
    ///   - url: `URL?`
    ///   - other: `[Any]`
    public init(
        image: UIImage? = nil,
        text: String? = nil,
        url: URL? = nil,
        other: [Any] = []
    ) {
        self.image = image
        self.text = text
        self.url = url
        self.other = other
    }

    // MARK: - Items

    /// Items in order of primary preference
    public func items() -> [Any] {
        var items: [Any] = []

        if let image = image {
            items.append(image)
        }

        if let text = text {
            items.append(text)
        }

        if let url = url {
            items.append(url)
        }

        items.append(contentsOf: other)

        return items
    }

    /// Is the first of `items()` a `UIImage`
    public func isPrimaryImage() -> Bool {
        return items().first is UIImage
    }

    /// Map `items()` to `ShareItem`s
    public func shareItems() -> [ShareItem] {
        return items().enumerated().map {
            // Make first in `items()` the primary item
            let isPrimaryItem = $0.offset == 0
            return ShareItem(
                shareObject: $0.element,
                isPrimaryItem: isPrimaryItem,
                shareProvider: self
            )
        }
    }

    // MARK: - ShareProvider

    /// Subject for `shareItem` for `activityType`
    ///
    /// - Parameters:
    ///   - shareItem: `ShareItem`
    ///   - activityType: `UIActivity.ActivityType?`
    public func subjectForShareItem(
        _ shareItem: ShareItem,
        for activityType: UIActivity.ActivityType?
    ) -> String {
        return subjectForActivityType?(shareItem, activityType) ?? ""
    }

    /// Should the `shareItem` be shared for the given `activityType`
    ///
    /// - Parameters:
    ///   - shareItem: `ShareItem`
    ///   - activityType: `UIActivity.ActivityType?`
    public func shouldShareItem(
        _ shareItem: ShareItem,
        for activityType: UIActivity.ActivityType?
    ) -> Bool {
        // Share without limitation if we don't have an `activityType`
        guard let activityType = activityType else { return true }

        // Check if our primary share item is a UIImage
        let isPrimaryImage = self.isPrimaryImage()

        // Share without limitation if our primary item is not a `UIImage`
        guard isPrimaryImage else { return true }

        // As are primary item is a `UIImage`, make sure it's only
        // the `UIImage` we share if the platform we are sharing to forces
        // image only
        guard activityType.isImageOnly() else { return true }
        return shareItem.isPrimaryItem
    }

    /// Map to shareable entity
    /// - Parameters:
    ///   - shareItem: `ShareItem`
    ///   - activityType: `UIActivity.ActivityType`
    /// - Returns: `Any`
    public func item(
        _ shareItem: ShareItem,
        for activityType: UIActivity.ActivityType?
    ) -> Any? {
        // Take closure return type nullability into account by guarding (opposed to optional chaining)
        guard let itemMapping = itemForActivityType else { return shareItem.shareObject }
        return itemMapping(shareItem, activityType)
    }

    /// Create `LPLinkMetadata`
    @available(iOS 13.0, *)
    public func linkMetadata() -> LPLinkMetadata {
        let metadata = LPLinkMetadata()

        // title
        metadata.title = text

        // imageProvider
        if let image = image {
            metadata.imageProvider = NSItemProvider(object: image)
        }

        // originalURL, url
        metadata.originalURL = url
        metadata.url = metadata.originalURL

        return metadata
    }
}
