//
//  LoadingCoordinator.swift
//  CVGenericDataSourceExample
//
//  Created by Stephan Schulz on 22.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import Foundation
import UIKit
import CVGenericDataSource

class LoadingCoordinator: NSObject, CoordinatorProtocol {
    
    // MARK: - Variables <CoordinatorProtocol>
    
    var parentCoordinator: CoordinatorProtocol?
    var childCoordinators: [CoordinatorProtocol] = []
    
    // MARK: - Variables
    
    var navigationController: UINavigationController!
    var loadingViewController: LoadingViewController!
    
    // MARK: - Init
    
    init(parentCoordinator: CoordinatorProtocol?, navigationController: UINavigationController) {
        super.init()
        
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
    }
    
    // MARK: - CoordinatorProtocol
    
    func start() {
        loadingViewController = LoadingViewController(nibName: String(describing: LoadingViewController.self), bundle: nil)
        loadingViewController.viewModel = LoadingViewModel(coordinator: self)
        
        navigationController.pushViewController(loadingViewController, animated: true)
    }
}
