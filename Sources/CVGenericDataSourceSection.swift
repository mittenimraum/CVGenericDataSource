//
//  CVGenericDataSourceSection.swift
//  CVGenericDataSource
//
//  Created by Stephan Schulz on 12.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import Foundation

// MARK: - CVSectionProtocol

public protocol CVSectionProtocol {

    associatedtype Item: Equatable

    var items: [Item] { get set }
    var headerTitle: String? { get }
    var footerTitle: String? { get }
}

// MARK: - CVSectionOptionProtocol

public protocol CVSectionOptionProtocol {

    associatedtype Item: Equatable

    var insets: UIEdgeInsets? { get }
    var headerShouldAppear: Bool { get }
    var footerShouldAppear: Bool { get }
    var lineSpacing: CGFloat? { get }
    var cellSpacing: CGFloat? { get }

    func selection(_ item: Item?, _ index: Int) -> Void
}

// MARK: - CVSection

public struct CVSection<Item: Equatable>: CVSectionProtocol {

    // MARK: - Options

    public enum CVSectionOption {
        case insets(UIEdgeInsets)
        case selection(CVSectionSelection)
        case headerShouldAppear(Bool)
        case footerShouldAppear(Bool)
        case lineSpacing(CGFloat)
        case cellSpacing(CGFloat)
    }

    public var options: [CVSectionOption]? {
        didSet {
            guard let options = options else {
                return
            }
            for option in options {
                switch option {
                case let .insets(value):
                    _optionInsets = value
                case let .selection(value):
                    _optionSelection = value
                case let .headerShouldAppear(value):
                    _optionHeaderShouldAppear = value
                case let .footerShouldAppear(value):
                    _optionFooterShouldAppear = value
                case let .lineSpacing(value):
                    _optionLineSpacing = value
                case let .cellSpacing(value):
                    _optionCellSpacing = value
                }
            }
        }
    }

    fileprivate var _optionLineSpacing: CGFloat?
    fileprivate var _optionCellSpacing: CGFloat?
    fileprivate var _optionFooterShouldAppear: Bool?
    fileprivate var _optionHeaderShouldAppear: Bool?
    fileprivate var _optionInsets: UIEdgeInsets?
    fileprivate var _optionSelection: CVSectionSelection?

    // MARK: - Constants
    
    public let headerTitle: String?
    public let footerTitle: String?
    
    // MARK: - Variables

    public var items: [Item]
    public var count: Int {
        return items.count
    }
    
    // MARK: - Init

    public init(items: Item..., headerTitle: String? = nil, footerTitle: String? = nil, _ options: [CVSectionOption]? = nil) {
        self.init(items, headerTitle: headerTitle, footerTitle: footerTitle, options)
    }

    public init(_ items: [Item], headerTitle: String? = nil, footerTitle: String? = nil, _ options: [CVSectionOption]? = nil) {
        self.items = items
        self.headerTitle = headerTitle
        self.footerTitle = footerTitle

        defer {
            self.options = options
        }
    }
    
    // MARK: - Subscript

    public subscript(index: Int) -> Item {
        get {
            return items[index]
        }
        set {
            items[index] = newValue
        }
    }
}

// MARK: - Extensions

extension CVSection: CVSectionOptionProtocol {
    
    public typealias CVSectionSelection = (_ item: Item?, _ index: Int) -> Void
    
    public var cellSpacing: CGFloat? {
        return _optionCellSpacing
    }
    
    public var lineSpacing: CGFloat? {
        return _optionLineSpacing
    }
    
    public var insets: UIEdgeInsets? {
        return _optionInsets
    }
    
    public var headerShouldAppear: Bool {
        return _optionHeaderShouldAppear ?? true
    }
    
    public var footerShouldAppear: Bool {
        return _optionFooterShouldAppear ?? false
    }
    
    public func selection(_ item: Item?, _ index: Int) {
        _optionSelection?(item, index)
    }
}
