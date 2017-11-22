//
//  main.swift
//  LocalisationParser
//
//  Created by Simon Mitchell on 13/04/2016.
//  Copyright © 2016 Three Sided Cube. All rights reserved.
//
//  Apologies for all the Regex guys :)

import Foundation
import Darwin
import Cocoa

enum PrintStyle: String {
    
    case Bold = "\u{001B}[0;1m"
    case Dim = "\u{001B}[0;2m"
    case Underlined = "\u{001B}[0;4m"
    case Blink = "\u{001B}[0;5m"
    case Reverse = "\u{001B}[0;7m"
    case Hidden = "\u{001B}[0;8m"
    
}

enum PrintColor: String {
    
    case Black = "\u{001B}[0;30m"
    case Red = "\u{001B}[0;31m"
    case Green = "\u{001B}[0;32m"
    case Yellow = "\u{001B}[0;33m"
    case Blue = "\u{001B}[0;34m"
    case Magenta = "\u{001B}[0;35m"
    case Cyan = "\u{001B}[0;36m"
    case White = "\u{001B}[0;37m"
    case Default = "\u{001B}[39m"
    
    static func all() -> [PrintColor] {
        return [.Black, .Red, .Green, .Yellow, .Blue, .Magenta, .Cyan, .White]
    }
}

func + (left: PrintColor, right: String) -> String {
    return left.rawValue + right + " \u{001B}[39m" // Prints in the colour, and then resets to default colour!
}

func password(_ prompt: String = "Please enter your password:") -> String? {
	return String(validatingUTF8: UnsafePointer<CChar>(getpass("Please enter your password: ")))
}

extension String {
	func countInstances(of stringToFind: String) -> Int {
		assert(!stringToFind.isEmpty)
		var searchRange: Range<String.Index>?
		var count = 0
		while let foundRange = range(of: stringToFind, options: .diacriticInsensitive, range: searchRange) {
			searchRange = Range(uncheckedBounds: (lower: foundRange.upperBound, upper: endIndex))
			count += 1
		}
		return count
	}
}

extension String {
	
    func matches(_ regex: String, index: Int, options: NSRegularExpression.Options) -> [(match:String, range:NSRange)] {
        
        do {
            
            let regex = try NSRegularExpression(pattern: regex,
                                                options: options)
            
            let nsString = self as NSString
            let results = regex.matches(in: self, options: .reportProgress, range: NSMakeRange(0, nsString.length))
            
            return results.map({
                
                let result = $0
                if result.numberOfRanges > index {
                    
                    let range = result.range(at: index)
                    
                    if range.length + range.location <= nsString.length {
                        return (nsString.substring(with: range), range)
                    } else {
                        return ("",range)
                    }
                    
                } else {
                    return ("", NSMakeRange(NSNotFound, 0))
                }
            })
            
        } catch _ {
            return []
        }
        
    }
    
    func matches(_ regex: String, options: NSRegularExpression.Options) -> [[(match:String, range:NSRange)]] {
        
        do {
            
            let regex = try NSRegularExpression(pattern: regex,
                                                options: options)
            
            let nsString = self as NSString
            let results = regex.matches(in: self, options: .reportProgress, range: NSMakeRange(0, nsString.length))
            
            return results.map({
                
                let result = $0
                var captures: [(match:String, range:NSRange)] = []
                
                for index in 0..<result.numberOfRanges {
                    
                    let range = result.range(at: index)
                    captures.append((nsString.substring(with: range), range))
                }
                
                return captures
            })
            
        } catch _ {
            return []
        }
    }
    
    
    func boolValue() -> Bool? {
        
        if ["Y","y","YES","Yes","yes"].contains(self) {
            return true
        }
        
        if ["N","n","NO","No","no"].contains(self) {
            return false
        }
        
        return nil
    }
}

extension FileManager {
    
    func recursivePathsForResource(_ type: String?, directory: String) -> [String] {
        
        var filePaths: [String] = []
        let enumerator = FileManager.default.enumerator(atPath: directory)
        
        while let element = enumerator?.nextObject() as? NSString {
            
            if type == nil || element.pathExtension == type {
                filePaths.append(directory + "/" + (element as String))
            }
        }
        
        return filePaths
    }
}

struct Localisation {
    
    var key: String! = ""
    var value: String?
    
