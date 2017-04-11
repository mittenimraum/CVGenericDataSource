//
//  DataBinding.swift
//  CVGenericDataSourceExample
//
//  Created by Stephan Schulz on 11.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

class DataBinding<T> {

    // MARK: - Aliases

    typealias Listener = (T) -> Void

    // MARK: - Variables

    var listener: Listener?
    var value: T {
        didSet {
            listener?(value)
        }
    }

    // MARK: - Init

    init(_ v: T) {
        value = v
    }

    // MARK: - Actions

    func bind(_ listener: Listener?) {
        self.listener = listener
    }

    func bindAndFire(_ listener: Listener?) {
        self.listener = listener
        listener?(value)
    }

    func fire() {
        listener?(value)
    }
}
