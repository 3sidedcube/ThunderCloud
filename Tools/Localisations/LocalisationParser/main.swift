//
//  main.swift
//  LocalisationParser
//
//  Created by Simon Mitchell on 13/04/2016.
//  Copyright © 2016 Three Sided Cube. All rights reserved.
//

import Foundation
import Darwin
import Cocoa

func input() -> String {
    
    let keyboard = NSFileHandle.fileHandleWithStandardInput()
    let inputData = keyboard.availableData
    
    let strData = NSString(data: inputData, encoding: NSUTF8StringEncoding)!
    return strData.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
}

extension String {
    
    func matches(regex: String, index: Int, options: NSRegularExpressionOptions) -> [String] {
        
        do {
            
            let regex = try NSRegularExpression(pattern: regex,
                                                options: options)
            
            let nsString = self as NSString
            let results = regex.matchesInString(self, options: .ReportProgress, range: NSMakeRange(0, nsString.length))
            return results.map({
                nsString.substringWithRange($0.rangeAtIndex(index))
            })
            
        } catch _ {
            return []
        }
        
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
    
    var key: String?
    var value: String?
}


var localisations: [Localisation] = []
var localisationsCount = 0

func addSwiftLocalisations(path: String) {
    
    guard let data = NSData(contentsOfFile: path), var string = String(data: data, encoding: NSUTF8StringEncoding) else { return }
    
    print("Parsing \(path) for Localised Strings")
    localisationsCount += (string.componentsSeparatedByString("localisationKey:").count - 1)
    localisationsCount += (string.componentsSeparatedByString("stringWithLocalisationKey(").count - 1)
    
    for match in string.matches("NSString\\(localisationKey:\\s*([^)]+)\\)", index:0, options: .AllowCommentsAndWhitespace) {
        
        var localisation = Localisation()
        
        localisation.key = match.matches("\"([^\"]+)\"", index:1, options: .AllowCommentsAndWhitespace).first
        localisation.value = match.matches("fallbackString:\\s*\\\"([^)]+)\\\"", index:1, options: .AllowCommentsAndWhitespace).first
        
        if localisation.key == nil {
            localisation.key = ""
        }
        
        localisations.append(localisation)
        
        string = string.stringByReplacingOccurrencesOfString(match, withString: "")
    }
    
    // Match on instance methods for  localised string
    var instanceMethodValueMatches = string.matches("\"([^\"]+)\".stringWithLocalisationKey\\(\"\\s*([^)^\"]+)\"", index: 1, options: .CaseInsensitive)
    instanceMethodValueMatches.appendContentsOf(string.matches("String\\((.*)\\).stringWithLocalisationKey\\(\"\\s*([^)^\"]+)\"", index: 1, options: .CaseInsensitive))
    var instanceMethodKeyMatches = string.matches("\"([^\"]+)\".stringWithLocalisationKey\\(\"\\s*([^)^\"]+)\"", index: 2, options: .CaseInsensitive)
    instanceMethodKeyMatches.appendContentsOf(string.matches("String\\((.*)\\).stringWithLocalisationKey\\(\"\\s*([^)^\"]+)\"", index: 2, options: .CaseInsensitive))

    for (index, fallback) in instanceMethodValueMatches.enumerate() {
        
        var localisation = Localisation()
        let keyMatch = instanceMethodKeyMatches[index]
        
        // If we're an instance method, then the key is the first result of keyMatch surrounded by a "
        localisation.key = keyMatch
        // And the fallback string is after the fallbackString: parameter
        localisation.value = fallback
        
        // If no key is provided, or it is an empty string, this will catch it
        if localisation.key == nil || localisation.key == " fallbackString:@" {
            localisation.key = ""
        }
        
        localisations.append(localisation)
    }
}

func addObjcLocalisations(path: String) {
    
    guard let data = NSData(contentsOfFile: path), var string = String(data: data, encoding: NSUTF8StringEncoding) else { return }
    
    print("Parsing \(path) for Localised Strings")
    localisationsCount += (string.componentsSeparatedByString("stringWithLocalisationKey:").count - 1)
    localisationsCount += (string.componentsSeparatedByString("attributedStringWithLocalisationKey:").count - 1)
    
    // Match on class methods for localised strings
    var classMethodMatches = string.matches("\\[NSString stringWithLocalisationKey:\\s*([^]]+)\\]", index:0, options: .CaseInsensitive)
    classMethodMatches.appendContentsOf(string.matches("\\[NSString attributedStringWithLocalisationKey:\\s*([^]]+)\\]", index:0, options: .CaseInsensitive))
    
    for match in classMethodMatches {
        
        var localisation = Localisation()
        
        // If we're a class method, then the key is the first result surrounded by a "
        localisation.key = match.matches("\"([^\"]+)\"", index:1, options: .CaseInsensitive).first
        // And the fallback string is after the fallbackString: parameter
        localisation.value = match.matches("fallbackString:\\s*@\\\"([^[]]]+)\\\"", index:1, options: .CaseInsensitive).first
        
        // If no key is provided, or it is an empty string, this will catch it
        if localisation.key == nil || localisation.key == " fallbackString:@" {
            localisation.key = ""
        }
        
        localisations.append(localisation)
        
        string = string.stringByReplacingOccurrencesOfString(match, withString: "")
    }
    
    // Match on instance methods for localised string
    let instanceMethodValueMatches = string.matches("\\[(.*)stringWithLocalisationKey:\\s*([^]]+)\\]", index: 1, options: .CaseInsensitive)
    let instanceMethodKeyMatches = string.matches("\\[(.*)stringWithLocalisationKey:\\s*([^]]+)\\]", index: 2, options: .CaseInsensitive)
    
    for (index, fallback) in instanceMethodValueMatches.enumerate() {
        
        var localisation = Localisation()
        let keyMatch = instanceMethodKeyMatches[index]
        
        // If we're an instance method, then the key is the first result of keyMatch surrounded by a "
        localisation.key = keyMatch.matches("\"([^\"]+)\"", index:1, options: .CaseInsensitive).first
        // And the fallback string is after the fallbackString: parameter
        localisation.value = fallback.matches("\"([^\"]+)\"", index:1, options: .CaseInsensitive).first
        
        // If no key is provided, or it is an empty string, this will catch it
        if localisation.key == nil || localisation.key == " fallbackString:@" {
            localisation.key = ""
        }

        localisations.append(localisation)
    }
}

print("Please enter the file path to the Project you want to parse for Localised Strings")
var filePath = input() //"/Users/simonmitchell/Documents/Coding/3SidedCube/Emergency/Thunder Cloud/Tools/Localisations/TestFolder"
print("Parsing contents of \(filePath) for Localised Strings")

// Insert code here to initialize your application

for path in NSFileManager.defaultManager().recursivePathsForResource("m", directory: filePath) {
    addObjcLocalisations(path)
}

for otherPath in NSFileManager.defaultManager().recursivePathsForResource("swift", directory: filePath) {
    addSwiftLocalisations(otherPath)
}

var string = ""
for localisation in localisations {
    
    if let aKey = localisation.key {
        string += aKey
    }
    string += "\t"
    
    if let aValue = localisation.value {
        string += aValue
    }
    
    string += "\n"
}

print("Parsed \(localisations.count) of \(localisationsCount)")

let savePath = filePath + "/\(localisations.count) of \(localisationsCount).tsv"
print("Saving Localisations to \(savePath)")
string.dataUsingEncoding(NSUTF8StringEncoding)?.writeToFile(savePath, atomically: true)

print("Check CMS for missing localisations? (Y/N)")
