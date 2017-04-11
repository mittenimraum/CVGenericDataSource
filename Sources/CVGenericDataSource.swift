//
//  CVGenericDataSource.swift
//  CVGenericDataSource
//
//  Created by Stephan Schulz on 12.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import UIKit

// MARK: - Enums

public enum CVDataSourceState {
    case inited, empty, ready, loading
}

public enum CVDataSourceType {
    case empty, loading, content
}

public enum CVDataSourceOperation {
    case insert, synchronize
}

// MARK: - CVDataSource

public class CVDataSource<S: CVSectionProtocol & CVSectionOptionProtocol, CellFactory: CVCellFactoryProtocol, SupplementaryFactory: CVSupplementaryViewFactoryProtocol, StateFactory: CVStateFactoryProtocol> where CellFactory.Item == S.Item {

    // MARK: - Options
    
    public typealias CVShouldShowSection = (_ section: Int) -> Bool
    public typealias CVLoadResult = ([S.Item], _ operation: CVDataSourceOperation) -> Void
    public typealias CVLoad = (_ section: Int, _ offset: Int, _ result: @escaping CVLoadResult) -> Void
    public typealias CVLoadMore = () -> Void
    public typealias CVLoadMoreDelay = () -> TimeInterval
    public typealias CVLoadMoreDistance = (UICollectionView) -> CGFloat
    public typealias CVShouldLoadMore = () -> Bool
    public typealias CVShouldShowState = (CVStateFactoryType) -> Bool
    public typealias CVPrefetchItems = (_ section: Int, _ items: [S.Item]) -> Void
    public typealias CVDidLoad = (_ section: Int, _ offset: Int, _ offsetBefore: Int, _ items: [S.Item]) -> Void
    public typealias CVDidFinishPerformUpdates = () -> Void
    public typealias CVSelect = (_ section: Int, _ item: S.Item?, _ cell: CellFactory.View, _ indexPath: IndexPath) -> Void
    public typealias CVSectionInsets = (_ section: Int) -> UIEdgeInsets
    
    public enum CVDataSourceOption {
        case lineSpacing(CGFloat)
        case cellSpacing(CGFloat)
        case sectionInsets(CVSectionInsets)
        case insets(UIEdgeInsets)
        case select(CVSelect)
        case load(CVLoad)
        case loadMore(CVLoadMore)
        case loadMoreDistance(CVLoadMoreDistance)
        case loadMoreDelay(CVLoadMoreDelay)
        case prefetch(CVPrefetchItems)
        case cancelPrefetch(CVPrefetchItems)
        case shouldLoadMore(CVShouldLoadMore)
        case shouldShowSection(CVShouldShowSection)
        case shouldShowState(CVShouldShowState)
        case didLoad(CVDidLoad)
        case didPerformUpdates(CVDidFinishPerformUpdates)
    }

    public var options: [CVDataSourceOption]? {
        didSet {
            guard let options = options else {
                return
            }
            for option in options {
                switch option {
                case let .load(value):
                    optionLoad = value
                case let .shouldShowSection(value):
                    optionShouldShowSection = value
                case let .shouldLoadMore(value):
                    optionShouldLoadMore = value
                case let .loadMore(value):
                    optionLoadMore = value
                case let .loadMoreDistance(value):
                    optionLoadMoreDistance = value
                case let .loadMoreDelay(value):
                    optionLoadMoreDelay = value
                case let .shouldShowState(value):
                    optionShouldShowState = value
                case let .lineSpacing(value):
                    optionLineSpacing = value
                case let .cellSpacing(value):
                    optionCellSpacing = value
                case let .prefetch(value):
                    optionPrefetch = value
                case let .cancelPrefetch(value):
                    optionCancelPrefetch = value
                case let .didLoad(value):
                    optionDidLoad = value
                case let .didPerformUpdates(value):
                    optionDidPerformUpdates = value
                case let .select(value):
                    optionSelect = value
                case let .insets(value):
                    optionInsets = value
                case let .sectionInsets(value):
                    optionSectionInsets = value
                }
            }
        }
    }
    
