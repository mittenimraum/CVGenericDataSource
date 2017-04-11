//
//  CustomCoordinator.swift
//  CVGenericDataSourceExample
//
//  Created by Stephan Schulz on 11.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import Foundation
import UIKit
import CVGenericDataSource

class CustomCoordinator: NSObject, CoordinatorProtocol {

    // MARK: - Variables <CoordinatorProtocol>

    var parentCoordinator: CoordinatorProtocol?
    var childCoordinators: [CoordinatorProtocol] = []

    // MARK: - Variables

    var navigationController: UINavigationController!
    var customViewController: CustomViewController!

    // MARK: - Init

    init(parentCoordinator: CoordinatorProtocol?, navigationController: UINavigationController) {
        super.init()

        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
    }

    // MARK: - CoordinatorProtocol

    func start() {
        customViewController = CustomViewController(nibName: String(describing: CustomViewController.self), bundle: nil)
        customViewController.viewModel = CustomViewModel(coordinator: self)
        
        navigationController.pushViewController(customViewController, animated: true)
    }
}
