//
//  BasicViewModel.swift
//  CVGenericDataSourceExample
//
//  Created by Stephan Schulz on 11.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import Foundation
import CVGenericDataSource

func == (a: BasicContent, b: BasicContent) -> Bool {
    return a.id == b.id
}

enum BasicIdentifier {
    case custom, synchronization, state, loading
}

struct BasicContent: Equatable {

    // MARK: - Constants

    var id: BasicIdentifier

    // MARK: - Variables

    var text: String?

    // MARK: - Init

    init(_ id: BasicIdentifier, _ text: String? = nil) {
        self.id = id
        self.text = text
    }
}

struct Test {
    
    struct Content {
        
    }
    
}

class BasicViewModel {

    // MARK: - Constants

    let coordinator: Coordinator
    let contents: [BasicContent] = [
        BasicContent(.custom, "Show custom cells example"),
        BasicContent(.synchronization, "Show synchronization example"),
        BasicContent(.state, "Show state example"),
        BasicContent(.loading, "Show progressive loading example")
    ]

    // MARK: - Variables

    var dataSource: CVDataSource<CVSection<BasicContent>,
    CVCellFactory<BasicContent, BasicCell>,
    CVSupplementaryViewFactory<UICollectionReusableView>,
    CVStateFactory<UICollectionViewCell, UICollectionViewCell>>?

    // MARK: - Life Cycle

    init(coordinator: Coordinator) {
        self.coordinator = coordinator

        setupDataSource()
    }

    // MARK: - DataSource

    func setupDataSource() {
        dataSource = CVDataSource(
            sections: [
                CVSection(contents, [
                    .insets(Interface.basic.sectionInsets),
                    .selection(selectCell),
                ]),
            ],
            cellFactory:
                CVCellFactory<BasicContent, BasicCell>([
                    .setup(setupCell),
                    .size(Interface.basic.cellSize)
        ]))
    }

    func setupCell(cell: BasicCell, item: BasicContent?, indexPath: IndexPath) {
        cell.button.setTitle(item?.text, for: .normal)
    }

    func selectCell(item: BasicContent?, _ index: Int) {
        guard let content = item else {
            return
        }
        switch content.id {
        case .custom:
            coordinator.openCustomExample()
        case .synchronization:
            coordinator.openSynchronizationExample()
        case .state:
            coordinator.openStateExample()
        case .loading:
            coordinator.openLoadingExample()
        }
    }
}
