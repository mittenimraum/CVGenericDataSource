//
//  ViewController.swift
//  CVGenericDataSourceExample
//
//  Created by Stephan Schulz on 11.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Variables

    var didLayoutSubviews = false
    var didViewAppear = false

    // MARK: - Life Cycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !didViewAppear else {
            return
        }
        didViewAppear = true

        viewDidAppearFirstTime()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard !didLayoutSubviews else {
            return
        }
        didLayoutSubviews = true

        viewDidLayout()
    }

    // The method is called between viewWillAppear and viewDidAppear, it ensures that
    // the constraints have been computed and that the subviews have a correct frame value
    func viewDidLayout() {
    }

    // Called only once
    func viewDidAppearFirstTime() {
    }
}
