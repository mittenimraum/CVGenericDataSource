//
//  CVGenericDataSourceTests.swift
//  CVGenericDataSource
//
//  Created by Stephan Schulz on 12.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import XCTest
@testable import CVGenericDataSource

class CVGenericDataSourceTests: DefaultTestCase {
    
    // MARK: - Tests
    
    func test_thatDataSource_createsSectionAutomatically_afterLoad() {
        
        // Given
        let items = [Content(0), Content(1), Content(2), Content(3)]
            
        setupDataSource([], [
            .load { (section, offset, result) in
                result(items, .insert)
            }
        ])
        
        // Then
        XCTAssertEqual(dataSource.numberOfSections(), 0)
        
        // When
        dataSource.load()
        
        // Then
        XCTAssertEqual(dataSource.numberOfSections(), 1)
        XCTAssertEqual(dataSource.sections[0].items.count, 4)
    }
    
    func test_thatDataSource_fillsMultipleSectionsWithItems_afterLoad() {
        
        // Given
        let items = [Content(0), Content(1), Content(2), Content(3)]
        
        setupDataSource([Section(), Section(), Section()], [
            .load { (section, offset, result) in
                result(items, .insert)
            }
        ])
        
        // When
        dataSource.load()
        
        // Then
        XCTAssertEqual(dataSource.numberOfSections(), 3)
        XCTAssertEqual(dataSource.sections[0].items.count, 4)
        XCTAssertEqual(dataSource.sections[1].items.count, 4)
        XCTAssertEqual(dataSource.sections[2].items.count, 4)
    }
    
    func test_thatDataSource_clearsAllSections() {
        
        // Given
        let items = [Content(0), Content(1), Content(2), Content(3)]
        
        // When
        setupDataSource([Section(items), Section(items), Section(items)])
        
        // Then
        XCTAssertEqual(dataSource.numberOfSections(), 3)
        XCTAssertEqual(dataSource.sections[0].items.count, 4)
        XCTAssertEqual(dataSource.sections[1].items.count, 4)
        XCTAssertEqual(dataSource.sections[2].items.count, 4)
        
        // When
        dataSource.clear()
        
        // Then
        XCTAssertEqual(dataSource.numberOfSections(), 0)
    }
    
    func test_thatDataSource_clearsAllSections_and_loadsNewSection_afterReload() {
        
        // Given
        let items = [Content(0), Content(1), Content(2), Content(3)]
        
        // When
        setupDataSource([Section(items), Section(items), Section(items)], [
            .load { (section, offset, result) in
                result(items, .insert)
            }
        ])
        
        // Then
        XCTAssertEqual(dataSource.numberOfSections(), 3)
        XCTAssertEqual(dataSource.sections[0].items.count, 4)
        XCTAssertEqual(dataSource.sections[1].items.count, 4)
        XCTAssertEqual(dataSource.sections[2].items.count, 4)
        
        // When
        dataSource.reload()
        
        // Then
        XCTAssertEqual(dataSource.numberOfSections(), 1)
        XCTAssertEqual(dataSource.sections[0].items.count, 4)
    }
    
    func test_thatDataSource_clearsAllSections_and_loadsNewSections_afterReload() {
        
        // Given
        let items = [Content(0), Content(1), Content(2), Content(3)]
        
        // When
        setupDataSource([Section(items), Section(items), Section(items)], [
            .load { (section, offset, result) in
                result(items, .insert)
            }
        ])
        
        // Then
        XCTAssertEqual(dataSource.numberOfSections(), 3)
        XCTAssertEqual(dataSource.sections[0].items.count, 4)
        XCTAssertEqual(dataSource.sections[1].items.count, 4)
        XCTAssertEqual(dataSource.sections[2].items.count, 4)
        
        // When
        dataSource.reload(newSections: [Section(), Section(), Section()])
        
        // Then
        XCTAssertEqual(dataSource.numberOfSections(), 3)
        XCTAssertEqual(dataSource.sections[0].items.count, 4)
        XCTAssertEqual(dataSource.sections[1].items.count, 4)
        XCTAssertEqual(dataSource.sections[2].items.count, 4)
    }
    
