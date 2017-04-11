//
//  DefaultTestCase.swift
//  CVGenericDataSource
//
//  Created by Stephan Schulz on 24.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import XCTest
@testable import CVGenericDataSource

func == (a: DefaultTestCase.Content, b: DefaultTestCase.Content) -> Bool {
    return a.id == b.id
}

class DefaultTestCase: XCTestCase {
    
    struct Content: Equatable {
        
        // MARK: - Variables
        
        var id: Int?
        
        // MARK: - Init
        
        init(_ id: Int = 0) {
            self.id = id
        }
    }
    
    class LoadingCell: CVCell {
        
        override open class var ReuseIdentifier: String {
            return String(describing: LoadingCell.self)
        }
    }
    
    class EmptyCell: CVCell {
        
        override open class var ReuseIdentifier: String {
            return String(describing: EmptyCell.self)
        }
    }
    
    class ContentCell: CVCell {
        
        override open class var ReuseIdentifier: String {
            return String(describing: ContentCell.self)
        }
    }
    
    class SupplementaryView: CVSupplementaryView {
        
        override open class var ReuseIdentifier: String {
            return String(describing: SupplementaryView.self)
        }
    }
    
    // MARK: - Aliases
    
    typealias Section = CVSection<Content>
    typealias CellFactory = CVCellFactory<Content, ContentCell>
    typealias CellFactoryOption = CellFactory.CVFactoryOption
    typealias SupplementaryViewFactory = CVSupplementaryViewFactory<SupplementaryView>
    typealias SupplementaryViewFactoryOption = SupplementaryViewFactory.CVFactoryOption
    typealias StateFactory = CVStateFactory<EmptyCell, LoadingCell>
    typealias Option = CVDataSource<Section, CellFactory, SupplementaryViewFactory, StateFactory>.CVDataSourceOption
    
    // MARK: - Variables
    
    var dataSource: CVDataSource<Section, CellFactory, SupplementaryViewFactory, StateFactory>!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        super.tearDown()
        
        CVDataSourceCache.shared.clear()
    }
    
    func setupDataSource(_ sections: [Section] = [], _ options: [Option]? = nil, _ cellFactoryOptions: [CellFactoryOption]? = nil, _ supplementaryFactoryOptions: [SupplementaryViewFactoryOption]? = nil) {
        dataSource = CVDataSource(
            sections: sections,
            cellFactory: CellFactory(cellFactoryOptions),
            supplementaryViewFactory: SupplementaryViewFactory(.header, supplementaryFactoryOptions),
            stateFactory: StateFactory(),
            options: options
        )
    }
    
    func setupCollectionView() -> UICollectionView {
        return UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), collectionViewLayout: UICollectionViewFlowLayout())
    }
}
