//
//  SynchronizationCoordinator.swift
//  CVGenericDataSourceExample
//
//  Created by Stephan Schulz on 11.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import Foundation
import UIKit
import CVGenericDataSource

class SynchronizationCoordinator: NSObject, CoordinatorProtocol {

    // MARK: - Variables <CoordinatorProtocol>

    var parentCoordinator: CoordinatorProtocol?
    var childCoordinators: [CoordinatorProtocol] = []

    // MARK: - Variables

    var navigationController: UINavigationController!
    var synchronizationViewController: SynchronizationViewController!

    // MARK: - Init

    init(parentCoordinator: CoordinatorProtocol?, navigationController: UINavigationController) {
        super.init()

        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
    }

    // MARK: - CoordinatorProtocol

    func start() {
        synchronizationViewController = SynchronizationViewController(nibName: String(describing: CustomViewController.self), bundle: nil)
        synchronizationViewController.viewModel = SynchronizationViewModel(coordinator: self)

        navigationController.pushViewController(synchronizationViewController, animated: true)
    }
}
