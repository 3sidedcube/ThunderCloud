//
//  TSCLink+Localised.swift
//  ThunderCloud
//
//  Created by Joel Trew on 18/09/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

public extension TSCLink {
    
    /// Helper to initialise a localised link. This is called in TSCLink's initWithDictionary. The method will attempt to correctly initialise the link's url property from the dictionary by matching against the current language.
    ///
    /// The method will attempt to find a full match first i.e if the users language is usa_eng it will try to match that, failing that it will fall back to basic eng, and finally fall back to the first url in the links array.
    ///
    ///
    /// - Parameter dictionary: The initialisation dictionary passed from initWithDictionary
    public func linkFromLocalisedLink(with dictionary: [AnyHashable: Any]) {
        
        guard let urlDictionaries = dictionary["links"] as? [[AnyHashable: Any]] else { return }
        
        guard let urlType = dictionary["type"] as? String else { return }
        
        self.linkClass = urlType
        
        let urls = urlDictionaries.flatMap({ LocalisedLinkContents(from: $0) })
        
        
        func findLinkForLocale(using urls: [TSCLink.LocalisedLinkContents]) -> TSCLink.LocalisedLinkContents? {
            
            var selectedUrlContents: TSCLink.LocalisedLinkContents? = nil
            
            guard let currentLanguage = StormLanguageController.shared.currentLanguage else {
                return nil
            }
            
            for urlContents in urls {
                
                guard let languagePack = StormLanguageController.shared.languagePack(forLocaleIdentifier: urlContents.localeIdentifier) else {
                    continue
                }
                
                // If the fileName is an exact match to the currently set language we have an exact region and language match, so lets return early
                if languagePack.fileName == currentLanguage {
                    return urlContents
                }
                
                // If the languageCode matches the currentLanguage
                if languagePack.locale.languageCode == StormLanguageController.shared.locale(for: currentLanguage)?.languageCode {
                    
                    // Prefer base language over region specific by checking if there is already a selectedUrlContents and that its locale regioncode is nil, i.e prefer eng over bra_eng if the user is in usa_eng
                    if let selectedUrlContents = selectedUrlContents, let selectedUrlLocale = StormLanguageController.shared.languagePack(forLocaleIdentifier: selectedUrlContents.localeIdentifier)?.locale, selectedUrlLocale.regionCode == nil {
                        continue
                    }
                    
                    selectedUrlContents = urlContents
                }
            }
            
            return selectedUrlContents
        }
        

        let selectedLink = findLinkForLocale(using: urls)
        
        
        // Set the TSCLink's url property to the selected locales url, if that doesn't exist fall back to the first link or nil if that doens't exist
        if let selectedLink = selectedLink {
            self.url = selectedLink.destination
        } else {
            self.url = urls.first?.destination
        }
    }
    
    // Model represenentation of a localised link data, contains the src along with the locale it's specific to
    struct LocalisedLinkContents {
        
        // Class name, currently always LocalisedLinkDetail
        var className: String?
        
        // The source of the url i.e www.3sidedcube.com
        var destination: URL
        
        // The locale identifier with 3 letter language code and optional 3 letter region code, i.e usa_eng or eng
        var localeIdentifier: String
        
        init?(from dictionary: [AnyHashable: Any]) {
            
            self.className = dictionary["class"] as? String
            
            guard let srcString = dictionary["src"] as? String else {
                return nil
            }
            guard let src = URL(string: srcString) else {
                return nil
            }
            self.destination = src
            
            guard let localeString = dictionary["locale"] as? String else {
                return nil
            }
            
            self.localeIdentifier = localeString
        }
    }
}
