//
//  StormFile.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 12/12/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import Foundation

/// A directory in the Storm bundle
public enum StormDirectory: String {
    
    /// Directory for data files
    case data
}

/// A file in the Storm bundle
public struct StormFile {
    
    /// File name of the file
    public var resourceName: String
    
    /// The extension of the file
    public var `extension`: String
    
    /// Directory the file is in
    public var directory: StormDirectory
    
    /// Public memberwise init
    public init(resourceName: String, `extension`: String, directory: StormDirectory) {
        self.resourceName = resourceName
        self.extension = `extension`
        self.directory = directory
    }
}

// MARK: - Extensions

/// A error that can occur when working with `StormFile`s
public enum StormFileError: Error {
    case fileNotFound(StormFile)
}

public extension ContentController {

    /// `URL` for `StormFile`
    func fileURL(from file: StormFile) -> URL? {
        return ContentController.shared.fileUrl(
            forResource: file.resourceName,
            withExtension: file.extension,
            inDirectory: file.directory.rawValue)
    }
    
    /// Decode a given json `StormFile` into a `T`
    func jsonDecode<T>(file: StormFile) throws -> T where T : Decodable {
        guard let url = fileURL(from: file) else {
            throw StormFileError.fileNotFound(file)
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
}