    mutating func clean() {
        
        key = key.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        key = key.replacingOccurrences(of: ").capitalizedString", with: "")
        key = key.replacingOccurrences(of: ").lowercaseString", with: "")
        key = key.replacingOccurrences(of: ").uppercaseString", with: "")
        key = key.replacingOccurrences(of: ".capitalizedString", with: "")
        key = key.replacingOccurrences(of: ".lowercaseString", with: "")
        key = key.replacingOccurrences(of: ".uppercaseString", with: "")
        
        value = value?.replacingOccurrences(of: ").capitalizedString", with: "")
        value = value?.replacingOccurrences(of: ").lowercaseString", with: "")
        value = value?.replacingOccurrences(of: ").uppercaseString", with: "")
        value = value?.replacingOccurrences(of: ".capitalizedString", with: "")
        value = value?.replacingOccurrences(of: ".lowercaseString", with: "")
        value = value?.replacingOccurrences(of: ".uppercaseString", with: "")
    }
}


var localisations: [Localisation] = []
var localisationsCount = 0

enum LocalisationRegexOrder {
    case fallbackKey  // Fallback comes before key in result "Hey".stringWithLocalisationKey("_SOME_KEY")
    case keyFallback  // Key comes before fallback in result NSString(localisationKey:"_KEY", fallbackString:"Hey 2")
}

struct SwiftRegex {
    
    var pattern = ""
    var order = LocalisationRegexOrder.keyFallback
    
    init(pattern aPattern: String, order anOrder: LocalisationRegexOrder?) {
        
        pattern = aPattern
        if let newOrder = anOrder {
            order = newOrder
        }
    }
}

func addSwiftLocalisations(_ path: String) {
    
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)), var string = String(data: data, encoding: String.Encoding.utf8) else { return }
    
	print("Parsing \(path.components(separatedBy: "/").last ?? path) for Localised Strings")
	let matchCount = string.countInstances(of: "localisationKey:") + string.countInstances(of: "localised(with:")
	localisationsCount += matchCount
	
	var newLocalisations: [Localisation] = []
	
	let basePattern = ".localised\\(with:\\s*\\\"([^\n\t\"]*)\\\"\\s*"
	
    // Order is imporant here
    let swiftRegexes = [
		SwiftRegex(pattern: ".localisationKey\\s*=\\s*([^\n]*)", order: nil), // localisationKey localisations
        SwiftRegex(pattern: "NSString\\(localisationKey:\\s*(.*)\\s*,.*fallbackString:\\s*(.*).*\\)", order: nil), // NSString method with fallback ✅
        SwiftRegex(pattern: "NSString\\(localisationKey:\\s*(.*)\\s*\\)", order: nil), // NSString method without fallback ✅
        SwiftRegex(pattern: "\"([^\n\t\"]*)\"\\.localised\\(with:\\s*\\\"(.*)\\\"\\s*\\,\\s*paramDictionary", order: .fallbackKey), // Swift literal strings with params ✅
		SwiftRegex(pattern: "\"([^\n\t\"]*)\"\\"+basePattern+"\\)", order: .fallbackKey), // Swift literal strings without params ✅
		SwiftRegex(pattern: "(\\S*)\\"+basePattern+"\\,\\s*paramDictionary", order: .fallbackKey), // Swift variable strings with params ✅
		SwiftRegex(pattern: "(\\S*)\\"+basePattern+"\\)", order: .fallbackKey), // Swift variable strings without params ✅
        SwiftRegex(pattern: "String\\((.*)\\)"+basePattern+"\\,\\s*paramDictionary", order: .fallbackKey), // Swift constructed string with params ✅
        SwiftRegex(pattern: "String\\((.*)\\)"+basePattern+"\\)", order: .fallbackKey), // Swift constructed string without params ✅
    ]
    
    for regex in swiftRegexes {
        
        let results = string.matches(regex.pattern, options: .caseInsensitive)
        
        for match in results {
            
            var localisation = Localisation()
            
            if match.count > 1 {
                
                if regex.order == .keyFallback {
                    localisation.key = match[1].match
                } else {
                    localisation.value = match[1].match
                }
            }
            
            if match.count > 2 {
                
                if regex.order == .keyFallback {
                    localisation.value = match[2].match
                } else {
                    localisation.key = match[2].match
                }
            }
            
            newLocalisations.append(localisation)
            
            if match.count > 0 {
                string = string.replacingOccurrences(of: match[0].match, with: "")
            }
        }
    }
	
	if newLocalisations.count != matchCount {
		print("⚠️ Missed \(matchCount - newLocalisations.count) localisations in \(path.components(separatedBy: "/").last ?? path)")
	}
	
	localisations.append(contentsOf: newLocalisations)
}