    var optionSelect: CVSelect?
    var optionPrefetch: CVPrefetchItems?
    var optionCancelPrefetch: CVPrefetchItems?
    var optionLoad: CVLoad?
    var optionLoadMore: CVLoadMore?
    var optionLoadMoreDelay: CVLoadMoreDelay = { 0.5 }
    var optionLoadMoreDistance: CVLoadMoreDistance = { collectionView in
        var direction = UICollectionViewScrollDirection.vertical
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            direction = flowLayout.scrollDirection
        }
        switch direction {
        case .vertical:
            return min(collectionView.contentSize.height * 0.5, collectionView.frame.size.height * 4)
        case .horizontal:
            return min(collectionView.contentSize.width * 0.5, collectionView.frame.size.width * 4)
        }
    }
    var optionInsets = UIEdgeInsets.zero
    var optionSectionInsets: CVSectionInsets?
    var optionLineSpacing: CGFloat = 0
    var optionCellSpacing: CGFloat = 0
    var optionDidLoad: CVDidLoad?
    var optionDidPerformUpdates: CVDidFinishPerformUpdates?
    var optionShouldShowSection: CVShouldShowSection?
    var optionShouldLoadMore: CVShouldLoadMore = { false }
    var optionShouldShowState: CVShouldShowState = { state in true }
    
    // MARK: - Variables
    
    public var sections: [S]
    public var state: CVDataSourceState = .inited {
        didSet {
            switch state {
            case .loading:
                guard isEmpty(), optionShouldShowState(.loading) else {
                    return
                }
                switchTo(type: .loading)
            case .empty:
                guard optionShouldShowState(.empty) else {
                    return
                }
                switchTo(type: .empty)
            case .ready:
                if isEmpty(), optionShouldShowState(.empty) {
                    switchTo(type: .empty)
                } else {
                    switchTo(type: .content)
                }
                _readyTimestamp = Date().timeIntervalSince1970
            default:
                break
            }
        }
    }
    public weak var collectionView: UICollectionView? {
        didSet {
            guard sections.count == 0 else {
                return
            }
            switch state {
            case .loading:
                guard isEmpty(), optionShouldShowState(.loading) else {
                    return
                }
                switchTo(type: .loading)
            case .inited:
                guard isEmpty(), optionShouldShowState(.empty) else {
                    return
                }
                state = .empty
            default:
                break
            }
        }
    }
    
    // MARK: - Constants
    
    let cellFactory: CellFactory

    // MARK: - Variables
    
    var supplementaryViewFactory: SupplementaryFactory!
    var bridgedDataSource: CVDataSourceBridge?
    var loadingDataSource: CVStateDataSource<StateFactory>?
    var emptyDataSource: CVStateDataSource<StateFactory>?
    
    // MARK: - Variables <Private>
    
    fileprivate var _loadingGroup = DispatchGroup()
    fileprivate var _updateGroup: DispatchGroup?
    fileprivate var _readyTimestamp: TimeInterval = 0
    
    // MARK: - Init

    public init(sections: [S], cellFactory: CellFactory, options: [CVDataSourceOption]? = nil) {
        self.sections = sections
        self.cellFactory = cellFactory

        defer {
            self.options = options
        }
    }
    
    public init(sections: [S], cellFactory: CellFactory, stateFactory: StateFactory, options: [CVDataSourceOption]? = nil) {
        self.sections = sections
        self.cellFactory = cellFactory
        self.loadingDataSource = CVStateDataSource(type: .loading, stateFactory: stateFactory)
        self.emptyDataSource = CVStateDataSource(type: .empty, stateFactory: stateFactory)
        
        defer {
            self.options = options
        }
    }

    public init(sections: [S], cellFactory: CellFactory, supplementaryViewFactory: SupplementaryFactory, options: [CVDataSourceOption]? = nil) {
        self.sections = sections
        self.cellFactory = cellFactory
        self.supplementaryViewFactory = supplementaryViewFactory

        defer {
            self.options = options
        }
    }
    
    public init(sections: [S], cellFactory: CellFactory, supplementaryViewFactory: SupplementaryFactory, stateFactory: StateFactory, options: [CVDataSourceOption]? = nil) {
        self.sections = sections
        self.cellFactory = cellFactory
        self.supplementaryViewFactory = supplementaryViewFactory
        self.loadingDataSource = CVStateDataSource(type: .loading, stateFactory: stateFactory)
        self.emptyDataSource = CVStateDataSource(type: .empty, stateFactory: stateFactory)
        
        defer {
            self.options = options
        }
    }
}

