//
//  LocalisationLocaleTests.swift
//  ThunderCloudTests
//
//  Created by Simon Mitchell on 27/02/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import XCTest
@testable import ThunderCloud

class LocalisationLocaleTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitialisesCorrectlyNilPublishInfo() {
        
        let dictionary: [AnyHashable : Any] = [
            "id": "unique",
            "code": "eng",
            "language": [
                "name": [
                    "native": "Spanish"
                ]
            ]
        ]
        
        let locale = LocalisationLocale(dictionary: dictionary)
        XCTAssertEqual(locale.languageCode, "eng")
        XCTAssertEqual(locale.uniqueIdentifier, "unique")
        XCTAssertEqual(locale.languageName, "Spanish")
        XCTAssertFalse(locale.isPublishable.test)
        XCTAssertFalse(locale.isPublishable.live)
    }
    
    func testInitialisesCorrectlyNilId() {
        
        let dictionary: [AnyHashable : Any] = [
            "code": "eng",
            "language": [
                "name": [
                    "native": "Spanish"
                ]
            ],
            "publishable": [
                "live": true,
                "test": true
            ]
        ]
        
        let locale = LocalisationLocale(dictionary: dictionary)
        XCTAssertEqual(locale.languageCode, "eng")
        XCTAssertNil(locale.uniqueIdentifier)
        XCTAssertEqual(locale.languageName, "Spanish")
        XCTAssertTrue(locale.isPublishable.test)
        XCTAssertTrue(locale.isPublishable.live)
    }
    
    func testInitialisesCorrectlyNilCode() {
        
        let dictionary: [AnyHashable : Any] = [
            "id": "test",
            "language": [
                "name": [
                    "native": "English"
                ]
            ],
            "publishable": [
                "live": true,
                "test": false
            ]
        ]
        
        let locale = LocalisationLocale(dictionary: dictionary)
        XCTAssertEqual(locale.languageCode, "")
        XCTAssertEqual(locale.uniqueIdentifier, "test")
        XCTAssertEqual(locale.languageName, "English")
        XCTAssertFalse(locale.isPublishable.test)
        XCTAssertTrue(locale.isPublishable.live)
    }
}
