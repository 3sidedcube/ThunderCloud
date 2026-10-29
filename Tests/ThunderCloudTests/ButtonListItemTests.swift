//
//  ButtonListItemTests.swift
//  ThunderCloudTests
//
//  Created by Ryan Bourne on 08/08/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import XCTest
@testable import ThunderCloud

class ButtonListItemTests: XCTestCase {
    
    private var mockedLanguageController: StormLanguageController {
        let languageController = StormLanguageController()
        
        languageController.languageDictionary = [
            "key1": "value1",
            "key2": "value2",
            "key3": "value3",
            "key4": "value4"
        ]
        
        return languageController
    }
    
    /// Enforces that the default properties for the ListItem remain as expected.
    func test_defaultProperties_returnsExpectedResults() {
        // For this test, we do not need to worry about passing a dictionary in.
        // This is because (for now) all items are optional.
        let listItem = ButtonListItem(dictionary: [:])
        
        XCTAssert(listItem.accessoryType == UITableViewCell.AccessoryType.none)
        XCTAssert(listItem.selectionStyle == UITableViewCell.SelectionStyle.none)
    }
    
    /// Enforces that, when given an empty dictionary, all properties are nil.
    func test_init_emptyDictionary_allPropertiesNil() {
        let listItem = ButtonListItem(dictionary: [:])
        
        XCTAssert(listItem.embeddedLinks == nil)
        XCTAssert(listItem.title == nil)
        XCTAssert(listItem.subtitle == nil)
    }
    
    /// Enforces that, when given an invalid dictionary, all properties are nil.
    func test_init_invalidDictionary_allPropertiesNil() {
        let dictionary: [AnyHashable: Any] = [
            "button": [
                "class": "UriLink",
                "destination": "www.google.com",
                "title": [ "class": "Text", "content": "key1" ]
            ],
            "title": "Yaay a title",
            "description": "A description too!"
        ]
        
        let listItem = ButtonListItem(dictionary: dictionary, languageController: mockedLanguageController)
        
        XCTAssert(listItem.embeddedLinks == nil)
        XCTAssert(listItem.title == nil)
        XCTAssert(listItem.subtitle == nil)
    }
    
    /// Enforces that, when given an invalid link, only the title & description are set.
    func test_init_invalidLink_allPropertiesNil() {
        let dictionary: [AnyHashable: Any] = [
            "button": [
                "link": [:]
            ],
            "title": [ "class": "Text", "content": "key2" ],
            "description": [ "class": "Text", "content": "key3" ]
        ]
        
        let listItem = ButtonListItem(dictionary: dictionary, languageController: mockedLanguageController)
        
        XCTAssert(listItem.embeddedLinks == nil)
        XCTAssert(listItem.title == "value2")
        XCTAssert(listItem.subtitle == "value3")
    }
    
    /// Enforces that, when given a link with no title, but the button has a title, the link is given the button's title.
    func test_init_validDictionary_linkHasNoTitle_titleGiven_linkUsesAdditionalTitle() {
        let dictionary: [AnyHashable: Any] = [
            "button": [
                "link": [
                    "class": "UriLink",
                    "destination": "test1.example"
                ],
                "title": [ "class": "Text", "content": "key1" ]
            ],
            "title": [ "class": "Text", "content": "key2" ],
            "description": [ "class": "Text", "content": "key3" ]
        ]
        
        let listItem = ButtonListItem(dictionary: dictionary, languageController: mockedLanguageController)
        
        XCTAssert(listItem.embeddedLinks?.count == 1)
        XCTAssert(listItem.embeddedLinks?.first?.title == "value1")
        XCTAssert(listItem.embeddedLinks?.first?.destination == "test1.example")
        XCTAssert(listItem.title == "value2")
        XCTAssert(listItem.subtitle == "value3")
    }
    
    /// Enforces that, when given a link with a title, and the button has a title, the link's title is used.
    func test_init_validDictionary_linkHasTitle_titleGiven_linkUsesInitialTitle() {
        let dictionary: [AnyHashable: Any] = [
            "button": [
                "link": [
                    "class": "UriLink",
                    "destination": "test1.example",
                    "title": [ "class": "Text", "content": "key1" ]
                ],
                "title": [ "class": "Text", "content": "key4" ]
            ],
            "title": [ "class": "Text", "content": "key2" ],
            "description": [ "class": "Text", "content": "key3" ]
        ]
        
        let listItem = ButtonListItem(dictionary: dictionary, languageController: mockedLanguageController)
        
        XCTAssert(listItem.embeddedLinks?.count == 1)
        XCTAssert(listItem.embeddedLinks?.first?.title == "value1")
        XCTAssert(listItem.embeddedLinks?.first?.destination == "test1.example")
        XCTAssert(listItem.title == "value2")
        XCTAssert(listItem.subtitle == "value3")
    }
    
    /// Enforces that, when there's also embedded links, the button is the first item in the embedded links array.
    func test_init_validDictionary_embeddedLinks_additionalButton_linkIsFirstInEmbeddedLinks() {
        let dictionary: [AnyHashable: Any] = [
            "button": [
                "link": [
                    "class": "UriLink",
                    "destination": "test1.example",
                    "title": [ "class": "Text", "content": "key1" ]
                ],
                "title": [ "class": "Text", "content": "key4" ]
            ],
            "embeddedLinks": [
                [
                    "class": "UriLink",
                    "destination": "test2.example",
                    "title": [ "class": "Text", "content": "key4" ]
                ]
            ],
            "title": [ "class": "Text", "content": "key2" ],
            "description": [ "class": "Text", "content": "key3" ]
        ]
        
        let listItem = ButtonListItem(dictionary: dictionary, languageController: mockedLanguageController)
        
        XCTAssert(listItem.embeddedLinks?.count == 2)
        XCTAssert(listItem.embeddedLinks?.first?.title == "value1")
        XCTAssert(listItem.embeddedLinks?.first?.destination == "test1.example")
        XCTAssert(listItem.embeddedLinks?[1].title == "value4")
        XCTAssert(listItem.embeddedLinks?[1].destination == "test2.example")
        XCTAssert(listItem.title == "value2")
        XCTAssert(listItem.subtitle == "value3")
    }

}
