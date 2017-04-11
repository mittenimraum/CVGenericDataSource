//
//  StateLoadingCell.swift
//  CVGenericDataSourceExample
//
//  Created by Stephan Schulz on 11.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import Foundation
import UIKit
import CVGenericDataSource

class StateLoadingCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Variables
    
    override class var ReuseIdentifier: String {
        return String(describing: StateLoadingCell.self)
    }
    
    override class var NibName: String {
        return String(describing: StateLoadingCell.self)
    }

    // MARK: - Life Cycle

    override func prepare() {
        activityIndicator.startAnimating()
    }
}
