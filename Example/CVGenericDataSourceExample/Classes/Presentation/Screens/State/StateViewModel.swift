//
//  StateViewModel.swift
//  CVGenericDataSourceExample
//
//  Created by Stephan Schulz on 11.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import Foundation
import CVGenericDataSource

class StateViewModel {

    // MARK: - Constants

    let coordinator: StateCoordinator

    // MARK: - Variables
    
    var dataSource: CVDataSource<CVSection<SynchronizationContent>,
    CVCellFactory<SynchronizationContent, SynchronizationCell>,
    CVSupplementaryViewFactory<UICollectionReusableView>,
    CVStateFactory<StateEmptyCell, StateLoadingCell>>?
    
    // MARK: - Variables <Private>

    private var _index = 0
    private var _previous_delay: delay_result?

    // MARK: - Life Cycle

    init(coordinator: StateCoordinator) {
        self.coordinator = coordinator
        
        setupDataSource()
    }

    func dispose() {
        coordinator.finish()
    }
    
    // MARK: - DataSource
    
    func setupDataSource() {
        dataSource = CVDataSource(
            sections: [],
            cellFactory:
                CVCellFactory<SynchronizationContent, SynchronizationCell>([
                    .setup(setupCell),
            ]),
            stateFactory:
                CVStateFactory<StateEmptyCell, StateLoadingCell>(),
            options: [
                .load(loadData),
                .insets(Interface.state.sectionInset)
            ]
        )
        dataSource?.load()
    }
    
    func setupCell(cell: SynchronizationCell, item: SynchronizationContent?, indexPath: IndexPath) {
        cell.label.text = "Content"
    }
    
    func loadData(section: Int, offset: Int, result: @escaping ([SynchronizationContent], CVDataSourceOperation) -> Void) {
        _previous_delay?(true)
        _previous_delay = delay(1) {
            self._index += 1
        
            result(self._index % 2 != 0 ? [SynchronizationContent()] : [], .synchronize)
        }
    }
    
    // MARK: - Actions
    
    func reload() {
        dataSource?.reload()
    }
}