    func test_thatDataSource_synchronizesOneSection_afterSynchronize() {
        
        // Given
        let old = [Content(0), Content(1), Content(2), Content(3)]
        let new = [Content(0), Content(1), Content(5), Content(6)]
        
        // When
        setupDataSource([Section(old)])
        
        // When
        dataSource.synchronize(items: new, inSection: 0)
        
        // Then
        XCTAssertEqual(dataSource.numberOfSections(), 1)
        XCTAssertEqual(dataSource.numberOfItems(inSection: 0), 4)
        XCTAssertTrue(dataSource.sections[0].items.contains(old[0]))
        XCTAssertTrue(dataSource.sections[0].items.contains(old[1]))
        XCTAssertFalse(dataSource.sections[0].items.contains(old[2]))
        XCTAssertFalse(dataSource.sections[0].items.contains(old[3]))
        XCTAssertTrue(dataSource.sections[0].items.contains(new[2]))
        XCTAssertTrue(dataSource.sections[0].items.contains(new[3]))
    }
    
    func test_thatDataSource_synchronizesAllSections_afterSynchronize() {
        
        // Given
        let old = [Content(0), Content(1), Content(2), Content(3)]
        let new = [Content(0), Content(1), Content(5), Content(6)]
        
        // When
        setupDataSource([Section(old)])
        
        // When
        dataSource.synchronize(items: new, inSection: 0)
        
        // Then
        XCTAssertEqual(dataSource.numberOfSections(), 1)
        XCTAssertEqual(dataSource.numberOfItems(inSection: 0), 4)
        XCTAssertTrue(dataSource.sections[0].items.contains(old[0]))
        XCTAssertTrue(dataSource.sections[0].items.contains(old[1]))
        XCTAssertFalse(dataSource.sections[0].items.contains(old[2]))
        XCTAssertFalse(dataSource.sections[0].items.contains(old[3]))
        XCTAssertTrue(dataSource.sections[0].items.contains(new[2]))
        XCTAssertTrue(dataSource.sections[0].items.contains(new[3]))
    }
    
    func test_thatDataSource_showsEmptyState_ifEmpty() {
        
        // Given
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        setupDataSource()
        
        // Then
        XCTAssertEqual(dataSource.state, CVDataSourceState.inited)
        
        // When
        dataSource.bind(collectionView: collectionView)
        
        // Then
        XCTAssertEqual(dataSource.state, CVDataSourceState.empty)
    }
    
    func test_thatDataSource_showsEmptyState_ifEmpty_afterLoad() {
        
        // Given
        setupDataSource([], [
            .load { (section, offset, result) in
                result([], .insert)
            }
        ])
        dataSource.bind(collectionView: setupCollectionView())
        
        // When
        dataSource.load()
        
        // Then
        XCTAssertEqual(dataSource.state, CVDataSourceState.empty)
        XCTAssertTrue(dataSource.collectionView?.cellForItem(at: IndexPath(row: 0, section: 0)) is EmptyCell)
    }
    
    func test_thatDataSource_showsLoadingState() {
        
        // Given
        setupDataSource([], [
            .load { (section, offset, result) in
             
            }
        ])
        dataSource.bind(collectionView: setupCollectionView())
        
        // When
        dataSource.load()
        
        // Then
        XCTAssertEqual(dataSource.state, CVDataSourceState.loading)
        XCTAssertTrue(dataSource.collectionView?.cellForItem(at: IndexPath(row: 0, section: 0)) is LoadingCell)
    }
    
    func test_thatDataSource_returnsNil_whenDataFromInvalidSection_areRequested() {
        
        // Given
        let sectionA = CVSection(items: Content(0), Content(1))
        let sectionB = CVSection(items: Content(2), Content(3))
        
        setupDataSource([sectionA, sectionB])
        
        // When
        let requestedItem = dataSource.item(atRow: 0, inSection: 2)
        
        // Then
        XCTAssertNil(requestedItem, "The requested section shouldn't exist")
    }
    
    func test_thatDataSource_insertsExpectedData_atIndexPath() {
        
        // Given
        let sectionA = CVSection(items: Content(0), Content(1))
        let sectionB = CVSection(items: Content(2), Content(3))
        
        setupDataSource([sectionA, sectionB])

        // When
        let newItem = Content(4)
        dataSource.insert(item: newItem, at: IndexPath(item: 2, section: 1))
        
        let sectionItems = dataSource.items(inSection: 1)
        let insertedIndex = sectionItems?.index(of: newItem)
        
        // Then
        XCTAssertEqual(insertedIndex, 2, "New item should be at the requested index")
    }
    
    func test_thatDataSource_appendsExpectedData_inSection() {
        
        // Given
        let sectionA = CVSection(items: Content(0), Content(1))
        let sectionB = CVSection(items: Content(2), Content(3))
        
        setupDataSource([sectionA, sectionB])
        
        // When
        let newItem = Content(4)
        let section = 1
        dataSource.append(item: newItem, inSection: section)
        
        let sectionItems = dataSource.items(inSection: section)
        let insertedIndex = sectionItems?.index(of: newItem)
        
        // Then
        XCTAssertEqual(insertedIndex, sectionItems!.count - 1, "New item should be at the requested index")
        XCTAssertEqual(newItem, sectionItems?.last, "New item should be at the end of the requested section")
    }
    