func addObjcLocalisations(_ path: String) {
    
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)), var string = String(data: data, encoding: String.Encoding.utf8) else { return }
    
	print("Parsing \(path.components(separatedBy: "/").last ?? path) for Localised Strings")
	let matchCount = string.countInstances(of: "stringWithLocalisationKey:") + string.countInstances(of: "attributedStringWithLocalisationKey:")
    localisationsCount += matchCount
    
    // Match on class methods for localised strings
    var classMethodMatches = string.matches("\\[NSString stringWithLocalisationKey:\\s*([^]\\n\\r]*)\\]", index:0, options: .caseInsensitive)
    classMethodMatches.append(contentsOf: string.matches("\\[NSString attributedStringWithLocalisationKey:\\s*([^]\\n\\r]*)\\]", index:0, options: .caseInsensitive))
	
	var newLocalisations: [Localisation] = []
    
    for match in classMethodMatches {
        
        var localisation = Localisation()
        
        // If we're a class method, then the key is the first result surrounded by a "
        localisation.key = match.match.matches("\"([^\"]+)\"", index:1, options: .caseInsensitive).first?.match
        // And the fallback string is after the fallbackString: parameter
        localisation.value = match.match.matches("fallbackString:\\s*@\\\"([^[]]]+)\\\"", index:1, options: .caseInsensitive).first?.match
        
        // If no key is provided, or it is an empty string, this will catch it
        if localisation.key == nil || localisation.key == " fallbackString:@" {
            localisation.key = ""
        }
        
        newLocalisations.append(localisation)
        
        string = string.replacingOccurrences(of: match.match, with: "")
    }
    
    // Match on instance methods for localised string
	
    let instanceMethodValueMatches = string.matches("\\[(.*)stringWithLocalisationKey:\\s*([^]\\n\\r]*)\\]", index: 1, options: .caseInsensitive)
    let instanceMethodKeyMatches = string.matches("\\[(.*)stringWithLocalisationKey:\\s*([^]\\n\\r]*)\\]", index: 2, options: .caseInsensitive)
    
    for (index, fallback) in instanceMethodValueMatches.enumerated() {
        
        var localisation = Localisation()
        let keyMatch = instanceMethodKeyMatches[index]
        
        // If we're an instance method, then the key is the first result of keyMatch surrounded by a "
        localisation.key = keyMatch.match.matches("\"([^\"]+)\"", index:1, options: .caseInsensitive).first?.match
        // And the fallback string is after the fallbackString: parameter
        localisation.value = fallback.match.matches("\"([^\"]+)\"", index:1, options: .caseInsensitive).first?.match
        
        // If no key is provided, or it is an empty string, this will catch it
        if localisation.key == nil || localisation.key == " fallbackString:@" {
            localisation.key = ""
        }

        newLocalisations.append(localisation)
    }
	
	if newLocalisations.count != matchCount {
		print("⚠️ Missed \(matchCount - newLocalisations.count) localisations in \(path.components(separatedBy: "/").last ?? path)")
	}
	
	localisations.append(contentsOf: newLocalisations)
}

func addXibLocalisations(_ path: String) {
	
	guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)), var string = String(data: data, encoding: String.Encoding.utf8) else { return }
	
	print("Parsing \(path.components(separatedBy: "/").last ?? path) for Localised Strings")
	let matchCount = string.countInstances(of: "keyPath=\"localisationKey\"")
	localisationsCount += matchCount
	
	// Order is imporant here
	
	let matches = string.matches("keyPath=\"localisationKey\".*value=\\\"(.*)\\\"", index: 1, options: .caseInsensitive)
	
	if matches.count != matchCount {
		print("⚠️ Missed \(matchCount - matches.count) localisations in \(path.components(separatedBy: "/").last ?? path)")
	}
	
	for match in matches {
		
		var localisation = Localisation()
		
		// If we're a class method, then the key is the first result surrounded by a "
		localisation.key = match.match
		
		// If no key is provided, or it is an empty string, this will catch it
		if localisation.key == nil {
			localisation.key = ""
		}
		
		localisations.append(localisation)
		
		string = string.replacingOccurrences(of: match.match, with: "")
	}
}

print("Please enter the file path to the Project you want to parse for Localised Strings")
var filePath = readLine(strippingNewline: true)
while filePath == nil {
	filePath = readLine(strippingNewline: true)
}

filePath = filePath?.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\\ ", with: " ")
print("Parsing contents of \(filePath!) for Localised Strings")

// Insert code here to initialize your application

for path in FileManager.default.recursivePathsForResource("m", directory: filePath!) {
    addObjcLocalisations(path)
}

for otherPath in FileManager.default.recursivePathsForResource("swift", directory: filePath!) {
    addSwiftLocalisations(otherPath)
}

for xibPath in FileManager.default.recursivePathsForResource("xib", directory: filePath!) {
	addXibLocalisations(xibPath)
}

