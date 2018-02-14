//
//  main.swift
//  AppThinner
//
//  Created by Matthew Cheetham on 27/10/2015.
//  Copyright (c) 2015 Matt & Phill Collaboration. All rights reserved.
//

import Foundation

extension String {
    
    func isValidAssetResolution() -> Bool {
        return ["1x", "2x", "3x"].contains(self)
    }
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

func resolutionOf(filePath: String) -> String? {
    
    if filePath.rangeOfString("_x1.jpg") != nil || filePath.rangeOfString("_x1.png") != nil {
        
        return "1x"
        
    }
    
    if filePath.rangeOfString("_x2.jpg") != nil || filePath.rangeOfString("_x2.png") != nil {
        
        return "2x"
        
    }
    
    if filePath.rangeOfString("_x3.jpg") != nil || filePath.rangeOfString("_x3.png") != nil {
        
        return "3x"
        
    }
    
    if filePath.rangeOfString("_x1.5.jpg") != nil || filePath.rangeOfString("_x1.5.png") != nil {
        
        return "1.5x"
        
    }
    
    if filePath.rangeOfString("_x0.75.jpg") != nil || filePath.rangeOfString("_x0.75.png") != nil {
        
        return "0.75x"
        
    }
    
    return nil
}

func addToGenerationDictionary(filePath: String) -> Void {
    
    guard let resolution = resolutionOf(filePath) where resolution.isValidAssetResolution() else {
        return
    }
    
    if var existingDictionary = generationDictionary[fileNameKey(filePath)] {
        
        existingDictionary[resolution] = filePath
        generationDictionary[fileNameKey(filePath)] = existingDictionary
        
    } else {
        
        generationDictionary[fileNameKey(filePath)] = [resolution: filePath]

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

func checkInGenerationDictionary(filePath: String) -> Void {
    
    if let resolution = resolutionOf(filePath) where resolution.isValidAssetResolution() { return }
    
    guard let resolution = resolutionOf(filePath) else { return }
    
    // Check if we already have a dictionary for this
    if var oldDictionary = generationDictionary[fileNameKey(filePath)] {
        
        // If we do, but it contains an 0.75x asset and we're a 1.5x asset, let's replace it!
        if let oneXPath = oldDictionary["1x"], oneXResolution = resolutionOf(oneXPath) where (oneXResolution == "0.75x" && resolution == "1.5x") {
            
            oldDictionary["1x"] = filePath
            generationDictionary[fileNameKey(filePath)] = oldDictionary
            
            // Remove the smaller 0.75x asset at it's path!
            removeOriginalAsset(oneXPath)
            
        } else { // Otherwise simply remove the asset
            
            removeOriginalAsset(filePath)
        }
        
    } else {
        
        // If there is no generation dictionary for a stranded asset then set the 1x to be this value
        generationDictionary[fileNameKey(filePath)] = ["1x": filePath]
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

inputDirectoryPath = "/Users/simonmitchell/Desktop/Test Bundle/content"
outputDirectoryPath = "/Users/simonmitchell/Desktop/Bundle.xcassets"

if let filePath = inputDirectoryPath, enumerator = fileManager.enumeratorAtPath(filePath), outputDir = outputDirectoryPath {
    
    //Generate dictionary of files
    while let element = enumerator.nextObject() as? String {
        print(element, terminator: "")
        
        addToGenerationDictionary(element)
    }
    
    // Do a secondary enumeration to make sure there are no 0.75x or 1.5x files remaining which didn't have a 1x/2x/3x counterpart
    if let secondaryEnumerator = fileManager.enumeratorAtPath(filePath) {
        
        while let remainingElement = secondaryEnumerator.nextObject() as? String {
            checkInGenerationDictionary(remainingElement)
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