// MARK: - Getter

public extension CVDataSource {
    
    public func isEmpty() -> Bool {
        for section in 0..<numberOfSections() {
            if sections[section].items.count > 0 {
                return false
            }
        }
        return true
    }
    
    public func numberOfSections() -> Int {
        return sections.count
    }
    
    public func numberOfItems(inSection section: Int) -> Int {
        guard section < sections.count else {
            return 0
        }
        return sections[section].items.count
    }
    
    public func items(inSection section: Int) -> [S.Item]? {
        guard section < sections.count else {
            return nil
        }
        return sections[section].items
    }
    
    public func item(atRow row: Int, inSection section: Int) -> S.Item? {
        guard let items = items(inSection: section) else {
            return nil
        }
        guard row < items.count else {
            return nil
        }
        return items[row]
    }
    
    public func item(atIndexPath indexPath: IndexPath) -> S.Item? {
        return item(atRow: indexPath.row, inSection: indexPath.section)
    }
}

// MARK: - Loading

public extension CVDataSource {
    
    public func load() {
        guard state != .loading else {
            return
        }
        state = .loading
        
        for section in 0..<max(1, sections.count) {
            fetch(section: section)
        }
        didLoadNotifiy()
    }
    
    public func load(section: Int) {
        guard state != .loading else {
            return
        }
        state = .loading
        
        fetch(section: section)
        didLoadNotifiy()
    }
    
    func loadAutomatically() {
        guard let scrollView =  collectionView, state != .loading, !isEmpty(), Date().timeIntervalSince1970 - _readyTimestamp >= optionLoadMoreDelay(), optionShouldLoadMore() else {
            return
        }
        var distanceToEnd = CGFloat.greatestFiniteMagnitude
        var direction = UICollectionViewScrollDirection.vertical
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            direction = flowLayout.scrollDirection
        }
        switch direction {
        case .vertical:
            distanceToEnd = scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.size.height + scrollView.contentInset.bottom
        case .horizontal:
            distanceToEnd = scrollView.contentSize.width - scrollView.contentOffset.x - scrollView.frame.size.width + scrollView.contentInset.right
        }
        if distanceToEnd < optionLoadMoreDistance(scrollView) {
            guard let loadMore = optionLoadMore else {
                load()
                
                return
            }
            loadMore()
        }
    }
    
    public func reload() {
        clear()
        load()
    }
    
    public func reload(newSections sections: [S]) {
        clear()
        self.sections = sections
        load()
    }
    
    public func reload(section: Int) {
        remove(itemsInSection: section)
        load(section: section)
    }
    
    func fetch(section: Int) {
        _loadingGroup.enter()
        
        optionLoad?(section, section < numberOfSections() ? sections[section].items.count : 0, { (items, operation) in
            self.didLoad(items: items, inSection: section, withOperation: operation)
            
            self._loadingGroup.leave()
        })
    }
    
    func didLoadNotifiy() {
        _loadingGroup.notify(queue: DispatchQueue.main) {
            if self.isEmpty() {
                return
            }
            self.state = .ready
            
            DispatchQueue.main.asyncAfter(deadline: .now() + self.optionLoadMoreDelay()) {
                self.loadAutomatically()
            }
        }
    }
    
    func didLoad(items: [S.Item], inSection section: Int, withOperation operation: CVDataSourceOperation) {
        let offsetBefore = section < numberOfSections() ? sections[section].items.count : 0
        
        guard items.count > 0 || operation == .synchronize else {
            state = isEmpty() ? .empty : .ready

            optionDidLoad?(section, sections[section].items.count, offsetBefore, items)
            
            return
        }
        switchTo(type: .content)
        
        switch operation {
        case .insert:
            insert(items: items, inSection: section)
        case .synchronize:
            synchronize(items: items, inSection: section)
        }
        optionDidLoad?(section, sections[section].items.count, offsetBefore, items)
    }
}

