//
//  CVGenericDataSourceBridgeTests.swift
//  CVGenericDataSource
//
//  Created by Stephan Schulz on 24.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import XCTest
@testable import CVGenericDataSource

class CVGenericDataSourceBridgeTests: DefaultTestCase {

    func test_thatBridgedDataSource_implements_collectionViewDataSource() {
        
        // Given
        let collectionView = setupCollectionView()
        let collectionViewLayout = collectionView.collectionViewLayout
        
        setupDataSource([Section([Content()]), Section([Content(), Content()])])
        
        // When
        dataSource.bind(collectionView: collectionView)
        
        // Then
        guard let bridge = dataSource.collectionView?.dataSource as? CVDataSourceBridge else {
            XCTFail()
            
            return
        }
        XCTAssertNotNil(bridge.collectionCellForItemAtIndexPath)
        XCTAssertNotNil(bridge.collectionSupplementaryViewAtIndexPath)
        XCTAssertNotNil(bridge.sizeForItemAtIndexPath)
        XCTAssertNotNil(bridge.insetsForSectionAtIndex)
        XCTAssertNotNil(bridge.selectionAtIndexPath)
        XCTAssertNotNil(bridge.sizeForHeaderInSection)
        XCTAssertNotNil(bridge.sizeForFooterInSection)
        XCTAssertNotNil(bridge.willDisplayCell)
        XCTAssertNotNil(bridge.willDisplaySupplementaryView)
        XCTAssertNotNil(bridge.didEndDisplayingCell)
        XCTAssertNotNil(bridge.didEndDisplayingSupplementaryView)
        XCTAssertNotNil(bridge.scrollViewDidScroll)
        XCTAssertNotNil(bridge.lineSpacingForSection)
        XCTAssertNotNil(bridge.cellSpacingForSection)
        XCTAssertNotNil(bridge.prefetchItems)
        XCTAssertNotNil(bridge.cancelPrefetchItems)
        XCTAssertEqual(bridge.numberOfSections(in: collectionView), 2)
        XCTAssertEqual(bridge.numberOfItemsInSection(1), 2)
        XCTAssertNotNil(bridge.collectionCellForItemAtIndexPath?(collectionView, IndexPath(row: 0, section:1)))
        XCTAssertNotNil(bridge.collectionSupplementaryViewAtIndexPath?(collectionView, UICollectionElementKindSectionHeader, IndexPath(row: 0, section:1)))
        XCTAssertNotEqual(bridge.sizeForItemAtIndexPath?(collectionView, collectionViewLayout, IndexPath(row: 0, section:1)), CGSize.zero)
    }
}
