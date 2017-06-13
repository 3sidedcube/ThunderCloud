//
//  StormLanguageController.swift
//  ThunderCloud
//
//  Created by Matthew Cheetham on 02/06/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation
import UIKit

@objc(TSCStormLanguageController)
/// A subclass of ThunderBasic's `TSCLanguageController` which adds extra properties and methods to the controller more useful to Storm's needs
public class StormLanguageController: NSObject {
    
    @objc(sharedController)
    public static let shared = StormLanguageController()
    
    var languageDictionary: [AnyHashable: Any]?
    
    /// The locales that the user prefers to view content in.
    private var preferredLocales: [Locale]? {
        
        //Generate our preferred Locales based on the users preferences
        var _preferredLocales = Locale.preferredLanguages.flatMap({ (languageString: String) -> Locale in
            return Locale(identifier: languageString)
        })
        
        //Add override locales if they exist
        if let overrideObject = UserDefaults.standard.object(forKey: "TSCLanguageOverride") as? Data, let _overrideLanguage = NSKeyedUnarchiver.unarchiveObject(with: overrideObject) as? TSCLanguage, let localeIdentifier = _overrideLanguage.languageIdentifier {
            _preferredLocales.insert(Locale(identifier: localeIdentifier), at: 0)
            overrideLanguage = _overrideLanguage
        }
        
        return _preferredLocales
    }
    
    /// The locales that are available in the language packs
    private var availableLocales: [LanguagePack]? {
        
        let availableLocaleFileNames = ContentController.shared.files(inDirectory: "languages")
        
        if let _availableLocaleFileNames = availableLocaleFileNames {
            
            return _availableLocaleFileNames.flatMap({ (localeIdentifier: String) -> LanguagePack? in
                
                if let languageName = localeIdentifier.components(separatedBy: ".").first {
                    
                    let components = languageName.components(separatedBy: "_")
                    if let _languageString = components.last, let _regionString = components.first {
                        
                        if _languageString != _regionString {
                            let fixedIdentifier = "\(_languageString)_\(_regionString)"
                            return LanguagePack(locale: Locale(identifier: fixedIdentifier), fileName: languageName)
                        } else {
                            return LanguagePack(locale: Locale(identifier: _languageString), fileName: languageName)
                        }
                    }
                }
                
                return nil
            })
        }
        return nil
    }
    
    /// Works out the major and regional language packs that are most suitable for the user based on their preferences
    ///
    /// - Returns: A tuple containing regional and major language packs. Regional is optional where major should always return one of the packs
    private func languagePacks() -> (regionalLanguagePack: LanguagePack?, majorLanguagePack: LanguagePack?)? {
        
        //Find out if any locales match
        guard let _availableLocales = availableLocales, let _preferredLocales = preferredLocales else {
            return nil
        }
        
        var regionalLanguagePack: LanguagePack?
        var majorLanguagePack: LanguagePack?
        
        //Find our language packs that match
        for pack in _availableLocales {
            
            for preferredLocale in _preferredLocales {
                
                if preferredLocale.languageCode == pack.locale.languageCode && preferredLocale.regionCode == pack.locale.regionCode {
                    regionalLanguagePack = pack
                    
                    //Set the major language if it matches
                    if let _languageCode = pack.fileName.components(separatedBy: "_").last {
                        let languageOnlyLocale = Locale(identifier: _languageCode)
                        majorLanguagePack = LanguagePack(locale: languageOnlyLocale, fileName: _languageCode)
                    }
                    
                    return (regionalLanguagePack: regionalLanguagePack, majorLanguagePack: majorLanguagePack)
                } else if preferredLocale.languageCode == pack.locale.languageCode {
                    
                    //Set the major language if only the language matches. Major language pack always exists if a minor one exists
                    if let _languageCode = pack.locale.languageCode, let languageName = pack.fileName.components(separatedBy: "_").first {
                        majorLanguagePack = LanguagePack(locale: Locale(identifier: _languageCode), fileName: languageName)
                    }
                }
            }
        }
        
        //Add fallpack to "pack" in app.json
        
        return (regionalLanguagePack: regionalLanguagePack, majorLanguagePack: majorLanguagePack)
    }
    
