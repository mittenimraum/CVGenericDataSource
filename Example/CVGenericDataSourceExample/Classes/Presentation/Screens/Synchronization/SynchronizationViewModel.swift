//
//  SynchronizationViewModel.swift
//  CVGenericDataSourceExample
//
//  Created by Stephan Schulz on 11.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import Foundation
import CVGenericDataSource

func == (a: SynchronizationContent, b: SynchronizationContent) -> Bool {
    return a.id == b.id
}

struct SynchronizationContent: Equatable {

    // MARK: - Constants

    var id: Int

    // MARK: - Init

    init(_ id: Int = 0) {
        self.id = id
    }
}

class SynchronizationViewModel {

    // MARK: - Constants

    let coordinator: SynchronizationCoordinator

    // MARK: - Variables

    var dataSource: CVDataSource<CVSection<SynchronizationContent>,
    CVCellFactory<SynchronizationContent, SynchronizationCell>,
    CVSupplementaryViewFactory<CVTitledSupplementaryView>,
    CVStateFactory<UICollectionViewCell, UICollectionViewCell>>!

    // MARK: - Life Cycle

    deinit {
        debugPrint("deinit", self)
    }

    init(coordinator: SynchronizationCoordinator) {
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
                CVSection([SynchronizationContent()]),
                CVSection([SynchronizationContent()]),
                CVSection([SynchronizationContent()]),
                CVSection([SynchronizationContent()]),
            ],
            cellFactory:
                CVCellFactory<SynchronizationContent, SynchronizationCell>([
                    .setup(setupCell),
            ]),
            supplementaryViewFactory:
                CVSupplementaryViewFactory<CVTitledSupplementaryView>(.header, [
                    .setup(setupSectionHeader),
                    .size(Interface.general.sectionSize)
            ]),
            options: [
                .shouldShowSection(shouldShowSection),
                .lineSpacing(Interface.general.lineSpacing),
                .insets(Interface.general.sectionInset)
            ]
        )
    }

    func setupCell(cell: SynchronizationCell, item: SynchronizationContent?, indexPath: IndexPath) {
        guard let content = item else {
            return
        }
        cell.label.text = String(describing: content.id)
    }

    func setupSectionHeader(type: CVSupplementaryViewType, view: CVTitledSupplementaryView, section: Int) {
        view.label.text = String(format: "Section %i", section)
    }

    func shouldShowSection(section: Int) -> Bool {
        return dataSource.numberOfItems(inSection: section) > 0
    }

    // MARK: - Helper

    func random(integer: UInt32) -> Int {
        return Int(arc4random_uniform(integer))
    }

    // MARK: - Actions

    func synchronize() {
        var sections = [CVSection<SynchronizationContent>]()

        for _ in 0..<dataSource.numberOfSections() {
            var items = [SynchronizationContent]()

            for _ in 0..<random(integer: 8) {
                let content = SynchronizationContent(random(integer: 8))

                guard !items.contains(content) else {
                    continue
                }
                items.append(content)
            }
            sections.append(CVSection<SynchronizationContent>(items))
        }
        dataSource.synchronize(sections: sections)
    }

    // MARK: - Target Actions

    func didTouchUpSynchronize() {
        synchronize()
    }
}
