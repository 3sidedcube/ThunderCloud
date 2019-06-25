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
let fileManager = FileManager.default
var generationDictionary = [String: [String: String]]()

func fileNameKey(_ filePath: String) -> String {
    //JPG
    var newFilePath = filePath.replacingOccurrences(of: "_x0.75.jpg", with: "", options: .caseInsensitive)
    newFilePath = newFilePath.replacingOccurrences(of: "_x1.jpg", with: "", options: .caseInsensitive)
    newFilePath = newFilePath.replacingOccurrences(of: "_x1.5.jpg", with: "", options: .caseInsensitive)
    newFilePath = newFilePath.replacingOccurrences(of: "_x2.jpg", with: "", options: .caseInsensitive)
    newFilePath = newFilePath.replacingOccurrences(of: "_x3.jpg", with: "", options: .caseInsensitive)
    
    //JPEG
    newFilePath = newFilePath.replacingOccurrences(of: "_x0.75.jpeg", with: "", options: .caseInsensitive)
    newFilePath = newFilePath.replacingOccurrences(of: "_x1.jpeg", with: "", options: .caseInsensitive)
    newFilePath = newFilePath.replacingOccurrences(of: "_x1.5.jpeg", with: "", options: .caseInsensitive)
    newFilePath = newFilePath.replacingOccurrences(of: "_x2.jpeg", with: "", options: .caseInsensitive)
    newFilePath = newFilePath.replacingOccurrences(of: "_x3.jpeg", with: "", options: .caseInsensitive)
    
    //PNG
    newFilePath = newFilePath.replacingOccurrences(of: "_x0.75.png", with: "", options: .caseInsensitive)
    newFilePath = newFilePath.replacingOccurrences(of: "_x1.png", with: "", options: .caseInsensitive)
    newFilePath = newFilePath.replacingOccurrences(of: "_x1.5.png", with: "", options: .caseInsensitive)
    newFilePath = newFilePath.replacingOccurrences(of: "_x2.png", with: "", options: .caseInsensitive)
    newFilePath = newFilePath.replacingOccurrences(of: "_x3.png", with: "", options: .caseInsensitive)

    return newFilePath
}

func resolutionOf(_ filePath: String) -> String? {
    if filePath.range(of: "_x1.jpg") != nil || filePath.range(of: "_x1.png") != nil || filePath.range(of: "_x1.jpeg") != nil {
        return "1x"
    }
    
    if filePath.range(of: "_x2.jpg") != nil || filePath.range(of: "_x2.png") != nil || filePath.range(of: "_x2.jpeg") != nil {
        return "2x"
    }
    
    if filePath.range(of: "_x3.jpg") != nil || filePath.range(of: "_x3.png") != nil || filePath.range(of: "_x3.jpeg") != nil {
        return "3x"
    }
    
    if filePath.range(of: "_x1.5.jpg") != nil || filePath.range(of: "_x1.5.png") != nil || filePath.range(of: "_x1.5.jpeg") != nil {
        return "1.5x"
    }
    
    if filePath.range(of: "_x0.75.jpg") != nil || filePath.range(of: "_x0.75.png") != nil || filePath.range(of: "_x0.75.jpeg") != nil {
        return "0.75x"
    }
    
    return nil
}

func addToGenerationDictionary(_ filePath: String) -> Void {
    guard let resolution = resolutionOf(filePath), resolution.isValidAssetResolution() else {
        return
    }
    
    if var existingDictionary = generationDictionary[fileNameKey(filePath)] {
        existingDictionary[resolution] = filePath
        generationDictionary[fileNameKey(filePath)] = existingDictionary
    } else {
        generationDictionary[fileNameKey(filePath)] = [resolution: filePath]
    }
}

func removeOriginalAsset(_ fileName: String) -> Void {
    guard let filePath = inputDirectoryPath, fileManager.fileExists(atPath: "\(filePath)/\(fileName)") else { return }
    
    do {
        try fileManager.removeItem(atPath: "\(filePath)/\(fileName)")
    } catch let error as NSError {
        print(error.localizedDescription)
    }
}

func checkInGenerationDictionary(_ filePath: String) -> Void {
    if let resolution = resolutionOf(filePath), resolution.isValidAssetResolution() { return }
    
    guard let resolution = resolutionOf(filePath) else { return }
    
    // Check if we already have a dictionary for this
    if var oldDictionary = generationDictionary[fileNameKey(filePath)] {
        
        // If we do, but it contains an 0.75x asset and we're a 1.5x asset, let's replace it!
        if let oneXPath = oldDictionary["1x"], let oneXResolution = resolutionOf(oneXPath), (oneXResolution == "0.75x" && resolution == "1.5x") {
            
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
for (index, argument) in CommandLine.arguments.enumerated() {
    guard CommandLine.arguments.count > index + 1 else {
        break
    }
    
    switch argument {
    case "--inputDir", "-i":
        inputDirectoryPath = CommandLine.arguments[index+1]
        print("input directory : \(CommandLine.arguments[index+1])")
    
    case "--outputDir", "-o":
        outputDirectoryPath = CommandLine.arguments[index+1]
        print("output directory : \(CommandLine.arguments[index+1])")
        if let outputDir = outputDirectoryPath {
            
            if (fileManager.fileExists(atPath: outputDir)) {
                try fileManager.removeItem(atPath: outputDir)
            }
            try fileManager.createDirectory(atPath: outputDir, withIntermediateDirectories: true, attributes: nil)
        }

    default:
        break
    }
}

guard let filePath = inputDirectoryPath, let enumerator = fileManager.enumerator(atPath: filePath), let outputDir = outputDirectoryPath else {
    exit(EXIT_FAILURE)
}

//Generate dictionary of files
while let element = enumerator.nextObject() as? String {
    print(element, terminator: "")
    
    addToGenerationDictionary(element)
}

// Do a secondary enumeration to make sure there are no 0.75x or 1.5x files remaining which didn't have a 1x/2x/3x counterpart
if let secondaryEnumerator = fileManager.enumerator(atPath: filePath) {
    while let remainingElement = secondaryEnumerator.nextObject() as? String {
        checkInGenerationDictionary(remainingElement)
    }
}

//Loop through each one and generate dictionary
for (key, dictionaryEntry) in generationDictionary {
    let imageSetDir = "\(outputDir)/\(key).imageset"
    var newImageArray = [[String: String]]()
    
    do {
        try fileManager.createDirectory(atPath: imageSetDir, withIntermediateDirectories: false, attributes: nil)
    } catch let error as NSError {
        print(error.localizedDescription);
    }
    
    for (scale, fileName) in dictionaryEntry {
        newImageArray.append(["idiom": "universal", "scale": scale, "filename": fileName])
        
        do {
            try fileManager.copyItem(atPath: "\(filePath)/\(fileName)", toPath: "\(imageSetDir)/\(fileName)")
            removeOriginalAsset(fileName)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    let finalDictionary: [String: Any] = ["images": newImageArray, "info": ["version": 1, "author": "xcode"]]
    
    print("saving xcasset with dictionary\(finalDictionary)")
    
    do {
        let contentData = try JSONSerialization.data(withJSONObject: finalDictionary, options: .prettyPrinted)
        
        let imageSetURL = URL(fileURLWithPath: "\(imageSetDir)/Contents.json")
        try contentData.write(to: imageSetURL, options: .atomic)
    } catch let error as NSError {
        print(error.localizedDescription);
    }
}