    func test_thatDataSource_doesNotInsertData_atOutOfBounds_Section() {
        
        // Given
        let sectionA = CVSection(items: Content(0), Content(1))
        let sectionB = CVSection(items: Content(2), Content(3))
        
        setupDataSource([sectionA, sectionB])
        
        // When
        let newItem = Content(5)
        dataSource.insert(item: newItem, at: IndexPath(item: 1, section: 2))
        
        let sectionItems = dataSource.items(inSection: 2)
        
        // Then
        XCTAssertNil(sectionItems, "The requested section doesn't exist")
    }
    
    func test_thatDataSource_doesNotInsertData_atOutOfBounds_Row() {
        
        // Given
        let sectionA = CVSection(items: Content(0), Content(1))
        let sectionB = CVSection(items: Content(2), Content(3))

        setupDataSource([sectionA, sectionB])

        // When
        let newItem = Content(5)
        dataSource.insert(item: newItem, at: IndexPath(item: 4, section: 1))
        
        // Then
        XCTAssertFalse(dataSource.items(inSection: 1)!.contains(newItem), "The item shouldn't be added")
    }
    
    func test_thatDataSource_removesExpectedData_atIndexPath() {
        
        // Given
        let sectionA = CVSection(items: Content(0), Content(1))
        let sectionB = CVSection(items: Content(2), Content(3))
        
        setupDataSource([sectionA, sectionB])
        
        // When
        let itemToRemove = dataSource.remove(atIndexPath: IndexPath(item: 1, section: 0))
        
        // Then
        XCTAssertNotNil(itemToRemove)
        XCTAssertEqual(dataSource.sections.count, 2)
        XCTAssertEqual(dataSource.items(inSection: 0)?.count, 1)
        XCTAssertEqual(dataSource.items(inSection: 1)?.count, 2)
        XCTAssertEqual(sectionA.count, 2, "Original section should not be changed")
    }
    
    func test_thatDataSource_doesNotRemoveData_fromInvalid_SectionOrRow() {
        
        // Given
        let sectionA = CVSection(items: Content(0), Content(1))
        let sectionB = CVSection(items: Content(2), Content(3))

        setupDataSource([sectionA, sectionB])
        
        // When
        let invalidIndex = 2
        let itemToRemoveA = dataSource.remove(atRow: 0, inSection: invalidIndex)
        let itemToRemoveB = dataSource.remove(atRow: invalidIndex, inSection: 0)
        
        // Then
        XCTAssertNil(itemToRemoveA, "The section \(invalidIndex) doesn't exist")
        XCTAssertNil(itemToRemoveB, "There should be no item in row \(invalidIndex)")
    }
    
    func test_thatDataSource_returnsItem_atIndexPath() {
        
        // Given
        let model = Content(6)
        let sectionA = CVSection(items: Content(0), Content(1))
        let sectionB = CVSection(items: Content(2), Content(3))
        let sectionC = CVSection(items: Content(4), Content(5), model)

        setupDataSource([sectionA, sectionB, sectionC])
        
        // When
        let item = dataSource.item(atIndexPath: IndexPath(item: 2, section: 2))
        
        // Then
        XCTAssertEqual(item, model)
    }
    
