//
//  Interface.swift
//  CVGenericDataSourceExample
//
//  Created by Stephan Schulz on 11.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import Foundation
import UIKit

struct Interface {
    
    struct general {
        static let sectionInset = UIEdgeInsetsMake(0, 15, 0, 15)
        static let sectionSize = CGSize(width: UIScreen.main.bounds.width, height: CGFloat(52))
        static let lineSpacing: CGFloat = 15
    }

    struct basic {
        static let cellSize = CGSize(width: UIScreen.main.bounds.width - Interface.general.sectionInset.left - Interface.general.sectionInset.right, height: CGFloat(44))
        static let sectionInsets = UIEdgeInsetsMake(UIScreen.main.bounds.height * 0.2, 0, 0, 0)
    }
    
    struct state {
        static let sectionInset = UIEdgeInsetsMake(15, 15, 0, 15)
    }
}
