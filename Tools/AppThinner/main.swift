//
//  main.swift
//  AppThinner
//
//  Created by Matthew Cheetham on 27/10/2015.
//  Copyright (c) 2015 Matt & Phill Collaboration. All rights reserved.
//

import Foundation

enum AssetResolution: String {
    case OneX = "1x"
    case TwoX = "2x"
    case ThreeX = "3x"
}

var inputDirectoryPath: String?
var outputDirectoryPath: String?
let fileManager = NSFileManager.defaultManager()
var generationDictionary = [String: [String: String]]()

func fileNameKey(filePath: String) -> String {
    
    //JPG
    var newFilePath = filePath.stringByReplacingOccurrencesOfString("_x0.75.jpg", withString: "", options: .CaseInsensitiveSearch, range: Range<String.Index>(start:filePath.startIndex, end:filePath.endIndex))
    newFilePath = newFilePath.stringByReplacingOccurrencesOfString("_x1.jpg", withString: "", options: .CaseInsensitiveSearch, range: Range<String.Index>(start:newFilePath.startIndex, end:newFilePath.endIndex))
    newFilePath = newFilePath.stringByReplacingOccurrencesOfString("_x1.5.jpg", withString: "", options: .CaseInsensitiveSearch, range: Range<String.Index>(start:newFilePath.startIndex, end:newFilePath.endIndex))
    newFilePath = newFilePath.stringByReplacingOccurrencesOfString("_x2.jpg", withString: "", options: .CaseInsensitiveSearch, range: Range<String.Index>(start:newFilePath.startIndex, end:newFilePath.endIndex))
    newFilePath = newFilePath.stringByReplacingOccurrencesOfString("_x3.jpg", withString: "", options: .CaseInsensitiveSearch, range: Range<String.Index>(start:newFilePath.startIndex, end:newFilePath.endIndex))
    
    //PNG
    newFilePath = newFilePath.stringByReplacingOccurrencesOfString("_x0.75.png", withString: "", options: .CaseInsensitiveSearch, range: Range<String.Index>(start:newFilePath.startIndex, end:newFilePath.endIndex))
    newFilePath = newFilePath.stringByReplacingOccurrencesOfString("_x1.png", withString: "", options: .CaseInsensitiveSearch, range: Range<String.Index>(start:newFilePath.startIndex, end:newFilePath.endIndex))
    newFilePath = newFilePath.stringByReplacingOccurrencesOfString("_x1.5.png", withString: "", options: .CaseInsensitiveSearch, range: Range<String.Index>(start:newFilePath.startIndex, end:newFilePath.endIndex))
    newFilePath = newFilePath.stringByReplacingOccurrencesOfString("_x2.png", withString: "", options: .CaseInsensitiveSearch, range: Range<String.Index>(start:newFilePath.startIndex, end:newFilePath.endIndex))
    newFilePath = newFilePath.stringByReplacingOccurrencesOfString("_x3.png", withString: "", options: .CaseInsensitiveSearch, range: Range<String.Index>(start:newFilePath.startIndex, end:newFilePath.endIndex))

    return newFilePath
}

func resolutionOf(filePath: String) -> AssetResolution? {
    
    if filePath.rangeOfString("_x1.jpg") != nil || filePath.rangeOfString("_x1.png") != nil {
        
        return AssetResolution(rawValue:"1x")
        
    }
    
    if filePath.rangeOfString("_x2.jpg") != nil || filePath.rangeOfString("_x2.png") != nil {
        
        return AssetResolution(rawValue: "2x")
        
    }
    
    if filePath.rangeOfString("_x3.jpg") != nil || filePath.rangeOfString("_x3.png") != nil {
        
        return AssetResolution(rawValue: "3x")
        
    }
    
    return nil
    
}

func addToGenerationDictionary(filePath: String) -> Void {
    
    guard let resolution = resolutionOf(filePath) else {
        return
    }
    
    if var existingDictionary = generationDictionary[fileNameKey(filePath)] {
        
        existingDictionary[resolution.rawValue] = filePath
        generationDictionary[fileNameKey(filePath)] = existingDictionary
        
    } else {
        
        generationDictionary[fileNameKey(filePath)] = [resolution.rawValue: filePath]

    }
    
}

func removeOriginalAsset(fileName: String) -> Void {
    
    guard let filePath = inputDirectoryPath where fileManager.fileExistsAtPath(filePath.stringByAppendingString("/\(fileName)")) else { return }
    
    do {
        try fileManager.removeItemAtPath(filePath.stringByAppendingString("/\(fileName)"))
    } catch let error as NSError {
        print(error.localizedDescription)
    }
}

//Main Code
for (index, argument) in Process.arguments.enumerate() {
    
    switch argument {
        
    case "--inputDir", "-i" where Process.arguments.count > index + 1:
        
        inputDirectoryPath = Process.arguments[index+1]
        print("input directory : \(Process.arguments[index+1])")
    
    case "--outputDir", "-o" where Process.arguments.count > index + 1:
        
        outputDirectoryPath = Process.arguments[index+1]
        print("output directory : \(Process.arguments[index+1])")
        if let outputDir = outputDirectoryPath {
            
            if (fileManager.fileExistsAtPath(outputDir)) {
                try fileManager.removeItemAtPath(outputDir)
            }
            try fileManager.createDirectoryAtPath(outputDir, withIntermediateDirectories: true, attributes: nil)
        }

    default:
        break
    }
}

if let filePath = inputDirectoryPath, enumerator = fileManager.enumeratorAtPath(filePath), outputDir = outputDirectoryPath {
    
    //Generate dictionary of files
    while let element = enumerator.nextObject() as? String {
        print(element, terminator: "")
        
        addToGenerationDictionary(element)
    }
    
    // Do a secondary enumeration to make sure there are no 0.75x or 1.5x files remaining which didn't have a 1x/2x/3x counterpart
    if let secondaryEnumerator = fileManager.enumeratorAtPath(filePath) {
        
        while let remainingElement = secondaryEnumerator.nextObject() as? String {
            
            if let _ = generationDictionary[fileNameKey(filePath)] {
                
                // If there is already an existing dictionary we don't need this file and so can remove the original asset
                removeOriginalAsset(filePath)
                
            } else {
                
                // If there is no generation dictionary for a stranded asset then set the 1x to be this value
                generationDictionary[fileNameKey(filePath)] = ["1x": filePath]
            }
        }
    }
    
    //Loop through each one and generate dictionary
    for (key, dictionaryEntry) in generationDictionary {
    
        let imageSetDir = outputDir.stringByAppendingString("/\(key).imageset")
        var newImageArray = [[String: String]]()
        
        do {
            try fileManager.createDirectoryAtPath(imageSetDir, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription);
        }

        for (scale, fileName) in dictionaryEntry {
            
            newImageArray.append(["idiom": "universal", "scale": scale, "filename": fileName])
            
            do {
                
                try fileManager.copyItemAtPath(filePath.stringByAppendingString("/\(fileName)"), toPath: imageSetDir.stringByAppendingString("/\(fileName)"))
                removeOriginalAsset(fileName)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        var finalDictionary = ["images": newImageArray, "info": ["version": 1, "author": "xcode"]]
        
        print("saving xcasset with dictionary\(finalDictionary)")
        
        do {
            let contentData = try NSJSONSerialization.dataWithJSONObject(finalDictionary, options: .PrettyPrinted)
            contentData.writeToFile(imageSetDir.stringByAppendingString("/Contents.json"), atomically: true)
        } catch let error as NSError {
            print(error.localizedDescription);
        }
        
    }
}



