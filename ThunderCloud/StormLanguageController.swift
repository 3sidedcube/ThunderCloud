//
//  StormLanguageController.swift
//  ThunderCloud
//
//  Created by Matthew Cheetham on 02/06/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation
import UIKit
import ThunderTable

/// A controller that handles loading language files for Storm and provides methods to look up localisation strings.
/// To understand how this controller works you must first understand the difference between a Storm Locale and a `Locale`.
/// Storm Locales come in the format of "gbr_en" (Region, Language)
/// `Locale` comes in the format of "en_GB" (Language, Region)
/// `Locale` is able to ingest locales in the three letter format provided they are in the language_region format.
/// This controller often re-organises the Storm file names to be in the language_region format before converting to `Locale`, once these are converted to `Locale` they can easily be compared with `Locale`s from the users device to find a match.
@objc(TSCStormLanguageController)
public class StormLanguageController: NSObject {
    
    @objc(sharedController)
    public static let shared = StormLanguageController()
    
    /// The dictionary of keys and values used for looking up language values for localisations.
    var languageDictionary: [AnyHashable: Any]?
    
    /// The current language identifier
    @objc public var currentLanguage: String?
    
    /// The users langauge that they have forced as an overide. Usually different from the current device locale
    @available(*, deprecated, message: "Language is deprecated use overrideLanguagePack instead")
    public var overrideLanguage: Language?
    
    /// The users language they have chosen as an override to the default device locale, replaces overrideLanguage
    public var overrideLanguagePack: LanguagePack?
    
    /// Key used to save and retrieve an override language pack
    private let overrideLanguagePackSavingKey = "TSCLanguagePackOverrideFileName"
    
    /// The locales that the user prefers to view content in.
    private var preferredLocales: [Locale]? {
        
        //Generate our preferred Locales based on the users preferences
        var preferredLocales = Locale.preferredLanguages.flatMap({ (languageString: String) -> Locale in
            return Locale(identifier: languageString)
        })
        
        // If the user has applied an override language to the app we need to retrieve a saved version and apply it as the app language
        // Check the defaults for the override language filename
        if let overridePackFileName = UserDefaults.standard.object(forKey: overrideLanguagePackSavingKey) as? String {
            
            // If we have the saved override filename, filter our available language packs for it
            let savedOverridePack = availableLanguagePacks?.first(where: { (pack) -> Bool in
                return pack.fileName == overridePackFileName
            })
            
            // If we find the pack lets insert it into our preferredLocales, and set the overrideLanguage Pack to the saved version
            if let savedOverridePack = savedOverridePack {
                preferredLocales.insert(savedOverridePack.locale, at: 0)
                overrideLanguagePack = savedOverridePack
            }
        }
        
        return preferredLocales
    }
    
    // Private init as only the shred instance should be used
    private override init() {
        super.init()
        migrateToLanguagePackIfRequired()
    }
    
    /// The locales that are available in the language packs
    public var availableLanguagePacks: [LanguagePack]? {
        
        let availableLocaleFileNames = ContentController.shared.fileNames(inDirectory: "languages")
        
        if let availableLocaleFileNames = availableLocaleFileNames {
            
            return availableLocaleFileNames.flatMap({ (fileName: String) -> LanguagePack? in
                return languagePack(for: fileName)
            })
        }
        return nil
    }
    
    
    public func languagePack(for fileName: String) -> LanguagePack? {
        
        if let languageName = fileName.components(separatedBy: ".").first {
            return self.languagePack(forLocaleIdentifier: languageName)
        }
        
        return nil
    }
    
    
    public func languagePack(forLocaleIdentifier localeIdentifier: String) -> LanguagePack? {
        
        // Seperate region and langauge if there is a seperator
        let components = localeIdentifier.components(separatedBy: "_")
        
        // Get the first and last components from the array, if there is only 1 value these will be the same object
        if let languageString = components.last,
            let regionString = components.first {
            
            // if they aren't the same object we have a region AND a language
            if languageString != regionString {
                let fixedIdentifier = "\(preprocessed(language: languageString))_\(regionString)"
                return LanguagePack(locale: Locale(identifier: fixedIdentifier), fileName: localeIdentifier)
            } else {
                // Otherwise we only have a language
                return LanguagePack(locale: Locale(identifier: preprocessed(language: languageString)), fileName: localeIdentifier)
            }
        }
        
        return nil
    }
    