// MARK: - State

public extension CVDataSource {
    
    public func switchTo(type: CVDataSourceType) {
        guard let collectionView = collectionView else {
            return
        }
        switch type {
        case .empty:
            emptyDataSource?.bind(collectionView: collectionView)
        case .loading:
            loadingDataSource?.bind(collectionView: collectionView)
        case .content:
            bindDataSourceTo(collectionView: collectionView)
        }
    }
}

// MARK: - Data

public extension CVDataSource {

    public func append(item: S.Item, inSection section: Int) {
        guard let items = items(inSection: section) else {
            return
        }
        insert(item: item, atRow: items.endIndex, inSection: section)
    }
    
    public func synchronize(sections: [S]) {
        for (index, section) in sections.enumerated() {
            synchronize(items: section.items, inSection: index)
        }
    }

    public func synchronize(items: [S.Item], inSection section: Int) {
        var toRemove: [S.Item] = []
        var toAdd: [S.Item] = []
        var rows = [Int]()

        if section >= numberOfSections() {
            toAdd = items
        } else {
            for (index, item) in items.enumerated() {
                guard !sections[section].items.contains(item) else {
                    continue
                }
                toAdd.append(item)
                rows.append(index)
            }
            for item in sections[section].items {
                guard !items.contains(item) else {
                    continue
                }
                toRemove.append(item)
            }
        }
        remove(items: toRemove, inSection: section)
        insert(items: toAdd, inSection: section, atRows: rows) {
            if self.isEmpty() {
                self.state = .empty
            }
        }
    }
    
    public func clear() {
        for section in 0..<numberOfSections() {
            remove(items: sections[section].items, inSection: section)
        }
        sections.removeAll()
        
        state = .empty
    }
    
    @discardableResult
    public func remove(atRow row: Int, inSection section: Int) -> S.Item? {
        guard let item = item(atRow: row, inSection: section) else {
            return nil
        }
        return remove(items: [item], inSection: section)?.filter({ $0 == item }).first
    }
    
    @discardableResult
    public func remove(atIndexPath indexPath: IndexPath) -> S.Item? {
        return remove(atRow: indexPath.row, inSection: indexPath.section)
    }
    
    public func remove(itemsInSection section: Int) {
        guard let items = items(inSection: section) else {
            return
        }
        remove(items: items, inSection: section)
    }
    
    @discardableResult
    func remove(items: [S.Item], inSection section: Int, completion: (() -> Void)? = nil) -> [S.Item]? {
        guard items.count > 0 else {
            return nil
        }
        var indexPaths = [IndexPath]()
        var itemsRemoved: [S.Item] = []

        for item in items {
            guard let index = sections[section].items.index(of: item) else {
                continue
            }
            indexPaths.append(IndexPath(row: index, section: section))
        }
        for item in items {
            guard let index = sections[section].items.index(of: item) else {
                continue
            }
            sections[section].items.remove(at: index)
            
            itemsRemoved.append(item)
        }
        renderRemoval(atIndexPaths: indexPaths) {
            completion?()
        }
        return itemsRemoved
    }
    
