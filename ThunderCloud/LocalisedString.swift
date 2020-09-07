//
//  LocalisedString.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 24/01/2016.
//  Copyright © 2016 threesidedcube. All rights reserved.
//

import Foundation
import ObjectiveC
import ThunderBasics

private var localisationKeyAssociationKey: UInt8 = 0

public extension String {
    
    /**
    Returns the key for the string
    - discussion This can be nil-checked to see if a string is localised or not
    */
    var localisationKey: String? {
        get {
            return objc_getAssociatedObject(self, &localisationKeyAssociationKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &localisationKeyAssociationKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    /// Localises the given string using the localisation key provided
    ///
    /// - Parameter key: The localisation key to localise using
    /// - Returns: If a localisation with the given key was found returns the localised string, if not returns a copy of self
    func localised(with key: String) -> String {
        return localised(with: key, paramDictionary: nil)
    }
    
    /// Localises the given string using the localisation key provided and replacing any variables in the localised string with the parameters from paramDictionary
    ///
    /// - Parameters:
    ///   - key: The localisation key to localise using
    ///   - paramDictionary: A dictionary of parameters to use to replace string variables
    /// - Returns: If a localisation with the given key was found returns the localised string, if not returns a copy of self
    func localised(with key: String, paramDictionary: [String: Any]?) -> String {
        var string = NSAttributedString(string: self).localised(with: key, paramDictionary: paramDictionary).string
        string.localisationKey = key
        if LocalisationsTool.showDebugLocalisations && !string.hasSuffix("[\(key)]") {
            return "[\(key)] \(string)"
        }
        return string
    }
    
    fileprivate func performingMethod(_ method: String) -> String {
        
        let currentLocale = StormLanguageController.shared.currentLocale
        
        switch method.lowercased() {
        case "uppercase", "uppercased":
            return uppercased(with: currentLocale)
        case "lowercase", "lowercased":
            return lowercased(with: currentLocale)
        case "capitalise", "capitalised", "capitalize", "capitalized":
            return capitalized(with: currentLocale)
        case "propercase", "propercased":
            
            // Lowercase to get rid of random uppercase letters
            var returnString = lowercased(with: currentLocale)
            
            // Upper case otherwise full stop isn't picked up as the end of a sentence
            let testString = returnString.uppercased(with: currentLocale)
            
            testString.enumerateSubstrings(in: returnString.startIndex..., options: [.bySentences]) { (substring, substringRange, enclosingRange, _) in
                
                guard let substring = substring else { return }
                
                let returnFirstIndexRange = substringRange.lowerBound..<returnString.index(after: substringRange.lowerBound)
                let substringFirstIndexRange = substring.startIndex..<substring.index(after: substring.startIndex)
                returnString = returnString.replacingCharacters(in: returnFirstIndexRange, with: substring[substringFirstIndexRange])
            }
            
            return returnString
            
        default:
            return self
        }
    }
}


public extension NSAttributedString {
    
    /// Localises the given attributed string using the localisation key provided and replacing any variables in the localised string with the parameters from paramDictionary
    ///
    /// - Parameters:
    ///   - key: The localisation key to localise using
    ///   - paramDictionary: A dictionary of parameters to use to replace string variables
    /// - Returns: If a localisation with the given key was found returns the localised string, if not returns a copy of self
    func localised(with key: String, paramDictionary: [String: Any]?) -> NSAttributedString {
        
        guard let currentLanguage = StormLanguageController.shared.currentLanguage?.split(separator: "_").last else {
            return self
        }
        
        var localisedString: String?
        
        if let localisationDictionary = LocalisationController.shared.localisationDictionary(forKey: key) {
            localisedString = localisationDictionary[String(currentLanguage)] as? String
        } else if let languageString = StormLanguageController.shared.string(forKey: key, withFallback: string) {
            localisedString = languageString
        }
        
        var finalString = localisedString != nil ? NSAttributedString(string: localisedString!) : self
        
        finalString = finalString.replacingPlaceholdersWith(paramDictionary)
        finalString.localisationKey = key
        
        if LocalisationsTool.showDebugLocalisations {
            let mutableFinalString = NSMutableAttributedString(attributedString: finalString)
            mutableFinalString.insert(NSAttributedString(string: "[\(key)] "), at: 0)
            return mutableFinalString
        }
        
        return finalString
    }
    
    fileprivate func replacingPlaceholdersWith(_ parameters: [String : Any]?) -> NSAttributedString {
        
        guard let parameters = parameters else { return self }
        
        guard let variableExpression = try? NSRegularExpression(pattern: "\\{(.*?)\\}", options: []) else {
            return self
        }
        
        let finalString = NSMutableAttributedString(attributedString: self)
        
        // Pulls out parameters surrounded by {}
        variableExpression.enumerateMatches(in: string, options: .reportCompletion, range: NSRange(string.startIndex..., in: string)) { (result, _, _) in
            
            guard let result = result, let fullRange = Range(result.range, in: string), let captureRange = Range(result.range(at: 1), in: string) else { return }
            
            let fullMatch = string[fullRange]
            let capturedText = string[captureRange]
            
            // This can't be done via a simple components(separatedBy: ".") because method parameters can be decimal!.
            let variableKey = capturedText.components(separatedBy: ".")[0]
            
            var methods: [String] = []
            
            if let methodRegex = try? NSRegularExpression(pattern: "\\.([a-zA-Z]*\\([^\\)]*\\))", options: []) {
                let matches = methodRegex.matches(in: String(capturedText), options: [], range: NSRange(capturedText.startIndex..., in: capturedText))
                methods = matches.compactMap({ match -> String? in
                    guard let range = Range(match.range(at: 1), in: String(capturedText)) else { return nil }
                    let matchString = String(capturedText)[range]
                    return String(matchString)
                })
            }
            
            guard var parameter: Any = parameters[variableKey] else {
                return
            }
            
            // If the parameter has methods attached to it, then we need to perform these methods on the string before replacing it
            guard !methods.isEmpty else {
                
                let replacement = "\(parameter)"
                
                // Have to find the range again because we're mutating the string as we go
                guard let range = finalString.string.range(of: fullMatch) else {
                    return
                }
                finalString.replaceCharacters(in: NSRange(range, in: finalString.string), with: replacement)
                
                return
            }
            
            // Perform any methods found on the variable to customise the string
            methods.forEach({ (method) in
                parameter = NSAttributedString.performingMethod(method, on: parameter) ?? parameter
            })
                
            guard let finalParameter = parameter as? NSAttributedString else {
                return
            }
            
            guard let range = finalString.string.range(of: fullMatch) else {
                return
            }
            
            finalString.replaceCharacters(in: NSRange(range, in: finalString.string), with: finalParameter)
        }
        
        return finalString
    }
    
    fileprivate static func performingMethod(_ method: String, on parameter: Any) -> NSAttributedString? {
        
        let methodComponents = method.components(separatedBy: "(")
        
        guard methodComponents.count > 1 else {
            return nil
        }
        
        // Gets the name of the method
        let methodName = methodComponents[0]
        
        // Gets the remainder of the method so we can strip parameters
        guard let nameRange = method.range(of: methodName) else { return nil }
        let methodRemainder = String(method[nameRange.upperBound...])
        
        var parameters: [String] = []
        
        // Regex for pulling the parameters out of the method string
        guard let parametersExpression = try? NSRegularExpression(pattern: "\"(.*?)\\\"", options: []) else {
            return nil
        }
        
        parametersExpression.enumerateMatches(in: methodRemainder, options: [], range: NSRange(methodRemainder.startIndex..., in: methodRemainder)) { (result, _, _) in
            guard let nsRange = result?.range(at: 1) else { return }
            guard let range = Range(nsRange, in: methodRemainder) else { return }
            parameters.append(String(methodRemainder[range]))
        }
        
        switch (methodName, parameter) {
        case ("date", let date as Date):
            guard let format = parameters.first, let dateString = DateFormatter.string(from: date, strfttimeFormat: format) else {
                return nil
            }
            return NSAttributedString(string: dateString)
        case ("array", let array as [Any]):
            
            let separator = parameters.first ?? ", "
            let lastSeparator = parameters.count > 1 ? parameters[1] : nil
            var methodizedString = ""
            
            array.enumerated().forEach { (enumeration) in
                
                switch enumeration.offset {
                case array.count - 1:
                    methodizedString.append("\(enumeration.element)")
                case array.count - 2:
                    methodizedString.append("\(enumeration.element)\(lastSeparator ?? separator)")
                default:
                    methodizedString.append("\(enumeration.element)\(separator)")
                }
            }
            
            return NSAttributedString(string: methodizedString)
            
        default:
            
            // All string based methods
            var attributes: [NSAttributedString.Key : Any] = [:]
            var methodizedString: String
            
            switch parameter {
            case let attributedString as NSAttributedString:
                attributes = attributedString.attributes(at: 0, effectiveRange: nil)
                methodizedString = attributedString.string
            case let string as String:
                methodizedString = string
            default:
                methodizedString = "\(parameter)"
            }
            
            methodizedString = methodizedString.performingMethod(methodName)
            
            attributes += NSAttributedString.attributeDictionaryWith(method: methodName, parameters: parameters)
            
            return NSAttributedString(string: methodizedString, attributes: attributes)
        }
    }
    
    fileprivate static func attributeDictionaryWith(method: String, parameters: [String]) -> [NSAttributedString.Key : Any] {
        
        var attributes: [NSAttributedString.Key : Any] = [:]
        
        switch method.lowercased() {
        case "textcolor", "textcolour", "foregroundcolor", "foregroundcolour":
            
            guard let colorString = parameters.first, let color = UIColor(hexString: colorString) else {
                return attributes
            }
            
            attributes[.foregroundColor] = color
            
        case "backgroundcolor", "backgroundcolour":
            
            guard let colorString = parameters.first, let color = UIColor(hexString: colorString) else {
                return attributes
            }
            
            attributes[.backgroundColor] = color
            
        case "underline", "underlined":
            
            parameters.forEach { (parameter) in
                if let color = UIColor(hexString: parameter) {
                    attributes[.underlineColor] = color
                } else if let intValue = Int(parameter) {
                    attributes[.underlineStyle] = NSUnderlineStyle(rawValue: intValue)
                }
            }
            
        case "strike", "strikethrough", "strikedthrough":
            
            attributes[.strikethroughStyle] = NSUnderlineStyle.single
            
            parameters.forEach { (parameter) in
                if let color = UIColor(hexString: parameter) {
                    attributes[.strikethroughColor] = color
                } else if let intValue = Int(parameter) {
                    attributes[.strikethroughStyle] = NSUnderlineStyle(rawValue: intValue)
                }
            }
            
        case "stroke", "stroked":
            
            attributes[.strokeWidth] = 1.0
            
            parameters.forEach { (parameter) in
                if let color = UIColor(hexString: parameter) {
                    attributes[.strokeColor] = color
                } else if let doubleValue = Double(parameter) {
                    attributes[.strokeWidth] = doubleValue
                }
            }
            
        case "skew", "skewed", "obliqueness":
            
            guard let firstParam = parameters.first, let obliqueness = Double(firstParam) else {
                return attributes
            }
            
            attributes[.obliqueness] = obliqueness
            
        case "link":
            
            guard let firstParam = parameters.first, let url = URL(string: firstParam) else {
                return attributes
            }
            
            attributes[.link] = url
            
        default:
            break
        }
        
        return attributes
    }
}

extension Dictionary {
    public static func +=(lhs: inout [Key: Value], rhs: [Key: Value]) {
        rhs.forEach({ lhs[$0] = $1})
    }
}

public extension NSAttributedString {
    /// Returns the localisation key used to create the NSAttributedString
    var localisationKey: String? {
        get {
            return objc_getAssociatedObject(self, &localisationKeyAssociationKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &localisationKeyAssociationKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}
