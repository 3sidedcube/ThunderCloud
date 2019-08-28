//
//  AppCollectionItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 02/11/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

/// A model representation of an app to be shown in a `TSCAppScrollerItemViewCell`
open class AppCollectionItem: StormObjectProtocol {
    
    /// Defines the keys used to decode this data object.
    enum DecoderKeys: String {
        case icon
        case identifier
        case overlay
    }
    
    /// The app's icon - derived from "icon"
    public let appIcon: StormImage?
    
    /// The app's name - derived from "overlay"
    public let appName: String?
    
    /// The app identity for the app, contains information on the URL schemes, app name, iTunes id e.t.c. - derived from "identifier"
    public let app: AppIdentity?
    
    /// Initialises a new instance from a CMS representation of an app
    ///
    /// - Parameter dictionary: Dictionary to use to initialise and populate the app
    public required init(dictionary: [AnyHashable : Any]) {
        
        let icon = StormGenerator.image(fromJSON: dictionary[DecoderKeys.icon])
        appIcon = icon
        
        var appIdentifier: AppIdentity?
        
        if let identifier = dictionary[DecoderKeys.identifier] as? String {
            appIdentifier = AppLinkController().apps.first(where: {$0.identifier == identifier})
            app = appIdentifier
        } else {
            app = nil
        }
        
        if let overlay = dictionary[DecoderKeys.overlay] as? [AnyHashable: Any] {
            appName = StormLanguageController.shared.string(for: overlay) ?? appIdentifier?.name
        } else {
            appName = app?.name
        }
    }
}
