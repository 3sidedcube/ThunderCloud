//
//  LocalisedStringTests.swift
//  ThunderCloudTests
//
//  Created by Simon Mitchell on 13/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import XCTest
@testable import ThunderCloud

class LocalisedStringTests: XCTestCase {

    override func setUp() {
        StormLanguageController.shared.currentLanguage = "en"
        StormLanguageController.shared.languageDictionary = [
            "test_case_standard" : "Hello World",
            "test_only_key": "Hello World",
            "basic_parameter": "Hello {NAME}",
            "basic_parameter_proper": "Hello {NAME.propercase()}",
            "basic_parameter_capitalized": "Hello {NAME.capitalized()}",
            "basic_parameter_uppercased": "Hello {NAME.uppercased()}",
            "basic_parameter_lowercased": "Hello {NAME.lowercased()}",
            "date": "It is {DATE.date(\"%a %d %B %Y at %H:%M\")}",
            "date_uppercased": "It is {DATE.date(\"%a %d %B %Y at %H:%M\").uppercased()}",
            "underline": "This is the link: {LINK.underlined(\"#FFF\", \"2\")}",
            "foregroundcolor": "This is the link: {LINK.foregroundColor(\"#FFF\", \"2\")}",
            "backgroundcolor": "This is the link: {LINK.backgroundColor(\"#FFF\")}",
            "stroke": "This is the link: {LINK.stroke(\"1\", \"#FFF\")}",
            "strikethrough": "This is the link: {LINK.strikeThrough(\"2\", \"#FFF\")}",
            "skew": "This is the link: {LINK.skew(\"1.32\")}",
            "decimal": "This is the link: {LINK.skew(\"1.32\")}",
            "link": "This is the link: {LINK.link(\"https://www.google.co.uk\")}",
            "linkcapitalisedandunderlined": "This is the link {LINK.link(\"https://www.google.co.uk\").capitalised().underlined(\"#FFF\", \"2\")}"
        ]
        LocalisationController.shared.localisationsDictionary = [
            "test_case_standard": [
                "en": "Hello World"
            ],
            "test_only_dictionary": [
                "en": "Hello World"
            ]
        ]
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFallback() {
        XCTAssertEqual("Fallback".localised(with: "fallback"), "Fallback")
    }

    func testLocalises() {
        
        XCTAssertEqual("Test".localised(with: "test_case_standard"), "Hello World")
        XCTAssertEqual("Test".localised(with: "test_only_key"), "Hello World")
        XCTAssertEqual("Test".localised(with: "test_only_dictionary"), "Hello World")
        
        let localised = "Test".localised(with: "test_case_standard")
        XCTAssertEqual(localised.localisationKey, "test_case_standard")
        
        var altLocalised = localised
        XCTAssertEqual(altLocalised.localisationKey, "test_case_standard")
        
        let label = UILabel(frame: .zero)
        label.text = altLocalised
        XCTAssertEqual(label.text?.localisationKey, "test_case_standard")
    }
    
    func testDecimalParamterLocalises() {
        
        let attributedUnderlined = NSAttributedString().localised(with: "skew", paramDictionary: ["LINK": "www.google.co.uk"])
        
        guard let range = attributedUnderlined.string.range(of: "www.google.co.uk") else {
            XCTFail("Couldn't find range of LINK parameter in returned string")
            return
        }
        
        var effectiveRange: NSRange = NSRange(location: 0, length: 0)
        let attributes = attributedUnderlined.attributes(at: 21, effectiveRange: &effectiveRange)
        
        XCTAssertEqual(attributes[.obliqueness] as? Double, 1.32)
    }
    
    func testBasicParameter() {
        
        let localised = "Test".localised(with: "basic_parameter", paramDictionary: ["NAME": "Simon"])
        XCTAssertEqual(localised, "Hello Simon")
    }
    
    func testProperCase() {
        let localised = "Test".localised(with: "basic_parameter_proper", paramDictionary: ["NAME": "simon. welcome to our world!"])
        XCTAssertEqual(localised, "Hello Simon. Welcome to our world!")
    }
    
    func testCapitalized() {
        let localised = "Test".localised(with: "basic_parameter_capitalized", paramDictionary: ["NAME": "simon"])
        XCTAssertEqual(localised, "Hello Simon")
    }
    
    func testUppercased() {
        let localised = "Test".localised(with: "basic_parameter_uppercased", paramDictionary: ["NAME": "simon"])
        XCTAssertEqual(localised, "Hello SIMON")
    }
    
    func testLowercased() {
        let localised = "Test".localised(with: "basic_parameter_lowercased", paramDictionary: ["NAME": "SIMON"])
        XCTAssertEqual(localised, "Hello simon")
    }
    
    func testDate() {
        let date = Date(timeIntervalSince1970: 0)
        let localised = "Test".localised(with: "date", paramDictionary: ["DATE": date])
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        XCTAssertEqual(localised, "It is Thu 01 January 1970 at \(dateFormatter.string(from: date))")
    }
    
    func testDateAndUppercased() {
        let date = Date(timeIntervalSince1970: 0)
        let localised = "Test".localised(with: "date_uppercased", paramDictionary: ["DATE": date])
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        XCTAssertEqual(localised, "It is THU 01 JANUARY 1970 AT \(dateFormatter.string(from: date))")
    }
    
    func testUnderline() {
        
        let underlined = "Test".localised(with: "underline", paramDictionary: ["LINK": "www.google.co.uk"])
        XCTAssertEqual(underlined, "This is the link: www.google.co.uk")
        
        let attributedUnderlined = NSAttributedString().localised(with: "underline", paramDictionary: ["LINK": "www.google.co.uk"])
        XCTAssertEqual(attributedUnderlined.string, "This is the link: www.google.co.uk")
        
        guard let range = attributedUnderlined.string.range(of: "www.google.co.uk") else {
            return
        }
        
        var effectiveRange: NSRange = NSRange(location: 0, length: 0)
        let attributes = attributedUnderlined.attributes(at: 21, effectiveRange: &effectiveRange)
        
        XCTAssertEqual(range, Range(effectiveRange, in: attributedUnderlined.string))
        XCTAssertEqual(attributes[.underlineStyle] as? NSUnderlineStyle, .thick)
        XCTAssertEqual(attributes[.underlineColor] as? UIColor, UIColor(hexString: "FFF"))
    }
    
    func testStrikeThrough() {
        
        let underlined = "Test".localised(with: "strikethrough", paramDictionary: ["LINK": "www.google.co.uk"])
        XCTAssertEqual(underlined, "This is the link: www.google.co.uk")
        
        let attributedUnderlined = NSAttributedString().localised(with: "strikethrough", paramDictionary: ["LINK": "www.google.co.uk"])
        XCTAssertEqual(attributedUnderlined.string, "This is the link: www.google.co.uk")
        
        guard let range = attributedUnderlined.string.range(of: "www.google.co.uk") else {
            return
        }
        
        var effectiveRange: NSRange = NSRange(location: 0, length: 0)
        let attributes = attributedUnderlined.attributes(at: 21, effectiveRange: &effectiveRange)
        
        XCTAssertEqual(range, Range(effectiveRange, in: attributedUnderlined.string))
        XCTAssertEqual(attributes[.strikethroughStyle] as? NSUnderlineStyle, .thick)
        XCTAssertEqual(attributes[.strikethroughColor] as? UIColor, UIColor(hexString: "FFF"))
    }
    
    func testForegroundColor() {
        
        let underlined = "Test".localised(with: "foregroundcolor", paramDictionary: ["LINK": "www.google.co.uk"])
        XCTAssertEqual(underlined, "This is the link: www.google.co.uk")
        
        let attributedUnderlined = NSAttributedString().localised(with: "foregroundcolor", paramDictionary: ["LINK": "www.google.co.uk"])
        XCTAssertEqual(attributedUnderlined.string, "This is the link: www.google.co.uk")
        
        guard let range = attributedUnderlined.string.range(of: "www.google.co.uk") else {
            return
        }
        
        var effectiveRange: NSRange = NSRange(location: 0, length: 0)
        let attributes = attributedUnderlined.attributes(at: 21, effectiveRange: &effectiveRange)
        
        XCTAssertEqual(range, Range(effectiveRange, in: attributedUnderlined.string))
        XCTAssertEqual(attributes[.foregroundColor] as? UIColor, UIColor(hexString: "FFF"))
    }
    
    func testBackgroundColor() {
        
        let underlined = "Test".localised(with: "backgroundcolor", paramDictionary: ["LINK": "www.google.co.uk"])
        XCTAssertEqual(underlined, "This is the link: www.google.co.uk")
        
        let attributedUnderlined = NSAttributedString().localised(with: "backgroundcolor", paramDictionary: ["LINK": "www.google.co.uk"])
        XCTAssertEqual(attributedUnderlined.string, "This is the link: www.google.co.uk")
        
        guard let range = attributedUnderlined.string.range(of: "www.google.co.uk") else {
            return
        }
        
        var effectiveRange: NSRange = NSRange(location: 0, length: 0)
        let attributes = attributedUnderlined.attributes(at: 21, effectiveRange: &effectiveRange)
        
        XCTAssertEqual(range, Range(effectiveRange, in: attributedUnderlined.string))
        XCTAssertEqual(attributes[.backgroundColor] as? UIColor, UIColor(hexString: "FFF"))
    }
    
    func testStroke() {
        
        let underlined = "Test".localised(with: "stroke", paramDictionary: ["LINK": "www.google.co.uk"])
        XCTAssertEqual(underlined, "This is the link: www.google.co.uk")
        
        let attributedUnderlined = NSAttributedString().localised(with: "stroke", paramDictionary: ["LINK": "www.google.co.uk"])
        XCTAssertEqual(attributedUnderlined.string, "This is the link: www.google.co.uk")
        
        guard let range = attributedUnderlined.string.range(of: "www.google.co.uk") else {
            return
        }
        
        var effectiveRange: NSRange = NSRange(location: 0, length: 0)
        let attributes = attributedUnderlined.attributes(at: 21, effectiveRange: &effectiveRange)
        
        XCTAssertEqual(range, Range(effectiveRange, in: attributedUnderlined.string))
        XCTAssertEqual(attributes[.strokeWidth] as? Double, 1)
        XCTAssertEqual(attributes[.strokeColor] as? UIColor, UIColor(hexString: "FFF"))
    }
    
    func testSkew() {
    
        let underlined = "Test".localised(with: "skew", paramDictionary: ["LINK": "www.google.co.uk"])
        XCTAssertEqual(underlined, "This is the link: www.google.co.uk")
        
        let attributedUnderlined = NSAttributedString().localised(with: "skew", paramDictionary: ["LINK": "www.google.co.uk"])
        XCTAssertEqual(attributedUnderlined.string, "This is the link: www.google.co.uk")
        
        guard let range = attributedUnderlined.string.range(of: "www.google.co.uk") else {
            return
        }
        
        var effectiveRange: NSRange = NSRange(location: 0, length: 0)
        let attributes = attributedUnderlined.attributes(at: 21, effectiveRange: &effectiveRange)
        
        XCTAssertEqual(range, Range(effectiveRange, in: attributedUnderlined.string))
        XCTAssertEqual(attributes[.obliqueness] as? Double, 1.32)
    }
    
    func testLink() {
        
        let underlined = "Test".localised(with: "link", paramDictionary: ["LINK": "www.google.co.uk"])
        XCTAssertEqual(underlined, "This is the link: www.google.co.uk")
        
        let attributedUnderlined = NSAttributedString().localised(with: "link", paramDictionary: ["LINK": "www.google.co.uk"])
        XCTAssertEqual(attributedUnderlined.string, "This is the link: www.google.co.uk")
        
        guard let range = attributedUnderlined.string.range(of: "www.google.co.uk") else {
            return
        }
        
        var effectiveRange: NSRange = NSRange(location: 0, length: 0)
        let attributes = attributedUnderlined.attributes(at: 21, effectiveRange: &effectiveRange)
        
        XCTAssertEqual(range, Range(effectiveRange, in: attributedUnderlined.string))
        XCTAssertEqual(attributes[.link] as? URL, URL(string: "https://www.google.co.uk")!)
    }
    
    func testLinkAndCapitaliseAndUnderline() {
        
        let underlined = "Test".localised(with: "linkcapitalisedandunderlined", paramDictionary: ["LINK": "simon"])
        XCTAssertEqual(underlined, "This is the link Simon")
        
        let attributedUnderlined = NSAttributedString().localised(with: "linkcapitalisedandunderlined", paramDictionary: ["LINK": "simon"])
        XCTAssertEqual(attributedUnderlined.string, "This is the link Simon")
        
        guard let range = attributedUnderlined.string.range(of: "www.google.co.uk") else {
            return
        }
        
        var effectiveRange: NSRange = NSRange(location: 0, length: 0)
        let attributes = attributedUnderlined.attributes(at: 21, effectiveRange: &effectiveRange)
        
        XCTAssertEqual(range, Range(effectiveRange, in: attributedUnderlined.string))
        XCTAssertEqual(attributes[.link] as? URL, URL(string: "https://www.google.co.uk")!)
        XCTAssertEqual(attributes[.underlineStyle] as? NSUnderlineStyle, .thick)
        XCTAssertEqual(attributes[.underlineColor] as? UIColor, UIColor(hexString: "#FFF"))
    }
}
