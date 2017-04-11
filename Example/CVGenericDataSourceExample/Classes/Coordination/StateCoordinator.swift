//
//  StateCoordinator.swift
//  CVGenericDataSourceExample
//
//  Created by Stephan Schulz on 11.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import Foundation
import UIKit
import CVGenericDataSource

class StateCoordinator: NSObject, CoordinatorProtocol {

    // MARK: - Variables <CoordinatorProtocol>

    var parentCoordinator: CoordinatorProtocol?
    var childCoordinators: [CoordinatorProtocol] = []

    // MARK: - Variables

    var navigationController: UINavigationController!
    var stateViewController: StateViewController!

    // MARK: - Init

    init(parentCoordinator: CoordinatorProtocol?, navigationController: UINavigationController) {
        super.init()

        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
    }

    // MARK: - CoordinatorProtocol

    func start() {
        stateViewController = StateViewController(nibName: String(describing: StateViewController.self), bundle: nil)
        stateViewController.viewModel = StateViewModel(coordinator: self)

        navigationController.pushViewController(stateViewController, animated: true)
    }
}
