//
//  CVDataSourceBridge.swift
//  CVGenericDataSource
//
//  Created by Stephan Schulz on 12.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Typealiases

internal typealias NumberOfSections = () -> Int
internal typealias NumberOfItemsInSection = (Int) -> Int
internal typealias CollectionCellForItemAtIndexPath = (UICollectionView, IndexPath) -> UICollectionViewCell
internal typealias CollectionSupplementaryViewAtIndexPath = (UICollectionView, String, IndexPath) -> UICollectionReusableView
internal typealias SizeForItemAtIndexPath = (UICollectionView, UICollectionViewLayout, IndexPath) -> CGSize
internal typealias InsetsForSectionAtIndex = (UICollectionView, UICollectionViewLayout, Int) -> UIEdgeInsets
internal typealias DidSelectItemAtIndexPath = (UICollectionView, IndexPath) -> Void
internal typealias SizeForHeaderInSection = (UICollectionView, UICollectionViewLayout, Int) -> CGSize
internal typealias SizeForFooterInSection = (UICollectionView, UICollectionViewLayout, Int) -> CGSize
internal typealias WillDisplayCell = (UICollectionView, UICollectionViewCell, IndexPath) -> Void
internal typealias WillDisplaySupplementaryView = (UICollectionView, UICollectionReusableView, String, IndexPath) -> Void
internal typealias DidEndDisplayingCell = (UICollectionView, UICollectionViewCell, IndexPath) -> Void
internal typealias DidEndDisplayingSupplementaryView = (UICollectionView, UICollectionReusableView, String, IndexPath) -> Void
internal typealias ScrollViewDidScroll = (UIScrollView) -> Void
internal typealias LineSpacingForSection = (Int) -> CGFloat
internal typealias CellSpacingForSection = (Int) -> CGFloat
internal typealias PrefetchItems = (UICollectionView, [IndexPath]) -> Void
internal typealias CancelPrefetchItems = (UICollectionView, [IndexPath]) -> Void

// MARK: - CVDataSourceBridge

@objc internal final class CVDataSourceBridge: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {

    // MARK: - Constants
    
    let numberOfSections: NumberOfSections
    let numberOfItemsInSection: NumberOfItemsInSection
    
    // MARK: - Variables

    var collectionCellForItemAtIndexPath: CollectionCellForItemAtIndexPath?
    var collectionSupplementaryViewAtIndexPath: CollectionSupplementaryViewAtIndexPath?
    var sizeForItemAtIndexPath: SizeForItemAtIndexPath?
    var insetsForSectionAtIndex: InsetsForSectionAtIndex?
    var selectionAtIndexPath: DidSelectItemAtIndexPath?
    var sizeForHeaderInSection: SizeForHeaderInSection?
    var sizeForFooterInSection: SizeForFooterInSection?
    var willDisplayCell: WillDisplayCell?
    var willDisplaySupplementaryView: WillDisplaySupplementaryView?
    var didEndDisplayingCell: DidEndDisplayingCell?
    var didEndDisplayingSupplementaryView: DidEndDisplayingSupplementaryView?
    var scrollViewDidScroll: ScrollViewDidScroll?
    var lineSpacingForSection: LineSpacingForSection?
    var cellSpacingForSection: CellSpacingForSection?
    var prefetchItems: PrefetchItems?
    var cancelPrefetchItems: PrefetchItems?
    
    // MARK: - Init

    init(numberOfSections: @escaping NumberOfSections, numberOfItemsInSection: @escaping NumberOfItemsInSection) {
        self.numberOfSections = numberOfSections
        self.numberOfItemsInSection = numberOfItemsInSection
    }
    
    // MARK: - UICollectionViewDataSource / UICollectionViewDelegate

    @objc func numberOfSections(in _: UICollectionView) -> Int {
        return numberOfSections()
    }

