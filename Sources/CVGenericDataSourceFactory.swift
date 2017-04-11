//
//  CVGenericDataSourceFactory.swift
//  CVGenericDataSource
//
//  Created by Stephan Schulz on 12.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import Foundation
import UIKit

// MARK: - CVReusableViewProtocol

public protocol CVReusableViewProtocol: class {

    static var ReuseIdentifier: String { get }
    static var NibName: String { get }
    
    func create()
    func layout()
    func prepare()
    func cleanup()
    func reset()
    
    static func getInstance(size: CGSize) -> UIView
}

public extension CVReusableViewProtocol {
    
    public static func getInstance(size: CGSize) -> UIView {
        let nib = UINib(nibName: ReuseIdentifier, bundle: Bundle(for: Self.self))
        let instance = nib.instantiate(withOwner: nil, options: nil)[0] as! UIView
        instance.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        instance.layoutIfNeeded()
        
        return instance
    }
}

extension UICollectionReusableView: CVReusableViewProtocol {

    open class var NibName: String {
        return String()
    }

    open class var ReuseIdentifier: String {
        return String(describing: UICollectionReusableView.self)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        create()
    }
    
    open func create() {
    }
    
    open func layout() {
    }
    
    open func prepare() {
    }
    
    open func cleanup() {
    }
    
    open func reset() {
    }
}

// MARK: - CELLS

// MARK: - CVCell

open class CVCell: UICollectionViewCell {
    
    // MARK: - Variables
    
    override open class var ReuseIdentifier: String {
        return String(describing: CVCell.self)
    }
    
    // MARK: - Variables <Private>
    
    fileprivate var _didMoveToSuperview = false
    
    // MARK: - Life Cycle
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        
        reset()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !_didMoveToSuperview else {
            return
        }
        _didMoveToSuperview = true
        
        layout()
    }
}

// MARK: - CVCellFactoryProtocol

public protocol CVCellFactoryProtocol {

    associatedtype Item
    associatedtype View: CVReusableViewProtocol

    func reuseIdentifier(item: Item?) -> String
    func nibName(item: Item?) -> String
    func viewClass(item: Item?) -> AnyClass
    func setup(view: View, withItem item: Item?, atIndexPath indexPath: IndexPath) -> Void
    func sizeFor(item: Item?, atIndexPath indexPath: IndexPath) -> CGSize
}

public extension CVCellFactoryProtocol {
    
    public func cell(item: Item?, collectionView: UICollectionView, indexPath: IndexPath) -> View {
        let name = nibName(item: item)
        let id = reuseIdentifier(item: item)
        
        if CVDataSourceCache.shared.add(collectionView, id) {
            switch name.isEmpty {
            case true:
                collectionView.register(viewClass(item: item), forCellWithReuseIdentifier: id)
            case false:
                collectionView.register(UINib(nibName: name, bundle: nil), forCellWithReuseIdentifier: id)
            }
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! View
        
        if let cell = cell as? UICollectionViewCell {
            cell.layoutIfNeeded()
        }
        setup(view: cell, withItem: item, atIndexPath: indexPath)
        
        return cell
    }
    
    public func size(item: Item, collectionView: UICollectionView, collectionViewLayout: UICollectionViewLayout, indexPath: IndexPath) -> CGSize {
        return sizeFor(item: item, atIndexPath: indexPath)
    }
}

// MARK: - CVCellFactory

open class CVCellFactory<Item, Cell: CVReusableViewProtocol>: CVCellFactoryProtocol {

    // MARK: - Typealiases

    public typealias CVFactoryCellSetup = (_ cell: Cell, _ item: Item?, _ indexPath: IndexPath) -> Void
    public typealias CVFactorySize = (_ item: Item?, _ indexPath: IndexPath) -> CGSize

    // MARK: - Enums

    public enum CVFactoryOption {
        case setup(CVFactoryCellSetup)
        case size(CGSize)
        case sizeAtIndexPath(CVFactorySize)
    }

    // MARK: - Variables

    public var options: [CVFactoryOption]? {
        didSet {
            guard let options = options else {
                return
            }
            for option in options {
                switch option {
                case let .setup(value):
                    _setup = value
                case let .sizeAtIndexPath(value):
                    _sizeAtIndexPath = value
                case let .size(value):
                    _size = value
                }
            }
        }
    }

    // MARK: - Typealiases <Private>

    fileprivate var _setup: CVFactoryCellSetup?
    fileprivate var _sizeAtIndexPath: CVFactorySize?
    fileprivate var _size: CGSize?

    // MARK: - Init

    public init(_ options: [CVFactoryOption]? = nil) {
        defer {
            self.options = options
        }
    }

    // MARK: - Setup
    
    open func viewClass(item: Item?) -> AnyClass {
        return View.self
    }

    open func reuseIdentifier(item: Item?) -> String {
        return View.ReuseIdentifier
    }

    open func nibName(item: Item?) -> String {
        return View.NibName
    }

