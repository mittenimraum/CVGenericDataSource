//
//  CVGenericDataSourceFactoryTests.swift
//  CVGenericDataSource
//
//  Created by Stephan Schulz on 24.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import XCTest
@testable import CVGenericDataSource

func == (a: CVGenericDataSourceFactoryTests.Content1, b: CVGenericDataSourceFactoryTests.Content1) -> Bool {
    return a.id == b.id
}

func == (a: CVGenericDataSourceFactoryTests.Content2, b: CVGenericDataSourceFactoryTests.Content2) -> Bool {
    return a.id == b.id
}

func == (lhs: CVGenericDataSourceFactoryTests.Content, rhs: CVGenericDataSourceFactoryTests.Content) -> Bool {
    switch (lhs, rhs) {
    case (.type1, .type1):
        return true
    case (.type2, .type2):
        return true
    default:
        return false
    }
}

class CVGenericDataSourceFactoryTests: XCTestCase {
    
    enum Content: Equatable {
        case type1(Content1)
        case type2(Content2)
    }
    
    struct Content1: Equatable {
        
        var id: Int?
        
        init(_ id: Int = 0) {
            self.id = id
        }
    }
    
    struct Content2: Equatable {
        
        var id: Int?
        
        init(_ id: Int = 0) {
            self.id = id
        }
    }
    
    class ContentCell1: CVCell {
        
        override open class var ReuseIdentifier: String {
            return String(describing: ContentCell1.self)
        }
    }
    
    class ContentCell2: CVCell {
        
        override open class var ReuseIdentifier: String {
            return String(describing: ContentCell2.self)
        }
    }
    
    class HeaderView: CVSupplementaryView {
        
        override open class var ReuseIdentifier: String {
            return String(describing: HeaderView.self)
        }
    }
    
    class FooterView: CVSupplementaryView {
        
        override open class var ReuseIdentifier: String {
            return String(describing: FooterView.self)
        }
    }
    
    class CellFactory<Item, View: CVReusableViewProtocol>: CVCellFactory<Item, View> {
        
        let type1: CVCellFactory<Content1, ContentCell1>
        let type2: CVCellFactory<Content2, ContentCell2>
        
        init(type1: CVCellFactory<Content1, ContentCell1>, type2: CVCellFactory<Content2, ContentCell2>, _ options: [CVFactoryOption]? = nil) {
            self.type1 = type1
            self.type2 = type2
            
            super.init(options)
        }
        
        override func viewClass(item: Item?) -> AnyClass {
            guard let item = item as? Content else {
                fatalError()
            }
            switch item {
            case .type1:
                return ContentCell1.self
            case .type2:
                return ContentCell2.self
            }
        }
        
        override func reuseIdentifier(item: Item?) -> String {
            guard let item = item as? Content else {
                fatalError()
            }
            switch item {
            case .type1:
                return ContentCell1.ReuseIdentifier
            case .type2:
                return ContentCell2.ReuseIdentifier
            }
        }
        
        override func nibName(item: Item?) -> String {
            return String()
        }
    }
    
    class SupplementaryViewFactory<View: CVReusableViewProtocol>: CVSupplementaryViewFactory<View> {
        
        let header: CVSupplementaryViewFactory<HeaderView>
        let footer: CVSupplementaryViewFactory<FooterView>
        
        init(header: CVSupplementaryViewFactory<HeaderView>, footer: CVSupplementaryViewFactory<FooterView>, _ options: [CVFactoryOption]? = nil) {
            self.header = header
            self.footer = footer
            
            super.init(.header, options)
        }
        
        override func viewClass(type: CVSupplementaryViewType, inSection section: Int) -> AnyClass {
            switch type {
            case .header:
                return HeaderView.self
            case .footer:
                return FooterView.self
            }
        }
        
        override func reuseIdentifier(type: CVSupplementaryViewType, inSection section: Int) -> String {
            switch type {
            case .header:
                return header.reuseIdentifier(type: type, inSection: section)
            case .footer:
                return footer.reuseIdentifier(type: type, inSection: section)
            }
        }
        
        override func nibName(type: CVSupplementaryViewType, inSection section: Int) -> String {
            return String()
        }
    }

    // MARK: - Aliases
    
    typealias Section = CVSection<Content>
    typealias CellFactory1 = CVCellFactory<Content1, ContentCell1>
    typealias CellFactory2 = CVCellFactory<Content2, ContentCell2>
    typealias CustomCellFactory = CellFactory<Content, UICollectionViewCell>
    typealias CustomCellFactoryOption = CustomCellFactory.CVFactoryOption
    typealias CustomSupplementaryViewFactory = SupplementaryViewFactory<UICollectionReusableView>
    typealias CustomSupplementaryViewFactoryOption = CustomSupplementaryViewFactory.CVFactoryOption
    typealias HeaderViewFactory = CVSupplementaryViewFactory<HeaderView>
    typealias FooterViewFactory = CVSupplementaryViewFactory<FooterView>
    typealias StateFactory = CVStateFactory<DefaultTestCase.EmptyCell, DefaultTestCase.LoadingCell>
    typealias Option = CVDataSource<Section, CustomCellFactory, CustomSupplementaryViewFactory, StateFactory>.CVDataSourceOption
    