    @objc func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItemsInSection(section)
    }

    @objc func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let collectionCellForItemAtIndexPath = collectionCellForItemAtIndexPath else {
            collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.ReuseIdentifier)
            return collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewCell.ReuseIdentifier, for: indexPath)
        }
        return collectionCellForItemAtIndexPath(collectionView, indexPath)
    }

    @objc func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let collectionSupplementaryViewAtIndexPath = collectionSupplementaryViewAtIndexPath else {
            collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: UICollectionReusableView.ReuseIdentifier)
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: UICollectionReusableView.ReuseIdentifier, for: indexPath)
        }
        return collectionSupplementaryViewAtIndexPath(collectionView, kind, indexPath)
    }

    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return sizeForItemAtIndexPath!(collectionView, collectionViewLayout, indexPath)
    }

    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let sizeForHeaderInSection = sizeForHeaderInSection else {
            return CGSize.epsilon
        }
        return sizeForHeaderInSection(collectionView, collectionViewLayout, section)
    }

    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let sizeForFooterInSection = sizeForFooterInSection else {
            return CGSize.epsilon
        }
        return sizeForFooterInSection(collectionView, collectionViewLayout, section)
    }

    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        guard let insetsForSectionAtIndex = insetsForSectionAtIndex else {
            return UIEdgeInsets.zero
        }
        return insetsForSectionAtIndex(collectionView, collectionViewLayout, section)
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        guard let lineSpacingForSection = lineSpacingForSection else {
            return 0
        }
        return lineSpacingForSection(section)
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        guard let cellSpacingForSection = cellSpacingForSection else {
            return 0
        }
        return cellSpacingForSection(section)
    }

    @objc func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectionAtIndexPath = selectionAtIndexPath else {
            return
        }
        selectionAtIndexPath(collectionView, indexPath)
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let willDisplayCell = willDisplayCell else {
            return
        }
        willDisplayCell(collectionView, cell, indexPath)
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        guard let willDisplaySupplementaryView = willDisplaySupplementaryView else {
            return
        }
        willDisplaySupplementaryView(collectionView, view, elementKind, indexPath)
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let didEndDisplayingCell = didEndDisplayingCell else {
            return
        }
        didEndDisplayingCell(collectionView, cell, indexPath)
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        guard let didEndDisplayingSupplementaryView = didEndDisplayingSupplementaryView else {
            return
        }
        didEndDisplayingSupplementaryView(collectionView, view, elementKind, indexPath)
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let prefetchItems = prefetchItems else {
            return
        }
        prefetchItems(collectionView, indexPaths)
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        guard let cancelPrefetchItems = cancelPrefetchItems else {
            return
        }
        cancelPrefetchItems(collectionView, indexPaths)
    }
    
    @objc func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScroll?(scrollView)
    }
}

// MARK: - CVDataSource Bridge Extensions

public extension CVDataSource where CellFactory.View: UICollectionViewCell, SupplementaryFactory.View: UICollectionReusableView, CellFactory.Item == S.Item {
    
    public func bind(collectionView: UICollectionView?) {
        if bridgedDataSource == nil {
            bridgedDataSource = bridge()
        }
        bindDataSourceTo(collectionView: collectionView)
        
        guard self.collectionView != collectionView else {
            return
        }
        self.collectionView = collectionView
    }
    
    internal func bridge() -> CVDataSourceBridge {
        
        let dataSource = CVDataSourceBridge(
            numberOfSections: { [unowned self]() -> Int in
                self.numberOfSections()
            },
            numberOfItemsInSection: { [unowned self](section) -> Int in
                self.numberOfItems(inSection: section)
        })
        dataSource.collectionCellForItemAtIndexPath = { [unowned self](collectionView, indexPath) -> UICollectionViewCell in
            self.cellFactory.cell(item: self.item(atIndexPath: indexPath), collectionView: collectionView, indexPath: indexPath)
        }
        dataSource.collectionSupplementaryViewAtIndexPath = { [unowned self](collectionView, kind, indexPath) -> UICollectionReusableView in
            guard self.supplementaryViewFactory != nil else {
                collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: UICollectionReusableView.ReuseIdentifier)
                return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: UICollectionReusableView.ReuseIdentifier, for: indexPath)
            }
            return self.supplementaryViewFactory.view(kind: kind, collectionView: collectionView, indexPath: indexPath)
        }
        dataSource.sizeForItemAtIndexPath = { [unowned self](_, _, indexPath) -> CGSize in
            self.cellFactory.sizeFor(item: self.item(atIndexPath: indexPath), atIndexPath: indexPath)
        }
        dataSource.insetsForSectionAtIndex = { [unowned self](_, _, section) -> UIEdgeInsets in
            if section < self.numberOfSections(), let insets = self.sections[section].insets {
                return insets
            }
            if let insets = self.optionSectionInsets {
                return insets(section)
            }
            return self.optionInsets
        }
        dataSource.selectionAtIndexPath = { [unowned self](collectionView, indexPath) -> Void in
            guard let cell = collectionView.cellForItem(at: indexPath) as? CellFactory.View else {
                return
            }
            let item = self.item(atIndexPath: indexPath)
            
            self.sections[indexPath.section].selection(item, indexPath.row)
            self.optionSelect?(indexPath.section, item, cell, indexPath)
        }
        dataSource.sizeForHeaderInSection = { [unowned self](collectionView, collectionViewLayout, section) -> CGSize in
            if let shouldShowSection = self.optionShouldShowSection, !shouldShowSection(section) {
                return CGSize.epsilon
            }
            guard section < self.numberOfSections(), self.sections[section].headerShouldAppear, self.supplementaryViewFactory != nil else {
                return CGSize.epsilon
            }
            return self.supplementaryViewFactory.size(kind: UICollectionElementKindSectionHeader, collectionView: collectionView, collectionViewLayout: collectionViewLayout, section: section)
        }
        dataSource.sizeForFooterInSection = { [unowned self](collectionView, collectionViewLayout, section) -> CGSize in
            guard section < self.numberOfSections(), self.sections[section].footerShouldAppear, self.supplementaryViewFactory != nil else {
                return CGSize.epsilon
            }
            return self.supplementaryViewFactory.size(kind: UICollectionElementKindSectionFooter, collectionView: collectionView, collectionViewLayout: collectionViewLayout, section: section)
        }
        dataSource.willDisplayCell = { (collectionView, cell, indexPath) -> Void in
            cell.prepare()
        }
        dataSource.didEndDisplayingCell = { (collectionView, cell, indexPath) -> Void in
            cell.cleanup()
        }
        dataSource.willDisplaySupplementaryView = { (collectionView, view, kind, indexPath) -> Void in
            view.prepare()
        }
        dataSource.didEndDisplayingSupplementaryView = { (collectionView, view, kind, indexPath) -> Void in
            view.cleanup()
        }
        dataSource.scrollViewDidScroll = { scrollView in
            self.loadAutomatically()
        }
        dataSource.lineSpacingForSection = { section in
            if let sectionLineSpacing = self.sections[section].lineSpacing {
                return sectionLineSpacing
            }
            return self.optionLineSpacing
        }
        dataSource.cellSpacingForSection = { section in
            if let sectionCellSpacing = self.sections[section].cellSpacing {
                return sectionCellSpacing
            }
            return self.optionCellSpacing
        }
        dataSource.prefetchItems = { (collectionView, indexPaths) in
            self.transform(indexPaths).forEach({ (section, items) in
                self.optionPrefetch?(section, items)
            })
        }
        dataSource.cancelPrefetchItems = { (collectionView, indexPaths) in
            self.transform(indexPaths).forEach({ (section, items) in
                self.optionCancelPrefetch?(section, items)
            })
        }
        return dataSource
    }
    
    fileprivate func transform(_ indexPaths: [IndexPath]) -> [Int: [S.Item]] {
        return indexPaths.reduce([:], { (result, indexPath) -> [Int: [S.Item]] in
            var result = result
            result[indexPath.section] = result[indexPath.section] ?? []
            if let item = self.item(atIndexPath: indexPath) {
                result[indexPath.section]?.append(item)
            }
            return result
        })
    }
}

