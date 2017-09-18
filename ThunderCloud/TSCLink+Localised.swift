//
//  TSCLink+Localised.swift
//  ThunderCloud
//
//  Created by Joel Trew on 18/09/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

public extension TSCLink {
    
    public func linkFromLocalisedLink(with dictionary: [AnyHashable: Any]) {
        
        guard let urlDictionaries = dictionary["links"] as? [[AnyHashable: Any]] else { return }
        
        guard let urlType = dictionary["type"] as? String else { return }
        
        self.linkClass = urlType
        
        let urls = urlDictionaries.flatMap({ LocalisedLinkContents(from: $0) })

        let selectedLink = urls.filter({ (linkContent) -> Bool in

            let languagePack = StormLanguageController.shared.languagePack(forLocaleIdentifier: linkContent.localeIdentifier)
           return languagePack?.fileName == StormLanguageController.shared.currentLanguage
        }).first
        
        
        // Set the TSCLink's url property to the selected locales url, if that doesn't exist fall back to the first link or nil if that doens't exist
        if let selectedLink = selectedLink {
            self.url = selectedLink.src
        } else {
            self.url = urls.first?.src
        }
    }
    
    
    struct LocalisedLinkContents {
        
        var className: String?
        var src: URL
        var localeIdentifier: String
        
        init?(from dictionary: [AnyHashable: Any]) {
            
            self.className = dictionary["class"] as? String
            
            guard let srcString = dictionary["src"] as? String else {
                return nil
            }
            guard let src = URL(string: srcString) else {
                return nil
            }
            self.src = src
            
            guard let localeString = dictionary["locale"] as? String else {
                return nil
            }
            
            self.localeIdentifier = localeString
        }
    }
}