    func test_thatDataSource_usesShouldLoadMoreOption() {
        
        // Given
        let items = [Content(0), Content(1), Content(2), Content(3)]
        let shouldLoadMoreExpectation = expectation(description: "test_thatDataSource_executesShouldLoadMoreOption")
        var shouldLoadMore = false
        
        setupDataSource([], [
            .load { (section, offset, result) in
                result(items, .insert)
            },
            .loadMoreDelay {
                0
            },
            .shouldLoadMore {
                shouldLoadMore = true
                shouldLoadMoreExpectation.fulfill()
                
                return true
            }
        ])
        dataSource.bind(collectionView: setupCollectionView())
        
        // When
        dataSource.load()
        
        // Then
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertTrue(shouldLoadMore)
        }
    }
    
    func test_thatDataSource_usesLoadMoreDelayOption() {
        
        // Given
        let items = [Content(0), Content(1), Content(2), Content(3)]
        let loadMoreDelayExpectation = expectation(description: "test_thatDataSource_usesLoadMoreDelay")
        var loadMoreDelayUsed = false
        
        setupDataSource([], [
            .load { (section, offset, result) in
                result(items, .insert)
            },
            .loadMoreDelay {
                loadMoreDelayUsed = true
                loadMoreDelayExpectation.fulfill()
                
                return 0
            },
            .shouldLoadMore {
                return true
            }
        ])
        dataSource.bind(collectionView: setupCollectionView())
        
        // When
        dataSource.load()
        
        // Then
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertTrue(loadMoreDelayUsed)
        }
    }
    
    func test_thatDataSource_usesLoadMoreDistanceOption() {
        
        // Given
        let items = [Content(0), Content(1), Content(2), Content(3)]
        let loadMoreDistanceExpectation = expectation(description: "test_thatDataSource_usesLoadMoreDistanceOption")
        var loadMoreDistsanceUsed = false
        
        setupDataSource([], [
            .load { (section, offset, result) in
                result(items, .insert)
            },
            .loadMoreDelay {
                return 0
            },
            .loadMoreDistance { _ in
                loadMoreDistsanceUsed = true
                loadMoreDistanceExpectation.fulfill()
                
                return 0
            },
            .shouldLoadMore {
                true
            }
        ])
        dataSource.bind(collectionView: setupCollectionView())
        
        // When
        dataSource.load()
        
        // Then
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertTrue(loadMoreDistsanceUsed)
        }
    }
    
    func test_thatDataSource_usesShouldShowSectionOption() {
        
        // Given
        var shouldShowSection = false
        
        setupDataSource([Section([Content()])], [
            .shouldShowSection { section in
                shouldShowSection = true
                
                return true
            }
        ])
        dataSource.bind(collectionView: setupCollectionView())
        
        // Then
        XCTAssertTrue(shouldShowSection)
    }
    
    func test_thatDataSource_usesAppearanceOptions() {
        
        // Given
        let collectionView = setupCollectionView()
        let collectionViewLayout = collectionView.collectionViewLayout
        let insets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        
        setupDataSource([Section([Content()])], [
            .lineSpacing(1),
            .cellSpacing(1),
            .insets(insets)
        ])
        dataSource.bind(collectionView: collectionView)
        
        // Then
        guard let bridge = dataSource.collectionView?.delegate as? CVDataSourceBridge else {
            XCTFail()
            
            return
        }
        XCTAssertEqual(bridge.collectionView(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAtIndex: 0), 1)
        XCTAssertEqual(bridge.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAtIndex: 0), 1)
        XCTAssertEqual(bridge.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAtIndex: 0), insets)
    }
    
    func test_thatDataSource_usesSectionInsetsOption() {
        
        // Given
        let collectionView = setupCollectionView()
        let collectionViewLayout = collectionView.collectionViewLayout
        let insets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        
        setupDataSource([Section([Content()])], [
            .sectionInsets { _ in
                insets
            }
        ])
        dataSource.bind(collectionView: collectionView)
        
        // Then
        guard let bridge = dataSource.collectionView?.delegate as? CVDataSourceBridge else {
            XCTFail()
            
            return
        }
        XCTAssertEqual(bridge.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAtIndex: 0), insets)
    }
    
    func test_thatDataSource_usesPrefetchOption() {
        
        // Given
        let collectionView = setupCollectionView()
        var didUsePrefetch = false
        
        setupDataSource([Section([Content()])], [
            .prefetch { (section, items) in
                didUsePrefetch = true
            }
        ])
        dataSource.bind(collectionView: collectionView)
        
        // When
        guard let bridge = dataSource.collectionView?.delegate as? CVDataSourceBridge else {
            XCTFail()
            
            return
        }
        bridge.collectionView(collectionView, prefetchItemsAt: [IndexPath(row: 0, section: 0)])
        
        // Then
        XCTAssertTrue(didUsePrefetch)
    }
    
    func test_thatDataSource_usesCancelPrefetchOption() {
        
        // Given
        let collectionView = setupCollectionView()
        var didUseCancelPrefetch = false
        
        setupDataSource([Section([Content()])], [
            .cancelPrefetch { (section, items) in
                didUseCancelPrefetch = true
            }
        ])
        dataSource.bind(collectionView: collectionView)
        
        // When
        guard let bridge = dataSource.collectionView?.delegate as? CVDataSourceBridge else {
            XCTFail()
            
            return
        }
        bridge.collectionView(collectionView, cancelPrefetchingForItemsAt: [IndexPath(row: 0, section: 0)])
        
        // Then
        XCTAssertTrue(didUseCancelPrefetch)
    }
    
    func test_thatDataSource_usesDidLoadOption() {
        
        // Given
        let items = [Content(0), Content(1), Content(2), Content(3)]
        var didLoad = false
        var didLoadSection = -1
        var didLoadOffset = -1
        var didLoadOffsetBefore = -1
        var didLoadItems = [Content]()
        
        setupDataSource([], [
            .load { (section, offset, result) in
                result(items, .insert)
            },
            .didLoad { (section, offset, offsetBefore, items) in
                
                didLoad = true
                didLoadSection = section
                didLoadOffset = offset
                didLoadOffsetBefore = offsetBefore
                didLoadItems = items
            }
        ])
        dataSource.bind(collectionView: setupCollectionView())
        
        // When
        dataSource.load()
        
        // Then
        XCTAssertTrue(didLoad)
        XCTAssertEqual(didLoadSection, 0)
        XCTAssertEqual(didLoadOffset, 4)
        XCTAssertEqual(didLoadOffsetBefore, 0)
        XCTAssertEqual(didLoadItems, items)
    }
    
    func test_thatDataSource_usesDidPerformUpdatesOption() {
        
        // Given
        let items = [Content(0), Content(1), Content(2), Content(3)]
        let didPerformUpdadtesExpectation = expectation(description: "test_thatDataSource_usesDidPerformUpdatesOption")
        var didPerformUpdates = false
        
        setupDataSource([], [
            .load { (section, offset, result) in
                result(items, .insert)
            },
            .didPerformUpdates {
                didPerformUpdates = true
                didPerformUpdadtesExpectation.fulfill()
            }
        ])
        dataSource.bind(collectionView: setupCollectionView())
        
        // When
        dataSource.load()
        
        // Then
        waitForExpectations(timeout: 10) { (error) in
            XCTAssertTrue(didPerformUpdates)
        }
    }
    
    func test_thatDataSource_usesShouldShowStateOption_forEmptyState() {
        
        // Given
        setupDataSource([], [
            .shouldShowState { state in
                switch state {
                case .empty:
                    return false
                default:
                    return true
                }
            }
        ])
        
        // When
        dataSource.bind(collectionView: setupCollectionView())
        
        // Then
        XCTAssertEqual(dataSource.collectionView?.numberOfSections, 0)
    }
    
    func test_thatDataSource_usesShouldShowStateOption_forLoadingState() {
        
        // Given
        setupDataSource([], [
            .shouldShowState { state in
                switch state {
                case .loading:
                    return false
                default:
                    return true
                }
            }
        ])
        dataSource.bind(collectionView: setupCollectionView())
        
        // When
        dataSource.load()
        
        // Then
        XCTAssertTrue(dataSource.collectionView?.cellForItem(at: IndexPath(row: 0, section: 0)) is EmptyCell)
    }
    
    func test_thatDataSource_returnsExpectedData_forCell() {
        
        // Given
        let item = Content(1)
        var setupCell: UICollectionViewCell?
        var setupItem: Content?
        var setupIndexPath: IndexPath?
        
        // When
        setupDataSource([Section([item])], nil, [
            .setup { (cell, item, indexPath) in
                setupCell = cell
                setupItem = item
                setupIndexPath = indexPath
            }
        ])
        dataSource.bind(collectionView: setupCollectionView())
        
        // Then
        XCTAssertNotNil(setupCell)
        XCTAssertNotNil(setupItem)
        XCTAssertNotNil(setupIndexPath)
        XCTAssertTrue(setupCell is ContentCell)
        XCTAssertTrue(setupItem == item)
        XCTAssertEqual(setupIndexPath?.row, 0)
        XCTAssertEqual(setupIndexPath?.section, 0)
    }
    
    func test_thatDataSource_returnsExpectedData_forSupplementaryView() {
        
        // Given
        let item = Content(1)
        var setupView: UICollectionReusableView?
        var setupType: CVSupplementaryViewType?
        var setupSection: Int?
        
        // When
        setupDataSource([Section([item])], nil, nil, [
            .setup { (type, view, section) in
                setupView = view
                setupType = type
                setupSection = section
            }
        ])
        dataSource.bind(collectionView: setupCollectionView())
        
        // Then
        XCTAssertNotNil(setupView)
        XCTAssertNotNil(setupType)
        XCTAssertNotNil(setupSection)
        XCTAssertTrue(setupView is SupplementaryView)
        XCTAssertEqual(setupSection, 0)
        XCTAssertEqual(setupType, CVSupplementaryViewType.header)
    }
}