    /// Reloads the language pack based on user preferences and assigns it to the language dictionary
    public func reloadLanguagePack() {
        
        //Check for overrides
        
        //Load languages
        var finalLanguage = [AnyHashable: Any]()
        
        let packs = languagePacks()
        
        //Major
        let majorPack = packs?.majorLanguagePack
        if let _majorFileName = majorPack?.fileName, let majorPackPath = ContentController.shared.fileUrl(forResource: _majorFileName, withExtension: "json", inDirectory: "languages") {
            
            let majorLanguageDictionary = languageDictionary(for: majorPackPath.path)
            
            if let _majorLanguageDictionary = majorLanguageDictionary {
                
                for (key, value) in _majorLanguageDictionary {
                    finalLanguage[key] = value as AnyObject
                }
            }
        }
        
        //Minor
        let minorPack = packs?.regionalLanguagePack
        if let _minorFileName = minorPack?.fileName, let minorPackPath = ContentController.shared.fileUrl(forResource: _minorFileName, withExtension: "json", inDirectory: "languages") {
            
            let minorLanguageDictionary = languageDictionary(for: minorPackPath.path)
            
            if let _minorLanguageDictionary = minorLanguageDictionary as? [String: String] {
                
                for (key, value) in _minorLanguageDictionary {
                    finalLanguage[key] = value as AnyObject
                }
            }
        }
        
        //Fall back to default if we need it
        if finalLanguage.count == 0 {
            
            if let appFileURL = ContentController.shared.fileUrl(forResource: "app", withExtension: "json", inDirectory: nil) {
            
                let appJSON = try? JSONSerialization.jsonObject(withFile:appFileURL.path, options: [])
            
                if let _appJSON = appJSON as? [String: AnyObject], let packString = _appJSON["pack"] as? String, let packURL = URL(string: packString) {
                    
                    guard let fileName = packURL.lastPathComponent.components(separatedBy: ".").first, let fullFilePath = ContentController.shared.fileUrl(forResource: fileName, withExtension: "json", inDirectory: "languages") else {
                        return
                    }
                    
                    self.languageDictionary = languageDictionary(for: fullFilePath.path)
                    return
                }
            }
        }
        
        self.languageDictionary = finalLanguage
    }
    
    /// Loads the contents of a language file at a specific path and sets it as the current language dictionary
    ///
    /// - Parameter filePath: The full file path of the .json language file to load
    func loadLanguageFile(filePath: String) {
        
        print("<ThunderStorm> [Languages] Loading language at path \(filePath)")
        
        let languageContent = languageDictionary(for: filePath)
        
        if let _languageContent = languageContent {
            languageDictionary = _languageContent
        } else {
            print("<ThunderStorm> [Languages] No data for language pack")
        }
    }
    
    /// Loads a language dictionary from a file path
    ///
    /// - Parameter filePath: The path of the file to load the language from
    /// - Returns: A dictionary with the key values of localisations if one was available from disc
    func languageDictionary(for filePath: String) -> [String: AnyObject]? {
        
        let languageFileDictionary = try? JSONSerialization.jsonObject(withFile:filePath, options: [])
        
        if let _languageFileDictionary = languageFileDictionary as? [String: AnyObject] {
            return _languageFileDictionary
        }
        
        return nil
    }
    
    /// Returns a `Locale` for a storm language key
    ///
    /// - Parameter languageKey: The locale string as returned by the CMS
    /// - Returns: A `Locale` generated from the string
    @objc(localeForLanguageKey:)
    public func locale(for languageKey: String) -> Locale? {
        
        let localeComponents = languageKey.components(separatedBy: "_")
        
        if localeComponents.count == 1 {
            return Locale(identifier: languageKey)
        } else if localeComponents.count == 2 {
            
            if let _language = localeComponents.last, let _region = localeComponents.first {
                return Locale(identifier: "\(_language)_\(_region)")
            }
        }
        
        return nil
    }
    
    /// Returns a localised name for a language for a certain locale
    ///
    /// - Parameter locale: The locale to return the localised name for
    /// - Returns: Returns the name of the locale, loclaised to the locale
    @objc(localisedLanguageNameForLocale:)
    public func localisedLanguageName(for locale: Locale) -> String? {
        
        return locale.localizedString(forIdentifier: locale.identifier)
    }
    
    /// Returns a localised name for a language for a certain locale identifier (i.e. en_US)
    ///
    /// - Parameter localeIdentifier: The locale id to return the localised name for
    /// - Returns: A string of the language name, in that language
    @objc(localisedLanguageNameForLocaleIdentifier:)
    public func localisedLanguageName(for localeIdentifier: String) -> String? {
        let locale = Locale(identifier: localeIdentifier)
        return locale.localizedString(forIdentifier: locale.identifier)
    }
    
    /// The locale for the users currently selected language
    public var currentLocale: Locale? {
        guard let _language = currentLanguage else {
            return nil
        }
        return locale(for: _language)
    }
    
    /// The current language identifier
    public var currentLanguage: String?
    
    /// The users language that they have forced as an overide. Usually different from the current device locale
    public var overrideLanguage: TSCLanguage?
    