for storyboardPath in FileManager.default.recursivePathsForResource("storyboard", directory: filePath!) {
	addXibLocalisations(storyboardPath)
}

var finalLocalisations: [Localisation] = []

localisations.forEach { (localisation) in
	
	if !finalLocalisations.contains(where: { $0.key == localisation.key }) {
		finalLocalisations.append(localisation)
	}
}

// I'm so sorry
let objcVariablesRegexes = [
    "%[\\d]*.?[\\d]*[@dDuUxXoOfeEgGcCsSpaAFp]",
    "%l[iduxf]",
    "%zx"
]
let swiftVariableRegexes = [
    "\\s*\\+*\\s*([^(^\"^+^-^\\/^\\^\\s]+)\\s*\\++\\s*", // Catches all variables from strings like: "Some String"+VarName+"Some Other String" apart from the last added component
    "\\s*\\+\\s*([^(^\"^+^-^\\/^\\^\\s]+)$",
    "\\\\(([^(^\"^+^-^\\/^\\^\\s\\0-9]*[^(^\"^+^-^\\/^\\^\\s]+)\\)"
]
let swiftVariablesRegex = ""

let localisationsWithVariableKeys = localisations.filter({
    
    var variables: [(match: String, range: NSRange)] = []
    
    for swiftRegex in swiftVariableRegexes {
		let matches = $0.key.matches(swiftRegex, index: 0, options: [])
		variables.append(contentsOf: matches)
    }
    
    for objcRegex in objcVariablesRegexes {
		let matches = $0.key.matches(objcRegex, index: 0, options: [])
        variables.append(contentsOf: matches)
    }
    
    return variables.count > 0
})

if localisationsWithVariableKeys.count > 0 {
    
    print("Looks like some of your localisations have variables in their keys, do you want to let us know what the possible variables are? (Y/N)")
    
    var shouldFixVarLocalisations = readLine(strippingNewline: true)?.boolValue()
    
    while (shouldFixVarLocalisations == nil) {
        print("Looks like some of your localisations have variables in their keys, do you want to let us know what the possible variables are? (Y/N)")
        shouldFixVarLocalisations = readLine(strippingNewline: true)?.boolValue()
    }
    
    if shouldFixVarLocalisations! {
        
        localisationsWithVariableKeys.forEach({ (localisation) in
			
			
		})
    }
}

print("Would you like us to check the CMS for localisations which already exist? (Y/N)")

var shouldCheckCMS = readLine(strippingNewline: true)?.boolValue()

while shouldCheckCMS == nil {
    print("Would you like us to check the CMS for localisations which already exist (This relies on you having downloaded the latest storm bundle)? (Y/N)")
    shouldCheckCMS = readLine(strippingNewline: true)?.boolValue()
}

if shouldCheckCMS! {
	
	print("Please enter the full path to the localisation file")
	var localisationFile = readLine(strippingNewline: true)
	while localisationFile == nil {
		print("Please enter the full path to the localisation file")
		localisationFile = readLine(strippingNewline: true)
	}
	
	localisationFile = localisationFile?.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\\ ", with: " ")
	
	let localisationFilePath = URL(fileURLWithPath: localisationFile!)
	
	guard let localisationData = try? Data(contentsOf: localisationFilePath), let localisationObject = try? JSONSerialization.jsonObject(with: localisationData, options: []), let localisationDictionary = localisationObject as? [String : Any] else {
		print("Failed to read localisation file, please run the command again and retry")
		exit(EXIT_FAILURE)
	}
	
	let keys = localisationDictionary.keys
	finalLocalisations = finalLocalisations.filter({ (localisation) -> Bool in
		return !keys.contains(where: { (key) -> Bool in
			return key == localisation.key
		})
	})
}

var string = ""
for var localisation in finalLocalisations {
	
	localisation.clean()
	
	if let aKey = localisation.key {
		string += aKey
	}
	string += ","
	
	if let aValue = localisation.value {
		string += aValue
	} else {
		string += "Unknwown Value"
	}
	
	string += "\n"
}

if localisationsCount != localisations.count {
	print(PrintColor.Red + "Parsed \(localisations.count) of \(localisationsCount) Localised Strings ❌")
} else {
	print(PrintColor.Green + "Parsed \(localisations.count) of \(localisationsCount) Localised Strings ✅")
}

let savePath = filePath! + "/\(localisations.count) of \(localisationsCount).csv"

print("Saving Localisations to \(savePath)")
try? string.data(using: String.Encoding.utf8)?.write(to: URL(fileURLWithPath: savePath), options: [.atomic])