    //MARK: - Migration Methods for TSCLanguage
    func migrateToLanguagePackIfRequired() {
        
        //Add override locales if they exist
        if let overrideObject = UserDefaults.standard.object(forKey: "TSCLanguageOverride") as? Data, let overrideLanguage = NSKeyedUnarchiver.unarchiveObject(with: overrideObject) as? Language {
            
            // Migrate the languageOverride to languagePack
            if let pack = languagePack(for: overrideLanguage) {
                UserDefaults.standard.set(pack.fileName, forKey: overrideLanguagePackSavingKey)
                
                // Clean up saved deprecated TSCLanguage override
                // Set the previous value saved value to nil
                UserDefaults.standard.set(nil, forKey: "TSCLanguageOverride")
            }
        }
    }
    
    /// Converts a TSCLanguage object into the new LanguagePack Format
    ///
    /// - Parameter langauge: a TSCLanguage that needs to be converted
    /// - Returns: a new LanguagePack object that represents the same data as the TSCLangauge or nil
    func languagePack(for language: Language) -> LanguagePack? {
        
        // Check the language has a languageIdentifier
        guard let languageIdentifier = language.languageIdentifier else { return nil }
        
        // Add .json to identifier to get the filename
        let fileName =  languageIdentifier
        
        // Create a locale from the identifier
        let locale = Locale(identifier: languageIdentifier)
        
        // Create the pack using the 2 properties
        let pack = LanguagePack(locale: locale, fileName: fileName)
        return pack
    }
    
    /// Unfortunately some language codes do not get ingested well by iOS, as their three letter and two letter country codes conflict somewhere internally so iOS gets confused and just represents the locale as a string instead of a real locale. This method will switch the language code out for something more compatible with iOS
    ///
    /// - Parameter language: The language code to check for conflicts
    /// - Returns: The new, compatible language code
    private func preprocessed(language: String) -> String {
        
        if language == "spa" {
            return "es"
        }
        
        return language
    }
    
    /// Works out the major and regional language packs that are most suitable for the user based on their preferences
    ///
    /// - Returns: A tuple containing regional and major language packs. Regional is optional where major should always return one of the packs
    private func languagePacks() -> (regionalLanguagePack: LanguagePack?, majorLanguagePack: LanguagePack?)? {
        
        //Find out if any locales match
        guard let availableLanguagePacks = availableLanguagePacks, let preferredLocales = preferredLocales else {
            return nil
        }
        
        var regionalLanguagePack: LanguagePack?
        var majorLanguagePack: LanguagePack?
        
        //Find our language packs that match
        
        for preferredLocale in preferredLocales {
            
            for pack in availableLanguagePacks {
            
                // Matches both language and region
                if preferredLocale.languageCode == pack.locale.languageCode &&
                    pack.locale.regionCode != nil &&
                    preferredLocale.regionCode == pack.locale.regionCode {
                    
                    regionalLanguagePack = pack
                    
                    //Set the major language if it matches
                    if let languageCode = pack.fileName.components(separatedBy: "_").last {
                        let languageOnlyLocale = Locale(identifier: languageCode)
                        majorLanguagePack = LanguagePack(locale: languageOnlyLocale, fileName: languageCode)
                    }
                    
                    return (regionalLanguagePack: regionalLanguagePack, majorLanguagePack: majorLanguagePack)
                    
                    // Only matches language, and if majorLanguage has not already been set
                } else if preferredLocale.languageCode == pack.locale.languageCode,
                    majorLanguagePack == nil {
                    
                    //Set the major language if only the language matches. Major language pack always exists if a minor one exists
                    if let languageCode = pack.locale.languageCode, let languageName = pack.fileName.components(separatedBy: "_").first {
                        majorLanguagePack = LanguagePack(locale: Locale(identifier: languageCode), fileName: languageName)
                    }
                }
            }
        }
        
        return (regionalLanguagePack: regionalLanguagePack, majorLanguagePack: majorLanguagePack)
    }
    
