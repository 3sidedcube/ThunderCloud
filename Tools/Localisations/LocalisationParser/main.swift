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

func + (let left: PrintColor, let right: String) -> String {
    return left.rawValue + right + " \u{001B}[39m" // Prints in the colour, and then resets to default colour!
}

func input() -> String {
    
    let keyboard = NSFileHandle.fileHandleWithStandardInput()
    let inputData = keyboard.availableData
    
    let strData = NSString(data: inputData, encoding: NSUTF8StringEncoding)!
    return strData.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
}

extension String {
    
    func matches(regex: String, index: Int, options: NSRegularExpressionOptions) -> [(match:String, matchRange:NSRange)] {
        
        do {
            
            let regex = try NSRegularExpression(pattern: regex,
                                                options: options)
            
            let nsString = self as NSString
            let results = regex.matchesInString(self, options: .ReportProgress, range: NSMakeRange(0, nsString.length))
            
            return results.map({
                
                let result = $0
                if result.numberOfRanges > index {
                    
                    let range = result.rangeAtIndex(index)
                    
                    if range.length + range.location <= nsString.length {
                        return (nsString.substringWithRange(range), range)
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
    
    func matches(regex: String, options: NSRegularExpressionOptions) -> [[(match:String, matchRange:NSRange)]] {
        
        do {
            
            let regex = try NSRegularExpression(pattern: regex,
                                                options: options)
            
            let nsString = self as NSString
            let results = regex.matchesInString(self, options: .ReportProgress, range: NSMakeRange(0, nsString.length))
            
            return results.map({
                
                let result = $0
                var captures: [(match:String, matchRange:NSRange)] = []
                
                for index in 0..<result.numberOfRanges {
                    
                    let range = result.rangeAtIndex(index)
                    captures.append((nsString.substringWithRange(range), range))
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

extension NSFileManager {
    
    func recursivePathsForResource(type: String?, directory: String) -> [String] {
        
        var filePaths: [String] = []
        let enumerator = NSFileManager.defaultManager().enumeratorAtPath(directory)
        
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
        
        key = key.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\""))
        key = key.stringByReplacingOccurrencesOfString(").capitalizedString", withString: "")
        key = key.stringByReplacingOccurrencesOfString(").lowercaseString", withString: "")
        key = key.stringByReplacingOccurrencesOfString(").uppercaseString", withString: "")
        key = key.stringByReplacingOccurrencesOfString(".capitalizedString", withString: "")
        key = key.stringByReplacingOccurrencesOfString(".lowercaseString", withString: "")
        key = key.stringByReplacingOccurrencesOfString(".uppercaseString", withString: "")
        
        value = value?.stringByReplacingOccurrencesOfString(").capitalizedString", withString: "")
        value = value?.stringByReplacingOccurrencesOfString(").lowercaseString", withString: "")
        value = value?.stringByReplacingOccurrencesOfString(").uppercaseString", withString: "")
        value = value?.stringByReplacingOccurrencesOfString(".capitalizedString", withString: "")
        value = value?.stringByReplacingOccurrencesOfString(".lowercaseString", withString: "")
        value = value?.stringByReplacingOccurrencesOfString(".uppercaseString", withString: "")
    }
}


var localisations: [Localisation] = []
var localisationsCount = 0

enum LocalisationRegexOrder {
    case FallbackKey  // Fallback comes before key in result "Hey".stringWithLocalisationKey("_SOME_KEY")
    case KeyFallback  // Key comes before fallback in result NSString(localisationKey:"_KEY", fallbackString:"Hey 2")
}

struct SwiftRegex {
    
    var pattern = ""
    var order = LocalisationRegexOrder.KeyFallback
    
    init(pattern aPattern: String, order anOrder: LocalisationRegexOrder?) {
        
        pattern = aPattern
        if let newOrder = anOrder {
            order = newOrder
        }
    }
}

func addSwiftLocalisations(path: String) {
    
    guard let data = NSData(contentsOfFile: path), var string = String(data: data, encoding: NSUTF8StringEncoding) else { return }
    
    print("Parsing \(path) for Localised Strings")
    localisationsCount += (string.componentsSeparatedByString("localisationKey:").count - 1)
    localisationsCount += (string.componentsSeparatedByString("stringWithLocalisationKey(").count - 1)
    
    // Order is imporant here
    let swiftRegexes = [
        SwiftRegex(pattern: "NSString\\(localisationKey:\\s*(.*)\\s*,.*fallbackString:\\s*(.*).*\\)", order: nil), // NSString method with fallback ✅
        SwiftRegex(pattern: "NSString\\(localisationKey:\\s*(.*)\\s*\\)", order: nil), // NSString method without fallback ✅
        SwiftRegex(pattern: "\"(.*)\".stringWithLocalisationKey\\(\\s*(.*),\\s*paramDictionary", order: .FallbackKey), // Swift literal strings with params ✅
        SwiftRegex(pattern: "\"(.*)\".stringWithLocalisationKey\\(\\s*(.*)\\)", order: .FallbackKey), // Swift literal strings without params ✅
        SwiftRegex(pattern: "String\\((.*)\\).stringWithLocalisationKey\\(\\s*\\s*(.*),\\s*paramDictionary", order: .FallbackKey), // Swift constructed string with params ✅
        SwiftRegex(pattern: "String\\((.*)\\).stringWithLocalisationKey\\(\\s*\\s*(.*)\\)", order: .FallbackKey), // Swift constructed string without params ✅
    ]
    
    for regex in swiftRegexes {
        
        let results = string.matches(regex.pattern, options: .CaseInsensitive)
        
        for match in results {
            
            var localisation = Localisation()
            
            if match.count > 1 {
                
                if regex.order == .KeyFallback {
                    localisation.key = match[1].match
                } else {
                    localisation.value = match[1].match
                }
            }
            
            if match.count > 2 {
                
                if regex.order == .KeyFallback {
                    localisation.value = match[2].match
                } else {
                    localisation.key = match[2].match
                }
            }
            
            localisations.append(localisation)
            
            if match.count > 0 {
                string = string.stringByReplacingOccurrencesOfString(match[0].match, withString: "")
            }
        }
    }
}

func addObjcLocalisations(path: String) {
    
    guard let data = NSData(contentsOfFile: path), var string = String(data: data, encoding: NSUTF8StringEncoding) else { return }
    
    print("Parsing \(path) for Localised Strings")
    localisationsCount += (string.componentsSeparatedByString("stringWithLocalisationKey:").count - 1)
    localisationsCount += (string.componentsSeparatedByString("attributedStringWithLocalisationKey:").count - 1)
    
    // Match on class methods for localised strings
    var classMethodMatches = string.matches("\\[NSString stringWithLocalisationKey:\\s*(.*)\\]", index:0, options: .CaseInsensitive)
    classMethodMatches.appendContentsOf(string.matches("\\[NSString attributedStringWithLocalisationKey:\\s*(.*)\\]", index:0, options: .CaseInsensitive))
    
    for match in classMethodMatches {
        
        var localisation = Localisation()
        
        // If we're a class method, then the key is the first result surrounded by a "
        localisation.key = match.match.matches("\"([^\"]+)\"", index:1, options: .CaseInsensitive).first?.match
        // And the fallback string is after the fallbackString: parameter
        localisation.value = match.match.matches("fallbackString:\\s*@\\\"([^[]]]+)\\\"", index:1, options: .CaseInsensitive).first?.match
        
        // If no key is provided, or it is an empty string, this will catch it
        if localisation.key == nil || localisation.key == " fallbackString:@" {
            localisation.key = ""
        }
        
        localisations.append(localisation)
        
        string = string.stringByReplacingOccurrencesOfString(match.match, withString: "")
    }
    
    // Match on instance methods for localised string
    let instanceMethodValueMatches = string.matches("\\[(.*)stringWithLocalisationKey:\\s*(.*)\\]", index: 1, options: .CaseInsensitive)
    let instanceMethodKeyMatches = string.matches("\\[(.*)stringWithLocalisationKey:\\s*(.*)\\]", index: 2, options: .CaseInsensitive)
    
    for (index, fallback) in instanceMethodValueMatches.enumerate() {
        
        var localisation = Localisation()
        let keyMatch = instanceMethodKeyMatches[index]
        
        // If we're an instance method, then the key is the first result of keyMatch surrounded by a "
        localisation.key = keyMatch.match.matches("\"([^\"]+)\"", index:1, options: .CaseInsensitive).first?.match
        // And the fallback string is after the fallbackString: parameter
        localisation.value = fallback.match.matches("\"([^\"]+)\"", index:1, options: .CaseInsensitive).first?.match
        
        // If no key is provided, or it is an empty string, this will catch it
        if localisation.key == nil || localisation.key == " fallbackString:@" {
            localisation.key = ""
        }

        localisations.append(localisation)
    }
}

print("Please enter the file path to the Project you want to parse for Localised Strings")
var filePath = "/Users/simonmitchell/Documents/Coding/3SidedCube/Emergency/Thunder Cloud/Tools/Localisations/TestFolder" //input()
print("Parsing contents of \(filePath) for Localised Strings")

// Insert code here to initialize your application

for path in NSFileManager.defaultManager().recursivePathsForResource("m", directory: filePath) {
    addObjcLocalisations(path)
}

for otherPath in NSFileManager.defaultManager().recursivePathsForResource("swift", directory: filePath) {
    addSwiftLocalisations(otherPath)
}

var string = ""
for var localisation in localisations {
    
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

let savePath = filePath + "/\(localisations.count) of \(localisationsCount).csv"

print("Saving Localisations to \(savePath)")
string.dataUsingEncoding(NSUTF8StringEncoding)?.writeToFile(savePath, atomically: true)

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
        variables.appendContentsOf($0.key.matches(swiftRegex, index:0, options: NSRegularExpressionOptions(rawValue: 0)))
    }
    
    for objcRegex in objcVariablesRegexes {
        variables.appendContentsOf($0.key.matches(objcRegex, index:0, options: NSRegularExpressionOptions(rawValue: 0)))
    }
    
    return variables.count > 0
})

if localisationsWithVariableKeys.count > 0 {
    
    print("Looks like some of your localisations have variables in their keys, do you want to let us know what the possible variables are? (Y/N)")
    
    var shouldFixVarLocalisations = input().boolValue()
    
    while (shouldFixVarLocalisations == nil) {
        print("Looks like some of your localisations have variables in their keys, do you want to let us know what the possible variables are? (Y/N)")
        shouldFixVarLocalisations = input().boolValue()
    }
    
    if shouldFixVarLocalisations! {
        
        
    }
}

print("Check CMS for missing localisations? (Y/N)")

var shouldCheckCMS = input().boolValue()

while (shouldCheckCMS == nil) {
    print("Looks like some of your localisations have variables in their keys, do you want to let us know what the possible variables are? (Y/N)")
    shouldCheckCMS = input().boolValue()
}

if shouldCheckCMS! {
    
}
