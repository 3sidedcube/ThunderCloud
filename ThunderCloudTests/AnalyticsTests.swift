//
//  AnalyticsTests.swift
//  ThunderCloudTests
//
//  Created by Simon Mitchell on 27/06/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import XCTest

class AnalyticsTests: XCTestCase {

    func testFirebaseSafeStringReplacesSpacesAndNewLinesWithUnderscore() {
        XCTAssertEqual("Hello World".firebaseSafe, "hello_world")
        XCTAssertEqual("Hello\nWorld".firebaseSafe, "hello_world")
        XCTAssertEqual("Hello\tWorld".firebaseSafe, "hello_world")
        XCTAssertEqual("Hello\rWorld".firebaseSafe, "hello_world")
        XCTAssertEqual("Hello  World".firebaseSafe, "hello_world")
        XCTAssertEqual("Hello  \n\r\tWorld".firebaseSafe, "hello_world")
        XCTAssertEqual("Hello World\nHow\rGoes\tIt".firebaseSafe, "hello_world_how_goes_it")
        
        let scalars = [
            9,
            10,
            11,
            12,
            13,
            32,
            133,
            160,
            5760,
            8192,
            8193,
            8194,
            8195,
            8196,
            8197,
            8198,
            8199,
            8200,
            8201,
            8202,
            8232,
            8233,
            8239,
            8287,
            12288
        ]
        
        scalars.forEach({
            guard let scalar = Unicode.Scalar($0) else { return }
            XCTAssertEqual("Hello\(Character(scalar))World".firebaseSafe, "hello_world")
        })
    }
    
    func testFirebaseSafeStringReplacesSpaceLikeCharactersWithUnderscores() {
        
        XCTAssertEqual("Hello-world".firebaseSafe, "hello_world")
        XCTAssertEqual("Hello–world".firebaseSafe, "hello_world")
        XCTAssertEqual("Hello—world".firebaseSafe, "hello_world")
        XCTAssertEqual("Hello+world".firebaseSafe, "hello_world")
        XCTAssertEqual("Hello.world".firebaseSafe, "hello_world")
    }
    
    func testFirebaseSafeStringTrimsUnallowedCharacters() {
        
        XCTAssertEqual(" Hello world\n".firebaseSafe, "hello_world")
        XCTAssertEqual("%':/\\?,=&!Hello world)@(-.£$+–".firebaseSafe, "hello_world")
    }
    
    func testFirebaseSafeStringResctrictsTo40Characters() {
        XCTAssertEqual("Hello world my name is Simon Mitchell and I come from Poole".firebaseSafe, "hello_world_my_name_is_simon_mitchell_an")
    }
    
    func testFirebaseSafeStringAllowsNumbers() {
        XCTAssertEqual("1 For 27th The Win!".firebaseSafe, "1_for_27th_the_win")
    }
}
