//
//  BundleHelper.swift
//  BundleApp
//
//  Created by Ben Shutt on 25/05/2023.
//

import Foundation
import ThunderCloud

struct BundleHelper {

    static var bundleDirectory: URL {
        get throws {
            let url = ContentController.shared.bundleDirectory
            guard let url else { throw BundleHelperError.bundleDirectory }
            return url
        }
    }

    static func printBundleDirectory() throws {
        try print("Contents of \(bundleDirectory)")
        try FileManager.default.contentsOfDirectory(
            at: bundleDirectory,
            includingPropertiesForKeys: nil,
            options: []
        ).forEach { url in
            var isDirectory: ObjCBool = false
            let exists = FileManager.default.fileExists(
                atPath: url.path(),
                isDirectory: &isDirectory
            )

            let isDir = isDirectory.boolValue && exists
            print("\(isDir): \(url.lastPathComponent)")
        }
    }
}

enum BundleHelperError: Error {
    case bundleDirectory
}
