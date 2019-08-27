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
    
    /// The app's icon
    public let appIcon: StormImage?
    
    /// The app's name
    public let appName: String?
    
    /// The app's price
    public let appPrice: String?
    
    /// The app identity for the app, contains information on the URL schemes, app name, iTunes id e.t.c.
    public let app: AppIdentity?
    
    /// Initialises a new instance from a CMS representation of an app
    ///
    /// - Parameter dictionary: Dictionary to use to initialise and populate the app
    public required init(dictionary: [AnyHashable : Any]) {
        
        let icon = StormGenerator.image(fromJSON: dictionary["icon"])
        appIcon = icon
        
        var appIdentifier: AppIdentity?
        
        if let identifier = dictionary["identifier"] as? String {
            appIdentifier = AppLinkController().apps.first(where: {$0.identifier == identifier})
            app = appIdentifier
        } else {
            app = nil
        }
        
        if let nameKey = dictionary["name"] as? String {
            appName = StormLanguageController.shared.string(forKey: nameKey) ?? appIdentifier?.name
        } else {
            appName = app?.name
        }
        
        if let priceDictionary = dictionary["overlay"] as? [AnyHashable : Any] {
            appPrice = StormLanguageController.shared.string(for: priceDictionary)
        } else {
            appPrice = nil
        }
    }
}
