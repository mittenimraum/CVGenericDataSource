//
//  CVGenericDataSourceSectionTests.swift
//  CVGenericDataSource
//
//  Created by Stephan Schulz on 24.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import XCTest
@testable import CVGenericDataSource

class CVGenericDataSourceSectionTests: DefaultTestCase {

    func test_thatSection_usesInsetsOption() {
        
        // Given
        let collectionView = setupCollectionView()
        let collectionViewLayout = collectionView.collectionViewLayout
        let insets1 = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        let insets2 = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        
        setupDataSource([
            Section([Content()], [
                .insets(insets1)
            ]),
            Section([Content()], [
                .insets(insets2)
            ])
        ])
        dataSource.bind(collectionView: collectionView)
        
        // Then
        guard let bridge = dataSource.collectionView?.delegate as? CVDataSourceBridge else {
            XCTFail()
            
            return
        }
        XCTAssertEqual(bridge.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAtIndex: 0), insets1)
        XCTAssertEqual(bridge.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAtIndex: 1), insets2)
    }
    
    func test_thatSection_usesSpacingOptions() {
        
        // Given
        let collectionView = setupCollectionView()
        let collectionViewLayout = collectionView.collectionViewLayout
        
        setupDataSource([
            Section([Content()], [
                .lineSpacing(1),
                .cellSpacing(1)
            ]),
            Section([Content()], [
                .lineSpacing(2),
                .cellSpacing(2)
            ])
        ])
        dataSource.bind(collectionView: collectionView)
        
        // Then
        guard let bridge = dataSource.collectionView?.delegate as? CVDataSourceBridge else {
            XCTFail()
            
            return
        }
        XCTAssertEqual(bridge.collectionView(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAtIndex: 0), 1)
        XCTAssertEqual(bridge.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAtIndex: 0), 1)
        XCTAssertEqual(bridge.collectionView(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAtIndex: 1), 2)
        XCTAssertEqual(bridge.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAtIndex: 1), 2)
    }
    
    func test_thatSection_usesHeaderShouldAppearOption() {
        
        // Given
        let collectionView = setupCollectionView()
        let collectionViewLayout = collectionView.collectionViewLayout
        
        setupDataSource([
            Section([Content()], [
                .headerShouldAppear(true)
            ]),
            Section([Content()], [
                .headerShouldAppear(false)
            ])
        ])
        dataSource.bind(collectionView: collectionView)
        
        // Then
        guard let bridge = dataSource.collectionView?.delegate as? CVDataSourceBridge else {
            XCTFail()
            
            return
        }
        XCTAssertNotEqual(bridge.collectionView(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: 0), CGSize.epsilon)
        XCTAssertEqual(bridge.collectionView(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: 1), CGSize.epsilon)
    }
    
    func test_thatSection_usesFooterShouldAppearOption() {
        
        // Given
        let collectionView = setupCollectionView()
        let collectionViewLayout = collectionView.collectionViewLayout
        
        setupDataSource([
            Section([Content()], [
                .footerShouldAppear(true)
            ]),
            Section([Content()], [
                .footerShouldAppear(false)
            ])
        ])
        dataSource.bind(collectionView: collectionView)
        
        // Then
        guard let bridge = dataSource.collectionView?.delegate as? CVDataSourceBridge else {
            XCTFail()
            
            return
        }
        XCTAssertNotEqual(bridge.collectionView(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: 0), CGSize.epsilon)
        XCTAssertEqual(bridge.collectionView(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: 1), CGSize.epsilon)
    }
    
    func test_thatSection_initializes() {
        
        // Given
        let item1 = Content(0)
        let item2 = Content(1)
        let item3 = Content(2)
        
        // When
        let sectionA = Section(items: item1, item2, item3, headerTitle: "Header")
        let sectionB = Section([item1, item2, item3], footerTitle: "Footer")
        
        // Then
        XCTAssertEqual(sectionA.items, sectionB.items, "Section items should be equal")
        XCTAssertEqual(sectionA.count, 3)
        XCTAssertEqual(sectionA.headerTitle, "Header")
        XCTAssertNil(sectionA.footerTitle)
        XCTAssertEqual(sectionB.count, 3)
        XCTAssertEqual(sectionB.footerTitle, "Footer")
        XCTAssertNil(sectionB.headerTitle)
    }
    
    func test_thatSection_returnsExpectedDataFromSubscript() {
        
        // Given
        let expectedModel = Content(0)
        let section = Section(items: Content(1), Content(2), expectedModel, Content(3), Content(4))
        
        // When
        let item = section[2]
        
        // Then
        XCTAssertEqual(item, expectedModel, "Model returned from subscript should equal expected model")
    }
    
    func test_thatSection_setsExpectedDataAtSubscript() {
        
        // Given
        var section = Section(items: Content(0), Content(1), Content(2), Content(3))
        let count = section.items.count
        
        // When
        let index = 1
        let expectedModel = Content(4)
        section[index] = expectedModel
        
        // Then
        XCTAssertEqual(section[index], expectedModel, "Model set at subscript should equal expected model")
        XCTAssertEqual(count, section.count, "Section count should remain unchanged")
    }
    
    func test_thatSection_returnsExpectedCount() {
        
        // Given
        let section = Section(items: Content(), Content(), Content(), Content())
        
        // When
        let count = section.count
        
        // Then
        XCTAssertEqual(4, count, "Count should equal expected count")
        XCTAssertEqual(4, section.items.count, "Count should equal expected count")
    }
}
