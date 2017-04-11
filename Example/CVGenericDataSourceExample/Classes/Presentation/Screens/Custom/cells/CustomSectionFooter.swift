//
//  CustomSectionFooter.swift
//  CVGenericDataSourceExample
//
//  Created by Stephan Schulz on 18.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import Foundation
import UIKit
import CVGenericDataSource

class CustomSectionFooter: CVSupplementaryView {

    // MARK: - Variables

    override class var ReuseIdentifier: String {
        return String(describing: CustomSectionFooter.self)
    }

    override class var NibName: String {
        return String(describing: CustomSectionFooter.self)
    }
}
