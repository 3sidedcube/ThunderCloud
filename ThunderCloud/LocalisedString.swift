//
//  LocalisedString.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 24/01/2016.
//  Copyright © 2016 threesidedcube. All rights reserved.
//

import Foundation
import ObjectiveC

private var localisationKeyAssociationKey: UInt8 = 0

public extension String {
    
    /**
    Returns the key for the NSString
    - discussion This can be nil-checked to see if a string is localised or not
    */
    public var localisationKey: String? {
        get {
            return objc_getAssociatedObject(self, &localisationKeyAssociationKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &localisationKeyAssociationKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public func localised(with key: String!) -> String {
        
        var finalString = NSString(localisationKey: key, fallbackString: self) as String
        finalString.localisationKey = key
        
        return finalString
    }
    
    public func localised(with key: String!, paramDictionary: [String: Any]!) -> String {
        
        var string = NSString(localisationKey: key, paramDictionary: paramDictionary, fallbackString:self ) as String
        string.localisationKey = key
        
        return string
    }
}