public extension CVDataSource {
    
    internal func bindDataSourceTo(collectionView: UICollectionView?) {
        guard collectionView?.dataSource !== bridgedDataSource else {
            return
        }
        if #available(iOS 10.0, *) {
            collectionView?.prefetchDataSource = bridgedDataSource
        }
        collectionView?.dataSource = bridgedDataSource
        collectionView?.delegate = bridgedDataSource
        collectionView?.layoutIfNeeded()
    }
}

public extension CVStateDataSource {
    
    public func bind(collectionView: UICollectionView?) {
        if bridgedDataSource == nil {
            bridgedDataSource = bridge()
        }
        if #available(iOS 10.0, *) {
            collectionView?.prefetchDataSource = bridgedDataSource
        }
        collectionView?.dataSource = bridgedDataSource
        collectionView?.delegate = bridgedDataSource
        collectionView?.layoutIfNeeded()
    }
    
    internal func bridge() -> CVDataSourceBridge {
        
        let dataSource = CVDataSourceBridge(
            numberOfSections: { () -> Int in
                return 1
        },
            numberOfItemsInSection: { (section) -> Int in
                return 1
        })
        dataSource.collectionCellForItemAtIndexPath = { [unowned self](collectionView, indexPath) -> UICollectionViewCell in
            return self.stateFactory.cellFor(type: self.type, collectionView: collectionView, indexPath: indexPath) as! UICollectionViewCell
        }
        dataSource.sizeForItemAtIndexPath = { [unowned self](collectionView, collectionViewLayout, indexPath) -> CGSize in
            return self.stateFactory.size(type: self.type, collectionView: collectionView, collectionViewLayout: collectionViewLayout, indexPath: indexPath)
        }
        dataSource.willDisplayCell = { (collectionView, cell, indexPath) -> Void in
            cell.prepare()
        }
        dataSource.didEndDisplayingCell = { (collectionView, cell, indexPath) -> Void in
            cell.cleanup()
        }
        return dataSource
    }
}

// MARK: - CVDataSourceCache

final class CVDataSourceCache {
    
    // MARK: - Constants
    
    static let shared: CVDataSourceCache = CVDataSourceCache()
    
    //MARK: - Variables
    
    lazy var dictionary: [Int: [String]] = [:]
    
    // MARK: - Init
    
    private init() {
        
    }
    
    // MARK: - Convenience
    
    func add(_ collectionView: UICollectionView, _ reuseIdentifier: String) -> Bool {
        if has(collectionView, reuseIdentifier) {
            return false
        }
        let collectionViewId = unsafeBitCast(collectionView, to: Int.self)
        
        if dictionary[collectionViewId] == nil {
            dictionary[collectionViewId] = []
        }
        dictionary[collectionViewId]?.append(reuseIdentifier)
        
        return true
    }
    
    func has(_ collectionView: UICollectionView, _ reuseIdentifier: String) -> Bool {
        let collectionViewId = unsafeBitCast(collectionView, to: Int.self)
        
        guard let array = dictionary[collectionViewId], array.contains(reuseIdentifier) else {
            return false
        }
        return true
    }
    
    func clear() {
        dictionary.removeAll()
    }
}

// MARK: - Extensions

extension CGSize {
    static var epsilon: CGSize {
        return CGSize(width: 0.0001, height: 0.0001)
    }
}
