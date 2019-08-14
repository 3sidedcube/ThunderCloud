//
//  ListItemTests.swift
//  ThunderCloudTests
//
//  Created by Ryan Bourne on 08/08/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import XCTest
@testable import ThunderCloud

class ListItemTests: XCTestCase {
    
    private var mockedLanguageController: StormLanguageController {
        let languageController = StormLanguageController()
        
        languageController.languageDictionary = [
            "key1": "value1",
            "key2": "value2",
            "key3": "value3"
        ]
        
        return languageController
    }
    
    /// Enforces that the default properties for the ListItem remain as expected.
    func test_defaultProperties_returnsExpectedResults() {
        // For this test, we do not need to worry about passing a dictionary in.
        // This is because (for now) all items are optional.
        let listItem = ListItem(dictionary: [:])
        
        XCTAssert(listItem.displaySeparators == true)
        XCTAssert(listItem.cellClass == StormTableViewCell.self)
        XCTAssert(listItem.padding == 12.0)
        XCTAssert(listItem.useNibSuperclass == true)
        XCTAssert(listItem.estimatedHeight == nil)
        XCTAssert(listItem.height(constrainedTo: CGSize.zero, in: UITableView(frame: .null)) == nil)
    }
    
    /// Enforces that, when there's no link, the selection style is `.none`.
    func test_selectionStyle_noLink_returnsNone() {
        let listItem = ListItem(dictionary: [:])
        
        XCTAssert(listItem.selectionStyle == UITableViewCell.SelectionStyle.none)
    }
    
    /// Enforces that, when there is a link, the selection style is `.default`.
    func test_selectionStyle_link_returnsDefault() {
        let listItem = ListItem(dictionary: [
            "class": "ListItemView",
            "link": [
                "class": "UriLink",
                "destination": "www.google.com",
                "title": [ "class": "Text", "content": "fai6c" ]
            ]
        ])
        
        XCTAssert(listItem.selectionStyle == UITableViewCell.SelectionStyle.default)
    }
    
    /// Enforces that, when given an empty dictionary, all properties are nil.
    func test_init_emptyDictionary_allPropertiesNil() {
        let listItem = ListItem(dictionary: [:])
        
        XCTAssert(listItem.title == nil)
        XCTAssert(listItem.subtitle == nil)
        XCTAssert(listItem.link == nil)
        XCTAssert(listItem.embeddedLinks == nil)
    }
    
    /// Enforces that, when given a dictionary that is invalid, all properties are nil.
    func test_init_invalidObjects_allPropertiesNil() {
        let dictionary: [AnyHashable: Any] = [
            "class": "ListItemView",
            "embeddedLinks": [
                "class": "UriLink",
                "destination": "test1.example"
            ],
            "link": [
                [
                    "class": "UriLink",
                    "destination": "test1.example"
                ],
                [
                    "class": "UriLink",
                    "destination": "test1.example"
                ]
            ],
            "title": "Yaay a title!",
            "description": "And also a description!"
        ]
        
        let listItem = ListItem(dictionary: dictionary, languageController: mockedLanguageController)
        
        XCTAssert(listItem.title == nil)
        XCTAssert(listItem.subtitle == nil)
        XCTAssert(listItem.link == nil)
        XCTAssert(listItem.embeddedLinks == nil)
    }
    
    /// Enforces that, when given a dictionary that contains valid title & description
    /// but no link objects, the title and description are set.
    func test_init_validObjects_noLinks_applicablePropertiesNonNil() {
        let dictionary: [AnyHashable: Any] = [
            "class": "ListItemView",
            "title": [ "class": "Text", "content": "key1" ],
            "description": [ "class": "Text", "content": "key2" ]
        ]
        
        let listItem = ListItem(dictionary: dictionary, languageController: mockedLanguageController)
        
        XCTAssert(listItem.title == "value1")
        XCTAssert(listItem.subtitle == "value2")
        XCTAssert(listItem.link == nil)
        XCTAssert(listItem.embeddedLinks == nil)
    }
    
    /// Enforces that, when given a dictionary that contains all but embedded links,
    /// the title, description, and link are set.
    func test_init_validObjects_onlyLink_applicablePropertiesNonNil() {
        let dictionary: [AnyHashable: Any] = [
            "class": "ListItemView",
            "link": [
                "class": "UriLink",
                "destination": "test3.example"
            ],
            "title": [ "class": "Text", "content": "key1" ],
            "description": [ "class": "Text", "content": "key2" ]
        ]
        
        let listItem = ListItem(dictionary: dictionary, languageController: mockedLanguageController)
        
        XCTAssert(listItem.title == "value1")
        XCTAssert(listItem.subtitle == "value2")
        XCTAssert(listItem.link?.destination == "test3.example")
        XCTAssert(listItem.embeddedLinks == nil)
    }
    
    /// Enforces that, when given a dictionary that contains all properties, all are set.
    func test_init_allValidObjects_allPropertiesNonNil() {
        let dictionary: [AnyHashable: Any] = [
            "class": "ListItemView",
            "embeddedLinks": [
                [
                    "class": "UriLink",
                    "destination": "test1.example"
                ],
                [
                    "class": "UriLink",
                    "destination": "test2.example",
                ]
            ],
            "link": [
                "class": "UriLink",
                "destination": "test3.example"
            ],
            "title": [ "class": "Text", "content": "key1" ],
            "description": [ "class": "Text", "content": "key2" ]
        ]
        
        let listItem = ListItem(dictionary: dictionary, languageController: mockedLanguageController)
        
        XCTAssert(listItem.title == "value1")
        XCTAssert(listItem.subtitle == "value2")
        XCTAssert(listItem.link?.destination == "test3.example")
        XCTAssert(listItem.embeddedLinks?[0].destination == "test1.example")
        XCTAssert(listItem.embeddedLinks?[1].destination == "test2.example")
    }

    func test_init_withAccessibilityLabel_accessibilityLabelSet() {
        
        let dictionary: [AnyHashable : Any] = [
            "class": "ListItemView",
            "image": [
                "accessibilityLabel": [
                    "class": "Text",
                    "content": "key1"
                ]
            ]
        ]
        
        let listItem = ListItem(dictionary: dictionary, languageController: mockedLanguageController)
        
        XCTAssertEqual(listItem.imageAccessibilityLabel, "value1")
    }
}
