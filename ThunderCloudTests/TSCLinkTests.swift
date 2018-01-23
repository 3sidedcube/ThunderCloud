//
//  TSCLinkTests.swift
//  ThunderCloud
//
//  Created by Joel Trew on 18/09/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import XCTest
import ThunderCloud

class TSCLinkTests: XCTestCase {
    
    var stormLanguageController: StormLanguageController? = nil
    
    static let linkDictionary: [AnyHashable: Any] = [
        "class": "LocalisedLink",
        "title": [
            "class": "Text",
            "content": [
                "en": "Hello",
                "fra": "Bonjour"
            ]
        ],
        "type": "UriLink",
        "links": [
            [
                "class": "LocalisedLinkDetail",
                "src": "https://www.google.fr",
                "locale": "fra"
            ],
            [
                "class": "LocalisedLinkDetail",
                "src": "https://www.google.co.uk",
                "locale": "eng"
            ],
            [
                "class": "LocalisedLinkDetail",
                "src": "https://www.google.br",
                "locale": "bra_eng"
            ]
        ]
    ]

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitialisation() {
        
        StormLanguageController.shared.currentLanguage = "eng"
        
        let link = TSCLink(dictionary: TSCLinkTests.linkDictionary)
        
        XCTAssertNotNil(link, "Link initialised from localisedLink returned nil")
        if let link = link {
            
            XCTAssertNotNil(link.url)
            if let url = link.url {
                XCTAssertEqual(url.absoluteString, "https://www.google.co.uk")
            }
        }
    }
    
    
    func testLocalisedFrench() {
        
        StormLanguageController.shared.currentLanguage = "fra"
        
        let link = TSCLink(dictionary: TSCLinkTests.linkDictionary)
        
        XCTAssertNotNil(link, "Link initialised from localisedLink returned nil")
        if let link = link {
            
            XCTAssertNotNil(link.url)
            if let url = link.url {
                XCTAssertEqual(url.absoluteString, "https://www.google.fr")
            }
        }
    }
    
    
    func testPicksCorrectLanguageAndRegion() {
        
        StormLanguageController.shared.currentLanguage = "bra_eng"
        
        let link = TSCLink(dictionary: TSCLinkTests.linkDictionary)
        
        XCTAssertNotNil(link, "Link initialised from localisedLink returned nil")
        if let link = link {
            
            XCTAssertNotNil(link.url)
            if let url = link.url {
                XCTAssertEqual(url.absoluteString, "https://www.google.br")
            }
        }
    }
    
    // Tests falling back to main language, i.e usa_eng should fall back to eng and not bra_eng
    func testFallbackToMainLanguage() {
        
        StormLanguageController.shared.currentLanguage = "usa_eng"
        
        let link = TSCLink(dictionary: TSCLinkTests.linkDictionary)
        
        XCTAssertNotNil(link, "Link initialised from localisedLink returned nil")
        if let link = link {
            
            XCTAssertNotNil(link.url)
            if let url = link.url {
                XCTAssertEqual(url.absoluteString, "https://www.google.co.uk")
            }
        }
    }
    
    func testFallbackToMainToFirstLanguage() {
        
        StormLanguageController.shared.currentLanguage = "usa_kor"
        
        let link = TSCLink(dictionary: TSCLinkTests.linkDictionary)
        
        XCTAssertNotNil(link, "Link initialised from localisedLink returned nil")
        if let link = link {
            
            XCTAssertNotNil(link.url)
            if let url = link.url {
                XCTAssertEqual(url.absoluteString, "https://www.google.fr")
            }
        }
    }
}