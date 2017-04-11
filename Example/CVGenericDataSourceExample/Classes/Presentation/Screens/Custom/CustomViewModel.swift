//
//  CustomViewModel.swift
//  CVGenericDataSourceExample
//
//  Created by Stephan Schulz on 11.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import Foundation
import CVGenericDataSource

func == (a: CustomContentGreen, b: CustomContentGreen) -> Bool {
    return a.id == b.id
}

func == (a: CustomContentBlue, b: CustomContentBlue) -> Bool {
    return a.id == b.id
}

func ==(lhs: CustomContent, rhs: CustomContent) -> Bool {
    switch (lhs, rhs) {
    case (.green, .green):
        return true
    case (.blue, .blue):
        return true
    default:
        return false
    }
}
struct CustomContentGreen: Equatable {

    var id: Int?
}

struct CustomContentBlue: Equatable {

    var id: Int?
}

enum CustomContent: Equatable {
    case green(CustomContentGreen)
    case blue(CustomContentBlue)
}

class CustomViewModel {

    // MARK: - Constants

    let coordinator: CustomCoordinator

    // MARK: - Variables

    var dataSource: CVDataSource<CVSection<CustomContent>,
    CustomCellFactory<CustomContent, UICollectionViewCell>,
    CustomSupplementaryViewFactory<UICollectionReusableView>,
    CVStateFactory<UICollectionViewCell, UICollectionViewCell>>!

    // MARK: - Life Cycle

    init(coordinator: CustomCoordinator) {
        self.coordinator = coordinator

        setupDataSource()
    }

    func dispose() {
        coordinator.finish()
    }

    // MARK: - DataSource

    func setupDataSource() {
        let greenItem = CustomContent.green(CustomContentGreen())
        let blueItem = CustomContent.blue(CustomContentBlue())

        dataSource = CVDataSource(
            sections: [
                CVSection([greenItem, blueItem]),
                CVSection([blueItem, blueItem, greenItem]),
            ],
            cellFactory:
                CustomCellFactory<CustomContent, UICollectionViewCell>(
                    green: CVCellFactory<CustomContentGreen, CustomCellGreen>(),
                    blue: CVCellFactory<CustomContentBlue, CustomCellBlue>()
            ),
            supplementaryViewFactory:
                CustomSupplementaryViewFactory<UICollectionReusableView>(
                    header: CVSupplementaryViewFactory<CustomSectionHeader>(.header),
                    footer: CVSupplementaryViewFactory<CustomSectionFooter>(.footer),
                    options: [
                        .size(Interface.general.sectionSize)
                    ]
            ),
            options: [
                .insets(Interface.general.sectionInset)
            ]
        )
    }
}

class CustomCellFactory<Item, View: CVReusableViewProtocol>: CVCellFactory<Item, View> {

    let green: CVCellFactory<CustomContentGreen, CustomCellGreen>
    let blue: CVCellFactory<CustomContentBlue, CustomCellBlue>

    init(green: CVCellFactory<CustomContentGreen, CustomCellGreen>, blue: CVCellFactory<CustomContentBlue, CustomCellBlue>) {
        self.green = green
        self.blue = blue
    }

    override func reuseIdentifier(item: Item?) -> String {
        guard let item = item as? CustomContent else {
            fatalError()
        }
        switch item {
        case .green:
            return CustomCellGreen.ReuseIdentifier
        case .blue:
            return CustomCellBlue.ReuseIdentifier
        }
    }

    override func nibName(item: Item?) -> String {
        guard let item = item as? CustomContent else {
            fatalError()
        }
        switch item {
        case .green:
            return CustomCellGreen.NibName
        case .blue:
            return CustomCellBlue.NibName
        }
    }
}

class CustomSupplementaryViewFactory<View: CVReusableViewProtocol>: CVSupplementaryViewFactory<View> {

    let header: CVSupplementaryViewFactory<CustomSectionHeader>
    let footer: CVSupplementaryViewFactory<CustomSectionFooter>

    init(header: CVSupplementaryViewFactory<CustomSectionHeader>, footer: CVSupplementaryViewFactory<CustomSectionFooter>, options: [CVFactoryOption]? = nil) {
        self.header = header
        self.footer = footer

        super.init(.header, options)
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
        switch type {
        case .header:
            return header.nibName(type: type, inSection: section)
        case .footer:
            return footer.nibName(type: type, inSection: section)
        }
    }
}
