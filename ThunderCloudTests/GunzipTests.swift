//
//  GunzipTests.swift
//  ThunderCloudTests
//
//  Created by Simon Mitchell on 07/04/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import XCTest

class GunzipTests: XCTestCase {

    func testGunzip() throws {
        
        guard let url = Bundle(for: GunzipTests.self).url(forResource: "test", withExtension: "tar.gz") else {
            XCTFail("test.tar.gz missing from test bundle")
            return
        }
        
        guard let responseUrl = Bundle(for: GunzipTests.self).url(forResource: "test_ungzipped_base64", withExtension: "txt") else {
            XCTFail("test_ungzipped_base64.txt missing from test bundle")
            return
        }
        
        let destination = FileManager.default.temporaryDirectory.appendingPathComponent("test.tar")
        
        do {
            try gunzip(url, to: destination)
            let ungzippedData = try Data(contentsOf: destination)
            let string = ungzippedData.base64EncodedString()
            let expectedString = try String(contentsOf: responseUrl)
            XCTAssertEqual(string, expectedString)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