    /// Reloads the language pack based on user preferences and assigns it to the language dictionary
    public func reloadLanguagePack() {
        
        //Load languages
        var finalLanguage = [AnyHashable: Any]()
        
        let packs = languagePacks()
        
        //Major
        let majorPack = packs?.majorLanguagePack
        
        if let majorFileName = majorPack?.fileName, let majorPackPath = ContentController.shared.fileUrl(forResource: majorFileName, withExtension: "json", inDirectory: "languages") {
            
            currentLanguage = majorFileName
            
            let majorLanguageDictionary = languageDictionary(for: majorPackPath)
            
            if let majorLanguageDictionary = majorLanguageDictionary {
                
                for (key, value) in majorLanguageDictionary {
                    finalLanguage[key] = value as Any
                }
            }
        }
        
        //Minor
        let minorPack = packs?.regionalLanguagePack
        if let minorFileName = minorPack?.fileName, let minorPackPath = ContentController.shared.fileUrl(forResource: minorFileName, withExtension: "json", inDirectory: "languages") {

            currentLanguage = minorFileName
            
            let minorLanguageDictionary = languageDictionary(for: minorPackPath)
            
            if let minorLanguageDictionary = minorLanguageDictionary as? [String: String] {
                
                for (key, value) in minorLanguageDictionary {
                    finalLanguage[key] = value as Any
                }
            }
        }
        
        //Fall back to default if we need it
        if finalLanguage.count == 0 {
            
            if let appFileURL = ContentController.shared.fileUrl(forResource: "app", withExtension: "json", inDirectory: nil) {
                
                let appJSON = try? JSONSerialization.jsonObject(with:appFileURL)
                
                if let _appJSON = appJSON as? [AnyHashable: Any], let packString = _appJSON["pack"] as? String, let packURL = URL(string: packString) {
                    
                    //Example of "PackString" `//languages/eng.json`
                    //We're trying to get the "eng" bit of it.
                    guard let fileName = packURL.lastPathComponent.components(separatedBy: ".").first, let fullFilePath = ContentController.shared.fileUrl(forResource: fileName, withExtension: "json", inDirectory: "languages") else {
                        return
                    }
                    
                    currentLanguage = fileName
                    self.languageDictionary = languageDictionary(for: fullFilePath)
                    return
                }
            }
        }
        
        //Final last ditch attempt at loading any language
        if finalLanguage.count == 0 {
            
            var allLanguages = availableStormLanguages()
			let preferredLanguages = Locale.preferredLanguages
			
			// Sort the available languages by their position in `Locale.preferredLanguages`
			allLanguages?.sort(by: { (language1, language2) -> Bool in
				
				guard let key1 = language1.languageIdentifier?.components(separatedBy: "_").last else {
					return false
				}
				guard let key2 = language2.languageIdentifier?.components(separatedBy: "_").last else {
					return true
				}
				
				let index1 = preferredLanguages.index(of: key1)
				let index2 = preferredLanguages.index(of: key2)
				
				// If language1 has a language key in preferredLanguages, but language2 doesn't it should come higher in sort order
				if index1 != nil && index2 == nil {
					return true
				// Otherwise if language2 has a language key in preferredLanguages but language1 doesn't then other way around!
				} else if index2 != nil && index1 == nil {
					return false
					// If neither aer in preferredLanguages, return the first one in the array
				}
                
                // If neither langauge is in preferredLanguages then leave the langauges as they are
                guard let _index1 = index1, let _index2 = index2 else {
                    return true
                }
				
				// Return their ordering in the preferredLanguages array!
				return _index1 < _index2
			})
            
            if let firstLanguage = allLanguages?.first, let languageIdentifier = firstLanguage.languageIdentifier {
                
                let filePath = ContentController.shared.fileUrl(forResource: languageIdentifier, withExtension: "json", inDirectory: "languages")
				
				currentLanguage = languageIdentifier
				
                if let _filePath = filePath {
                    languageDictionary = languageDictionary(for: _filePath)
                    return
                }
            }
        }
        
        self.languageDictionary = finalLanguage
    }
    
    /// Loads the contents of a language file at a specific url and sets it as the current language dictionary
    ///
    /// - Parameter filePath: The full url path of the .json language file to load
    func loadLanguageFile(fileURL: URL) {
        
        print("<ThunderStorm> [Languages] Loading language at path \(fileURL)")
        
        let languageContent = languageDictionary(for: fileURL)
        
        if let languageContent = languageContent {
            languageDictionary = languageContent
        } else {
            print("<ThunderStorm> [Languages] No data for language pack")
        }
    }
    
    /// Loads a language dictionary from a file path
    ///
    /// - Parameter filePath: The url of the file to load the language from
    /// - Returns: A dictionary with the key values of localisations if one was available from disc
    func languageDictionary(for fileURL: URL) -> [AnyHashable: Any]? {
        
        let languageFileDictionary = try? JSONSerialization.jsonObject(with: fileURL)
        
        if let languageFileDictionary = languageFileDictionary as? [AnyHashable: Any] {
            return languageFileDictionary
        }
        
        return nil
    }
    
