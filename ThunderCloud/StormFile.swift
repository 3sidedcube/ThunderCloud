//
//  StormFile.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 12/12/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import Foundation

/// A directory in the Storm bundle
enum StormDirectory: String {
    
    /// Directory for data files
    case data
}

/// A file in the Storm bundle
struct StormFile {
    
    /// File name of the file
    var resourceName: String
    
    /// The extension of the file
    var `extension`: String
    
    /// Directory the file is in
    var directory: StormDirectory
}

// MARK: - Extensions

/// A error that can occur when working with `StormFile`s
enum StormFileError: Error {
    case fileNotFound(StormFile)
}

extension ContentController {

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