    // MARK: - Variables
    
    var dataSource: CVDataSource<Section, CustomCellFactory, CustomSupplementaryViewFactory, StateFactory>!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        super.tearDown()
        
        CVDataSourceCache.shared.clear()
    }
    
    func setupDataSource(_ sections: [Section] = [],
                         _ cellFactoryOptions: [CustomCellFactoryOption]? = nil,
                         _ supplementaryViewOptions: [CustomSupplementaryViewFactoryOption]? = nil) {
        dataSource = CVDataSource(
            sections: sections,
            cellFactory: CustomCellFactory(
                type1: CellFactory1(),
                type2: CellFactory2(),
                cellFactoryOptions
            ),
            supplementaryViewFactory: CustomSupplementaryViewFactory(
                header: HeaderViewFactory(.header),
                footer: FooterViewFactory(.footer),
                supplementaryViewOptions
            ),
            stateFactory: StateFactory()
        )
    }
    
    func setupCollectionView() -> UICollectionView {
        return UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    // MARK: - Tests
    
    func test_thatDataSource_returnsExpectedData_forContentCell1() {
        
        // Given
        let item1 = Content.type1(Content1())
        let item2 = Content.type2(Content2())
        
        var setupCell: UICollectionViewCell?
        var setupItem: Content1?
        var setupIndexPath: IndexPath?
        
        // When
        setupDataSource([Section([item1, item2])], [
            .setup { (cell, item, indexPath) in
                guard let content = item else {
                    XCTFail()
                    
                    return
                }
                switch content {
                case let .type1(value):
                    setupCell = cell
                    setupItem = value
                    setupIndexPath = indexPath
                default:
                    break
                }
            }
        ])
        dataSource.bind(collectionView: setupCollectionView())
        
        // Then
        XCTAssertNotNil(setupCell)
        XCTAssertNotNil(setupItem)
        XCTAssertNotNil(setupIndexPath)
        XCTAssertTrue(setupCell is ContentCell1)
        XCTAssertEqual(setupIndexPath?.row, 0)
        XCTAssertEqual(setupIndexPath?.section, 0)
    }
    
    func test_thatDataSource_returnsExpectedData_forContentCell2() {
        
        // Given
        let item1 = Content.type1(Content1())
        let item2 = Content.type2(Content2())
        
        var setupCell: UICollectionViewCell?
        var setupItem: Content2?
        var setupIndexPath: IndexPath?
        
        // When
        setupDataSource([Section([item1, item2])], [
            .setup { (cell, item, indexPath) in
                guard let content = item else {
                    XCTFail()
                    
                    return
                }
                switch content {
                case let .type2(value):
                    setupCell = cell
                    setupItem = value
                    setupIndexPath = indexPath
                default:
                    break
                }
            }
        ])
        dataSource.bind(collectionView: setupCollectionView())
        
        // Then
        XCTAssertNotNil(setupCell)
        XCTAssertNotNil(setupItem)
        XCTAssertNotNil(setupIndexPath)
        XCTAssertTrue(setupCell is ContentCell2)
        XCTAssertEqual(setupIndexPath?.row, 1)
        XCTAssertEqual(setupIndexPath?.section, 0)
    }
    
    func test_thatDataSource_returnsExpectedData_forHeaderView() {
        
        // Given
        let item1 = Content.type1(Content1())
        let item2 = Content.type2(Content2())
        
        var setupView: UICollectionReusableView?
        var setupType: CVSupplementaryViewType?
        var setupSection: Int?
        
        // When
        setupDataSource([Section([item1, item2])], nil, [
            .setup { (type, view, section) in
                switch type {
                case .header:
                    setupType = type
                    setupView = view
                    setupSection = section
                default:
                    break
                }
            }
        ])
        dataSource.bind(collectionView: setupCollectionView())
        
        // Then
        XCTAssertNotNil(setupType)
        XCTAssertNotNil(setupView)
        XCTAssertNotNil(setupSection)
        XCTAssertTrue(setupView is HeaderView)
        XCTAssertEqual(setupType, CVSupplementaryViewType.header)
        XCTAssertEqual(setupSection, 0)
    }
    
    func test_thatDataSource_returnsExpectedData_forFooterView() {
        
        // Given
        let item1 = Content.type1(Content1())
        let item2 = Content.type2(Content2())
        
        var setupView: UICollectionReusableView?
        var setupType: CVSupplementaryViewType?
        var setupSection: Int?
        
        // When
        setupDataSource([Section([item1, item2])], nil, [
            .setup { (type, view, section) in
                switch type {
                case .footer:
                    setupType = type
                    setupView = view
                    setupSection = section
                default:
                    break
                }
            }
        ])
        dataSource.bind(collectionView: setupCollectionView())
        
        // Then
        XCTAssertNotNil(setupType)
        XCTAssertNotNil(setupView)
        XCTAssertNotNil(setupSection)
        XCTAssertTrue(setupView is FooterView)
        XCTAssertEqual(setupType, CVSupplementaryViewType.footer)
        XCTAssertEqual(setupSection, 0)
    }
}