    public func insert(item: S.Item, at indexPath: IndexPath) {
        insert(item: item, atRow: indexPath.row, inSection: indexPath.section)
    }
    
    public func insert(item: S.Item, atRow row: Int, inSection section: Int) {
        guard section < numberOfSections() else {
            return
        }
        guard row <= numberOfItems(inSection: section) else {
            return
        }
        insert(items: [item], inSection: section, atRows: [row])
    }
    
    func insert(items: [S.Item], inSection section: Int, atRows rows: [Int]? = nil, completion: (() -> Void)? = nil) {
        guard items.count > 0 else {
            completion?()
            
            return
        }
        let offsetBefore = section < numberOfSections() ? sections[section].items.count : 0
        let offsetAfter = offsetBefore + items.count
        let indexSet = section >= numberOfSections() ? IndexSet(numberOfSections()...section) : IndexSet()
        var indexPaths = [IndexPath]()
        
        for index in 0..<max(1, section) {
            if index < numberOfSections() {
                continue
            }
            sections.append(CVSection<S.Item>([]) as! S)
        }
        if let rows = rows, rows.count == items.count {
            for i in 0..<rows.count {
                let item = items[i]
                let index = min(sections[section].items.count, rows[i])

                indexPaths.append(IndexPath(row: index, section: section))
                sections[section].items.insert(item, at: index)
            }
        } else {
            for i in offsetBefore..<offsetAfter {
                indexPaths.append(IndexPath(row: i, section: section))
            }
            for item in items {
                sections[section].items.insert(item, at: sections[section].items.endIndex)
            }
        }
        renderInsertion(atIndexPaths: indexPaths, inSection: section, withIndexSet: indexSet) {
            completion?()
        }
    }
    
    func renderRemoval(atIndexPaths indexPaths: [IndexPath], completion: (() -> Void)?) {
        let dispatchGroup = updateGroup()
        dispatchGroup.1?.enter()

        collectionView?.performBatchUpdates({
            self.collectionView?.deleteItems(at: indexPaths)
        }, completion: { (value) in
            dispatchGroup.1?.leave()
            completion?()
        })
        updateGroupNotify(dispatchGroup.0)
    }

    func renderInsertion(atIndexPaths indexPaths: [IndexPath], inSection section: Int, withIndexSet indexSet: IndexSet, completion: (() -> Void)?) {
        let dispatchGroup = updateGroup()
        dispatchGroup.1?.enter()
        
        collectionView?.performBatchUpdates({
            if indexSet.count > 0 {
                self.collectionView?.insertSections(indexSet)
            }
            self.collectionView?.insertItems(at: indexPaths)
        }, completion: { value in
            dispatchGroup.1?.leave()
            completion?()
        })
        updateGroupNotify(dispatchGroup.0)
    }
    
    fileprivate func updateGroup() -> (Bool, DispatchGroup?) {
        if let group = _updateGroup {
            return (false, group)
        }
        _updateGroup = DispatchGroup()
            
        return (true, _updateGroup)
    }
    
    fileprivate func updateGroupNotify(_ value: Bool) {
        guard value else {
            return
        }
        _updateGroup?.notify(queue: DispatchQueue.main) {
            self.optionDidPerformUpdates?()
            
            self._updateGroup = nil
        }
    }
}

// MARK: - CVStateDataSource

public class CVStateDataSource<StateFactory: CVStateFactoryProtocol> {
    
    // MARK: - Constants <Internal>
    
    let type: CVStateFactoryType
    let stateFactory: StateFactory
    
    // MARK: - Variables <Internal>
    
    var bridgedDataSource: CVDataSourceBridge?
    
    // MARK: - Init
    
    public init(type: CVStateFactoryType, stateFactory: StateFactory) {
        self.type = type
        self.stateFactory = stateFactory
    }
}
