//
//  gunzip.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 07/04/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import Foundation
import zlib

/// Gunzips a file, without reading the whole file to memory
/// - Parameters:
///   - fileURL: The file url of the file to gunzip
///   - destination: The destination to gunzip the file to
public func gunzip(_ fileURL: URL, to destination: URL) throws {
    
    guard let writeStream = OutputStream(toFileAtPath: destination.path, append: false) else {
        throw GunzipError.failedToCreateWriteStream
    }
    
    let cfWriteStream = writeStream as CFWriteStream
    // Open the write stream
    guard CFWriteStreamOpen(writeStream) else {
        throw GunzipError.failedToOpenWriteStream
    }
    
    // gzopen the file
    let sourceFile = fileURL.path.withCString {
        return gzopen($0, "rb")
    }
    guard let _sourceFile = sourceFile else {
        throw GunzipError.failedToOpenFile
    }
    
    let bufferLength = 1024 * 256 // 256Kb
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferLength)
    
    // Clean up even if we throw an error
    defer {
        gzclose(_sourceFile)
        free(buffer)
        CFWriteStreamClose(cfWriteStream)
    }
    
    while true {
        
        let readBytes = gzread(_sourceFile, buffer, UInt32(bufferLength))
        
        guard readBytes > 0 else {
            if readBytes < 0 {
                throw readBytes == -1 ? GunzipError.decompressionFailed : GunzipError.unknownError
            }
            break
        }
        
        let writtenBytes = CFWriteStreamWrite(cfWriteStream, buffer, Int(readBytes))
        
        guard writtenBytes <= 0 else {
            continue
        }
        
        throw GunzipError.decompressionFailed
    }
}

enum GunzipError: Error {
    case decompressionFailed
    case failedToCreateWriteStream
    case failedToOpenWriteStream
    case failedToOpenFile
    case unknownError
}