    /// Returns a `Locale` for a storm language key
    ///
    /// - Parameter languageKey: The locale string as returned by the CMS
    /// - Returns: A `Locale` generated from the string
    @objc(localeForLanguageKey:)
    public func locale(for languageKey: String) -> Locale? {
        
        return languagePack(forLocaleIdentifier: languageKey)?.locale
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
    @objc public var currentLocale: Locale? {
        guard let language = currentLanguage else {
            return nil
        }
        return locale(for: language)
    }
    
    /// All available languages found in the current storm driven app
    ///
    /// - Returns: An array of TSCLanguage objects
    public func availableStormLanguages() -> [Language]? {
        
        let languageFiles = ContentController.shared.fileNames(inDirectory: "languages")
        
        return languageFiles?.flatMap({ (fileName: String) -> Language? in
			
			let lang = Language()
            lang.localisedLanguageName = localisedLanguageName(for: fileName)
            let components = fileName.components(separatedBy: ".")
            lang.languageIdentifier = components.first
            return lang
        })
    }
    
    /// Confirms that the user wishes to switch the language to the current string set at as overrideLanguage
    public func confirmLanguageSwitch() {
        
        let defaults = UserDefaults.standard
        
        if let overrideLanguagePack = overrideLanguagePack {
            defaults.set(overrideLanguagePack.fileName, forKey: overrideLanguagePackSavingKey)
			
			NotificationCenter.default.sendStatEventNotification(category: "Language Switching", action: "Switch to \(overrideLanguagePack.fileName)", label: nil, value: nil, object: nil)
        }
        
        reloadLanguagePack()
		
		BadgeController.shared.reloadBadgeData()
        
        // Re-index because we've changed language so we want core spotlight in correct language
        ContentController.shared.indexAppContent { (error: Error?) -> (Void) in
            
            // If we get an error mark the app as not indexed
            if let _ = error {
                defaults.set(false, forKey: "TSCIndexedInitialBundle")
            }
        }
        
        NotificationCenter.default.post(name: .languageSwitchedNotification, object: self, userInfo: nil)
        
        
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
    @objc public var isRightToLeft: Bool {
        
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
    public func string(forKey key: String) -> String? {
		return string(forKey: key, withFallback: key)
    }
    
    /// The localised string for the required key, with a fallback string if a localisation cannot be found in the key-value pair dictionary of localised strings
    ///
    /// - Parameters:
    ///   - key: The key for which a localised string should be returned.
    ///   - fallbackString: The fallback string to be used if the string doesn't exist in the key-value pair dictionary.
    /// - Returns: A string of either the localisation or the fallback string
    @objc(stringForKey:withFallbackString:)
    public func string(forKey key: String, withFallback fallbackString: String?) -> String? {
        guard let languageDictionary = languageDictionary, let string = languageDictionary[key] else {
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
        
        return string(forKey: contentKey, withFallback: nil)
    }
    
    /// A string representing the currently set language short key.
    public var currentLanguageShortKey: String? {
        return currentLocale?.languageCode
    }
}

/// A struct to contain a locale object and the assosicated file name of the storm language file
public struct LanguagePack {
    
    /// The locale object representing the language pack
    public let locale: Locale
    
    /// The raw file name of the language (without .json extension)
    public let fileName: String
}

extension LanguagePack: Row {
	
	public var title: String? {
		get {
			return StormLanguageController.shared.localisedLanguageName(for: locale)
		}
		set {}
	}
	
	public var accessoryType: UITableViewCellAccessoryType? {
		get {
			
			guard let currentLanguage = StormLanguageController.shared.currentLanguage else { return UITableViewCellAccessoryType.none
			}
			
			if let overrideLanguageId = StormLanguageController.shared.overrideLanguagePack?.fileName, overrideLanguageId == fileName {
				return .checkmark
			} else if StormLanguageController.shared.overrideLanguagePack == nil && fileName == currentLanguage {
				return .checkmark
			}
			
			return UITableViewCellAccessoryType.none
		}
		set {}
	}
}

public extension NSNotification.Name {
    public static let languageSwitchedNotification = Notification.Name("TSCLanguageSwitchedNotification")
}
