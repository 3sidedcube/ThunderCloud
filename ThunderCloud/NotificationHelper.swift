//
//  NotificationHelper.swift
//  ThunderCloud
//
//  Created by Matthew Cheetham on 06/02/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

/** An enum of errors that might occur while loading a result*/
enum NotificationHelperError: Error {
    /** The method did not return a value or an error. Something went wrong */
    case InvalidInputOrMethodFailure
}

/// A generic enum to restrict our methods to simply an error or a result
///
/// - success: The value if we are successful
/// - failure: The error object if we fail
enum Result<T> {
    case success(T)
    case failure(Error)
}

extension Result {
    
    /// Initializes a Result from an optional success value and an optional error. Useful for converting return values from many asynchronous Apple APIs to Result.
    init(value: T?, error: Error?) {
        
        switch (value, error) {
        case (let v?, _):
            self = .success(v)
        case (nil, let e?):
            self = .failure(e)
        case (nil, nil):
            self = .failure(NotificationHelperError.InvalidInputOrMethodFailure)
        }
    }
}

/// A class to aid the process of registering for notifications
class NotificationHelper {
    
    class func registerForNotifications(completion: @escaping (Result<String>) -> Void) {
        
        let result = Result<String>(value: nil, error: nil)
        completion(result)
    }
}
