//
//  BoundedTests.swift
//  ThunderCloudTests
//
//  Created by Ben Shutt on 16/03/2021.
//  Copyright © 2021 threesidedcube. All rights reserved.
//

import XCTest
@testable import ThunderCloud

/// Test bounding `Comparable` entities
class BoundedTests: XCTestCase {

    func testLowerBound() throws {
        XCTAssertEqual((0).bounded(lower: 0, upper: 1), 0)
        XCTAssertEqual((0).bounded(lower: 0, upper: 2), 0)
        XCTAssertEqual((-1).bounded(lower: -1, upper: 1), -1)
        XCTAssertEqual((-99).bounded(lower: -99, upper: 99), -99)
    }

    func testUpperBound() throws {
        XCTAssertEqual((1).bounded(lower: 0, upper: 1), 1)
        XCTAssertEqual((1).bounded(lower: -1, upper: 1), 1)
        XCTAssertEqual((0).bounded(lower: -1, upper: 0), 0)
    }

    func testInsideBound() throws {
        XCTAssertEqual((0.5).bounded(lower: 0, upper: 1), 0.5)
        XCTAssertEqual((0.2).bounded(lower: 0, upper: 1), 0.2)
        XCTAssertEqual((0.8).bounded(lower: 0, upper: 1), 0.8)
        XCTAssertEqual((0).bounded(lower: -1, upper: 1), 0)
        XCTAssertEqual((120).bounded(lower: 119, upper: 500), 120)
    }

    func testOutsideBound() throws {
        XCTAssertEqual((-1).bounded(lower: 0, upper: 1), 0)
        XCTAssertEqual((2).bounded(lower: 0, upper: 1), 1)
        XCTAssertEqual((-0.1).bounded(lower: 0, upper: 1), 0)
        XCTAssertEqual((1.1).bounded(lower: 0, upper: 1), 1)
        XCTAssertEqual((-2).bounded(lower: -1, upper: 1), -1)
    }
}