    /// All available languages found in the current storm driven app
    ///
    /// - Returns: An array of TSCLanguage objects
    public func availableStormLanguages() -> [TSCLanguage]? {
        
        let languageFiles = ContentController.shared.files(inDirectory: "languages")
        
        return languageFiles?.flatMap({ (fileName: String) -> TSCLanguage? in
            
            let lang = TSCLanguage()
            lang.localisedLanguageName = localisedLanguageName(for: fileName)
            let components = fileName.components(separatedBy: ".")
            lang.languageIdentifier = components.first
            return lang
        })        
    }
    
    /// Confirms that the user wishes to switch the language to the current string set at as overrideLanguage
    public func confirmLanguageSwitch() {
        
        let defaults = UserDefaults.standard
        
        if let _overrideLanguage = overrideLanguage {
            defaults.set(NSKeyedArchiver.archivedData(withRootObject: _overrideLanguage), forKey: "TSCLanguageOverride")
            
            NotificationCenter.default.post(name: NSNotification.Name("TSCStatEventNotification"), object: self, userInfo: ["type":"event", "category":"Language Switching", "action": "Switch to \(_overrideLanguage)"])

        }
        
        reloadLanguagePack()
        
        TSCBadgeController.shared().reloadBadgeData()
        
        // Re-index because we've changed language so we want core spotlight in correct language
        ContentController.shared.indexAppContent { (error: Error?) -> (Void) in
            
            // If we get an error mark the app as not indexed
            if let _ = error {
                defaults.set(false, forKey: "TSCIndexedInitialBundle")
            }
        }

        let appView = AppViewController()
        let window = UIApplication.shared.keyWindow
        window?.rootViewController = appView
    }
    
//MARK - Right to left support

    /// Returns the correct text alignment for the user's current language setting for a given base text direction.
    ///
    /// - Parameter baseDirection: the base text direction to correct for the users current language setting
    /// - Returns: The correct direction for the given language
    public func localisedTextDirection(for baseDirection: NSTextAlignment) -> NSTextAlignment? {
        
        guard let languageCode = self.currentLocale?.languageCode else {
            return baseDirection
        }
        
        let languageDirection = Locale.characterDirection(forLanguage: languageCode)
        
        if baseDirection == .left {
            
            if languageDirection == .leftToRight {
                return .left
            } else if languageDirection == .rightToLeft {
                return .right
            }
            
        } else if baseDirection == .right {
            
            if languageDirection == .leftToRight {
                return .right
            } else if languageDirection == .rightToLeft {
                return .left
            }
        }
        
        return baseDirection
        
    }
    
    /// Returns whether the users current language is a right to left language
    public var isRightToLeft: Bool {
        
        guard let languageCode = self.currentLocale?.languageCode else {
            return false
        }
        
        let languageDirection = Locale.characterDirection(forLanguage: languageCode)

        if languageDirection == .rightToLeft {
            return true
        }
        
        return false
    }
    
    //MARK: - Loop methods
    
    /// The localised string for the required key.
    ///
    /// - Parameter key: The key for which a localised string should be returned.
    /// - Returns: Returns the localised string for the required key.
    @objc(stringForKey:)
    public func string(for key: String) -> String? {
        return string(for: key, with: key)
    }
    
    /// The localised string for the required key, with a fallback string if a localisation cannot be found in the key-value pair dictionary of localised strings
    ///
    /// - Parameters:
    ///   - key: The key for which a localised string should be returned.
    ///   - fallbackString: The fallback string to be used if the string doesn't exist in the key-value pair dictionary.
    /// - Returns: A string of either the localisation or the fallback string
    @objc(stringForKey:withFallbackString:)
    public func string(for key: String, with fallbackString: String?) -> String? {
        guard let _languageDictionary = languageDictionary, let string = _languageDictionary[key] else {
            return fallbackString
        }
        
        return string as? String
    }
    
    /// Returns the correct localised string for a Storm text dictionary.
    ///
    /// - Parameter dictionary: The Storm text dictionary to pull a string out of.
    /// - Returns: A localised string if found, if not you will get nil
    @objc(stringForDictionary:)
    public func string(for dictionary: [AnyHashable: Any]) -> String? {
        
        guard let contentKey = dictionary["content"] as? String else {
            return nil
        }
        
        return string(for: contentKey, with: nil)
    }
    
    /// A string representing the currently set language short key.
    public var currentLanguageShortKey: String? {
        return currentLocale?.languageCode
    }
}

/// A struct to contain a locale object and the assosicated file name of the storm language file
struct LanguagePack {
    
    /// The locale object representing the language pack
    let locale: Locale
    
    /// The raw file name of the language (without .json extension)
    let fileName: String
}
