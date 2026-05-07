//
//  JSONStringTests.swift
//  ThunderCloudTests
//
//  Created by Simon Mitchell on 03/04/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import XCTest

class JSONStringTests: XCTestCase {

    func testDictionaryWithValidJSONObjectsReturnsCorrectString() {
        
        let dict: [String : Any] = [
            "number": 1.23,
            "string": "string",
            "boolean": true,
            "array": [],
            "object": [:],
            "null": NSNull()
        ]
        
        let string = String(dict, options: [.prettyPrinted, .sortedKeys])
        XCTAssertEqual(string, "{\n  \"array\" : [\n\n  ],\n  \"boolean\" : true,\n  \"null\" : null,\n  \"number\" : 1.23,\n  \"object\" : {\n\n  },\n  \"string\" : \"string\"\n}")
    }

    func testArrayWithValidJSONObjectsReturnsCorrectString() {
        
        let array: [[String : Any]] = [
            [
                "number": 1.23,
                "string": "string",
                "boolean": true,
                "array": [],
                "object": [:],
                "null": NSNull()
            ]
        ]
        
        let string = String(array, options: [.prettyPrinted, .sortedKeys])
        XCTAssertEqual(string, "[\n  {\n    \"array\" : [\n\n    ],\n    \"boolean\" : true,\n    \"null\" : null,\n    \"number\" : 1.23,\n    \"object\" : {\n\n    },\n    \"string\" : \"string\"\n  }\n]")
    }
    
    func testInvalidDictionaryReturnsNil() {
        
        let invalidDict: [String : Any] = [
            "invalid": CGPoint.zero
        ]
        
        let string = String(invalidDict)
        XCTAssertNil(string)
    }
    
    func testInvalidArrayReturnsNil() {
        
        let invalidArray = [
            CGPoint.zero
        ]
        
        let string = String(invalidArray)
        XCTAssertNil(string)
    }
}
