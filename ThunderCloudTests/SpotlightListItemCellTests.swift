//
//  SpotlightListItemCellTests.swift
//  ThunderCloudTests
//
//  Created by Simon Mitchell on 27/08/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import XCTest
@testable import ThunderCloud

class SpotlightListItemCellTests: XCTestCase {
    
    var collectionView: UICollectionView?
    
    override func setUp() {
        
        collectionView = UICollectionView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 320,
                height: 240
            ),
            collectionViewLayout: carouselLayout
        )
    }
    
    let carouselLayout = CarouselCollectionViewLayout()
    
    func testItemSizeIsCorrect() {
        XCTAssertEqual(carouselLayout.itemSize, CGSize(width: 236.0, height: 240.0))
    }
    
    func testScrollsCorrectlyToFirstCellWithZeroOffsetZeroVelocity() {
        
        let targetOffset = carouselLayout.targetContentOffset(forProposedContentOffset: .zero, withScrollingVelocity: CGPoint(x: 0, y: 0))
        XCTAssertEqual(.zero, targetOffset)
    }
    
    func testFlickingToNextPageOccursOnlyWhenVelocityAboveLimit() {
        
        let targetOffset = carouselLayout.targetContentOffset(forProposedContentOffset: .zero, withScrollingVelocity: CGPoint(x: 4.9, y: 0))
        XCTAssertEqual(.zero, targetOffset)
    }
    
    func testFlickingToNextPageOccursWhenVelocityAboveLimit() {
        
        let targetOffset = carouselLayout.targetContentOffset(forProposedContentOffset: .zero, withScrollingVelocity: CGPoint(x: 5.1, y: 0))
        XCTAssertEqual(CGPoint(x: 492, y: 0), targetOffset)
    }
    
    func testFlicksMultiplePagesWhenVelocityHighEnough() {
        
        let targetOffset = carouselLayout.targetContentOffset(forProposedContentOffset: .zero, withScrollingVelocity: CGPoint(x: 10, y: 0))
        XCTAssertEqual(CGPoint(x: 738, y: 0), targetOffset)
    }
    
    func testNegativeVelocityFlicksToPreviousPage() {
        
        let targetOffset = carouselLayout.targetContentOffset(forProposedContentOffset: CGPoint(x: 800, y: 0), withScrollingVelocity: CGPoint(x: -5, y: 0))
        XCTAssertEqual(CGPoint(x: -492.0, y: 0), targetOffset)
    }
}