    open func sizeFor(item: Item?, atIndexPath indexPath: IndexPath) -> CGSize {
        guard let _sizeAtIndexPath = _sizeAtIndexPath else {
            guard let _size = _size else {
                return CGSize(width: 100, height: 100)
            }
            return _size
        }
        return _sizeAtIndexPath(item, indexPath)
    }

    open func setup(view: Cell, withItem item: Item?, atIndexPath indexPath: IndexPath) {
        _setup?(view, item, indexPath)
    }
}

// MARK: - SUPPLEMENTARY VIEWS

// MARK: - CVSupplementaryView

open class CVSupplementaryView: UICollectionReusableView {
    
    // MARK: - Variables
    
    override open class var ReuseIdentifier: String {
        return String(describing: CVSupplementaryView.self)
    }
    
    override open class var NibName: String {
        return String()
    }
    
    // MARK: - Variables <Private>
    
    fileprivate var _didLayoutSubviews = false
    
    // MARK: - Life Cycle
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        
        reset()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !_didLayoutSubviews else {
            return
        }
        _didLayoutSubviews = true
        
        layout()
    }
}

// MARK: - CVTitledSupplementaryView

public class CVTitledSupplementaryView: CVSupplementaryView {
    
    // MARK: - Variables
    
    public override class var ReuseIdentifier: String {
        return String(describing: CVTitledSupplementaryView.self)
    }
    
    public var verticalInset = CGFloat(15) {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var horizontalInset = CGFloat(15) {
        didSet {
            setNeedsLayout()
        }
    }
    
    private(set) public var label: UILabel!
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    func initialize() {
        label = UILabel()
        
        addSubview(label)
    }
    
    // MARK: - Life Cycle
    
    public override func reset() {
        super.reset()
        
        label.text = nil
        label.attributedText = nil
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        label.frame = bounds.insetBy(dx: horizontalInset, dy: verticalInset)
    }
}

// MARK: - CVSupplementaryViewType

public enum CVSupplementaryViewType {

    case header
    case footer

    func kind() -> String {
        switch self {
        case .header:
            return UICollectionElementKindSectionHeader
        case .footer:
            return UICollectionElementKindSectionFooter
        }
    }

    static func kind(_ value: String) -> CVSupplementaryViewType {
        if value == UICollectionElementKindSectionHeader {
            return .header
        }
        return .footer
    }
}

// MARK: - CVSupplementaryViewFactoryProtocol

public protocol CVSupplementaryViewFactoryProtocol {

    associatedtype View: CVReusableViewProtocol

    func reuseIdentifier(type: CVSupplementaryViewType, inSection section: Int) -> String
    func nibName(type: CVSupplementaryViewType, inSection section: Int) -> String
    func viewClass(type: CVSupplementaryViewType, inSection section: Int) -> AnyClass
    func setup(type: CVSupplementaryViewType, forView view: View, inSection section: Int) -> Void
    func size(type: CVSupplementaryViewType, inSection section: Int) -> CGSize
}

public extension CVSupplementaryViewFactoryProtocol {
    
    public func view(kind: String, collectionView: UICollectionView, indexPath: IndexPath) -> View {
        let type = CVSupplementaryViewType.kind(kind)
        let name = nibName(type: type, inSection: indexPath.section)
        let id = reuseIdentifier(type: type, inSection: indexPath.section)
        
        if CVDataSourceCache.shared.add(collectionView, String(format: "%@%i", id, type.hashValue)) {
            switch name.isEmpty {
            case true:
                collectionView.register(viewClass(type: type, inSection: indexPath.section), forSupplementaryViewOfKind: kind, withReuseIdentifier: id)
            case false:
                collectionView.register(UINib(nibName: name, bundle: nil), forSupplementaryViewOfKind: kind, withReuseIdentifier: id)
            }
        }
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! View
        
        setup(type: type, forView: view, inSection: indexPath.section)
        
        return view
    }
    
    public func size(kind: String, collectionView: UICollectionView, collectionViewLayout: UICollectionViewLayout, section: Int) -> CGSize {
        return size(type: CVSupplementaryViewType.kind(kind), inSection: section)
    }
}

// MARK: - CVSupplementaryViewFactory

open class CVSupplementaryViewFactory<View: CVReusableViewProtocol>: CVSupplementaryViewFactoryProtocol {

    // MARK: - Typealiases

    public typealias CVFactoryViewSetup = (_ type: CVSupplementaryViewType, _ view: View, _ section: Int) -> Void
    public typealias CVFactorySize = (_ type: CVSupplementaryViewType, _ section: Int) -> CGSize

    // MARK: - Enums

    public enum CVFactoryOption {
        case setup(CVFactoryViewSetup)
        case size(CGSize)
        case sizeForSection(CVFactorySize)
    }

    // MARK: - Variables

    public var type: CVSupplementaryViewType
    public var options: [CVFactoryOption]? {
        didSet {
            guard let options = options else {
                return
            }
            for option in options {
                switch option {
                case let .setup(value):
                    _setup = value
                case let .sizeForSection(value):
                    _sizeForSection = value
                case let .size(value):
                    _size = value
                }
            }
        }
    }

    // MARK: - Typealiases <Private>

