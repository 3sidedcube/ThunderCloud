//
//  FirebaseAnalyticsTests.swift
//  ThunderCloudTests
//
//  Created by Ryan Bourne on 23/08/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import XCTest
@testable import ThunderCloud

class FirebaseAnalyticsTests: XCTestCase {
    
    func test_callEvent_tell_unknownNumber() {
        let event = Analytics.Event.call(URL(string: "tel://")!)
        
        let firebaseEvent = FirebaseEvent(event)
        
        XCTAssert(firebaseEvent?.event == "call")
        XCTAssert(firebaseEvent?.parameters["number"] as? String == "unknown")
    }

    func test_callEvent_tel_hasCorrectValues() {
        let event = Analytics.Event.call(URL(string: "tel://999")!)
        
        let firebaseEvent = FirebaseEvent(event)
        
        XCTAssert(firebaseEvent?.event == "call")
        XCTAssert(firebaseEvent?.parameters["number"] as? String == "999")
    }
    
    func test_firebase_callEvent_telprompt_hasCorrectValues() {
        let event = Analytics.Event.call(URL(string: "telprompt://999")!)
        
        let firebaseEvent = FirebaseEvent(event)
        
        XCTAssert(firebaseEvent?.event == "call")
        XCTAssert(firebaseEvent?.parameters["number"] as? String == "999")
    }

}
