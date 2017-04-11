//
//  SynchronizationCell.swift
//  CVGenericDataSourceExample
//
//  Created by Stephan Schulz on 11.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import Foundation
import UIKit
import CVGenericDataSource

class SynchronizationCell: CVCell {

    // MARK: - Outlets

    @IBOutlet weak var label: UILabel!

    // MARK: - Variables

    override class var ReuseIdentifier: String {
        return String(describing: SynchronizationCell.self)
    }

    override class var NibName: String {
        return String(describing: SynchronizationCell.self)
    }
}