    fileprivate var _setup: CVFactoryViewSetup?
    fileprivate var _sizeForSection: CVFactorySize?
    fileprivate var _size: CGSize?

    // MARK: - Init

    public init(_ type: CVSupplementaryViewType, _ options: [CVFactoryOption]? = nil) {
        self.type = type

        defer {
            self.options = options
        }
    }

    // MARK: - Setup
    
    open func viewClass(type: CVSupplementaryViewType, inSection section: Int) -> AnyClass {
        return View.self
    }

    open func reuseIdentifier(type: CVSupplementaryViewType, inSection section: Int) -> String {
        return View.ReuseIdentifier
    }

    open func nibName(type: CVSupplementaryViewType, inSection section: Int) -> String {
        return View.NibName
    }

    open func size(type: CVSupplementaryViewType, inSection section: Int) -> CGSize {
        guard let _sizeForSection = _sizeForSection else {
            guard let _size = _size else {
                return CGSize(width: 100, height: 100)
            }
            return _size
        }
        return _sizeForSection(type, section)
    }

    open func setup(type: CVSupplementaryViewType, forView view: View, inSection section: Int) {
        _setup?(type, view, section)
    }
}

// MARK: - STATE CELLS

// MARK: - CVStateFactoryType

public enum CVStateFactoryType {
    
    case empty
    case loading
}

// MARK: - CVStateFactoryProtocol

public protocol CVStateFactoryProtocol {
    
    associatedtype Empty: CVReusableViewProtocol
    associatedtype Loading: CVReusableViewProtocol
    
    func reuseIdentifier(type: CVStateFactoryType) -> String
    func nibName(type: CVStateFactoryType) -> String
    func setup(type: CVStateFactoryType, view: CVReusableViewProtocol) -> Void
    func size(type: CVStateFactoryType, preferredSize: CGSize) -> CGSize
}

public extension CVStateFactoryProtocol {
    
    public func cellFor(type: CVStateFactoryType, collectionView: UICollectionView, indexPath: IndexPath) -> CVReusableViewProtocol {
        let name = nibName(type: type)
        let id = reuseIdentifier(type: type)
        
        if CVDataSourceCache.shared.add(collectionView, String(format: "%@%i", id, type.hashValue)) {
            if name.isEmpty {
                switch type {
                case .empty:
                    collectionView.register(Empty.self, forCellWithReuseIdentifier: id)
                case .loading:
                    collectionView.register(Loading.self, forCellWithReuseIdentifier: id)
                }
            } else {
                collectionView.register(UINib(nibName: name, bundle: Bundle(for: type == .empty ? Empty.self : Loading.self)), forCellWithReuseIdentifier: id)
            }
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier(type: type), for: indexPath)
        cell.layoutIfNeeded()
        
        setup(type: type, view: cell)
        
        return cell
    }
    
    public func size(type: CVStateFactoryType, collectionView: UICollectionView, collectionViewLayout: UICollectionViewLayout, indexPath: IndexPath) -> CGSize {
        return size(type: type, preferredSize: collectionView.frame.size)
    }
}

// MARK: - CVStateFactory

open class CVStateFactory<E: CVReusableViewProtocol, L: CVReusableViewProtocol>: CVStateFactoryProtocol {
    
    
    // MARK: - Typealiases
    
    public typealias Empty = E
    public typealias Loading = L
    public typealias CVFactoryViewSetup = (_ type: CVStateFactoryType, _ view: CVReusableViewProtocol) -> Void
    public typealias CVFactorySize = (_ type: CVStateFactoryType) -> CGSize
    
    // MARK: - Enums
    
    public enum CVFactoryOption {
        case setup(CVFactoryViewSetup)
        case size(CGSize)
    }
    
    // MARK: - Variables
    
    public var type: CVStateFactoryType!
    public var options: [CVFactoryOption]? {
        didSet {
            guard let options = options else {
                return
            }
            for option in options {
                switch option {
                case let .setup(value):
                    _setup = value
                case let .size(value):
                    _size = value
                }
            }
        }
    }
    
    // MARK: - Typealiases <Private>
    
    fileprivate var _setup: CVFactoryViewSetup?
    fileprivate var _size: CGSize?
    
    // MARK: - Init
    
    public init(_ options: [CVFactoryOption]? = nil) {
        defer {
            self.options = options
        }
    }
    
    // MARK: - Setup
    
    open func reuseIdentifier(type: CVStateFactoryType) -> String {
        switch type {
        case .empty:
            return Empty.ReuseIdentifier
        case .loading:
            return Loading.ReuseIdentifier
        }
    }
    
    open func nibName(type: CVStateFactoryType) -> String {
        switch type {
        case .empty:
            return Empty.NibName
        case .loading:
            return Loading.NibName
        }
    }
    
    open func size(type: CVStateFactoryType, preferredSize: CGSize) -> CGSize {
        guard let _size = _size else {
            return preferredSize
        }
        return _size
    }
    
    open func setup(type: CVStateFactoryType, view: CVReusableViewProtocol) {
        _setup?(type, view)
    }
}
