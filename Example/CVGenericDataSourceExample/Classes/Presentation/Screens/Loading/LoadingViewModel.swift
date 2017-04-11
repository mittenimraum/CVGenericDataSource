//
//  LoadingViewModel.swift
//  CVGenericDataSourceExample
//
//  Created by Stephan Schulz on 22.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import Foundation
import CVGenericDataSource

class LoadingViewModel {
    
    // MARK: - Constants
    
    let coordinator: LoadingCoordinator
    
    // MARK: - Variables
    
    var dataSource: CVDataSource<CVSection<SynchronizationContent>,
    CVCellFactory<SynchronizationContent, SynchronizationCell>,
    CVSupplementaryViewFactory<UICollectionReusableView>,
    CVStateFactory<UICollectionViewCell, UICollectionViewCell>>!
    
    // MARK: - Life Cycle
    
    init(coordinator: LoadingCoordinator) {
        self.coordinator = coordinator
        
        setupDataSource()
    }
    
    func dispose() {
        coordinator.finish()
    }
    
    // MARK: - DataSource
    
    func setupDataSource() {
        dataSource = CVDataSource(
            sections: [
                CVSection([], [
                    .insets(Interface.state.sectionInset),
                    .lineSpacing(Interface.general.lineSpacing)
                ]
            )],
            cellFactory:
            CVCellFactory<SynchronizationContent, SynchronizationCell>([
                .setup(setupCell),
                .size(Interface.basic.cellSize)
            ]),
            options: [
                .load(loadData),
                .shouldLoadMore {
                    self.dataSource.items(inSection: 0)!.count < 200
                }
            ]
        )
        dataSource.load()
    }
    
    func setupCell(cell: SynchronizationCell, item: SynchronizationContent?, indexPath: IndexPath) {
        cell.label.text = "Content"
    }
    
    func loadData(section: Int, offset: Int, result: @escaping ([SynchronizationContent], CVDataSourceOperation) -> Void) {
        var items = [SynchronizationContent]()
        
        for _ in 0..<20 {
            items.append(SynchronizationContent())
        }
        result(items, .insert)
    }
}
