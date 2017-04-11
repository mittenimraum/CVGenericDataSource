//
//  StateEmptyCell.swift
//  CVGenericDataSourceExample
//
//  Created by Stephan Schulz on 11.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import Foundation
import CVGenericDataSource

class StateEmptyCell: UICollectionViewCell {

    // MARK: - Variables
    
    override class var ReuseIdentifier: String {
        return String(describing: StateEmptyCell.self)
    }
    
    override class var NibName: String {
        return String(describing: StateEmptyCell.self)
    }
}
