//
//  Coordinator.swift
//  Panic
//
//  Created by Stephan Schulz on 31.01.17.
//  Copyright © 2017 wycomco GmbH. All rights reserved.
//

import UIKit
import CVGenericDataSource

// MARK: - CoordinatorProtocol

protocol CoordinatorProtocol: NSObjectProtocol {
    var parentCoordinator: CoordinatorProtocol? { get set }
    var childCoordinators: [CoordinatorProtocol] { get set }

    func start()
    func finish()
    func cancel()
    func dispose()
    func childCoordinatorDidFinish(_ coordinator: CoordinatorProtocol)
    func childCoordinatorDidCancel(_ coordinator: CoordinatorProtocol)
    func childCoordinatorDidDispose(_ coordinator: CoordinatorProtocol)
    func getChildCoordinator(_ coordinator: AnyClass) -> CoordinatorProtocol?
}

extension CoordinatorProtocol {

    func finish() {
        parentCoordinator?.childCoordinatorDidFinish(self)

        dispose()
    }

    func cancel() {
        parentCoordinator?.childCoordinatorDidCancel(self)

        dispose()
    }

    func dispose() {
        for childCoordinator in childCoordinators.enumerated().reversed() {
            childCoordinator.element.dispose()

            removeChildCoordinator(childCoordinator.element)
        }
        parentCoordinator?.childCoordinatorDidDispose(self)
    }

    func addChildCoordinator(_ coordinator: CoordinatorProtocol) {
        childCoordinators.append(coordinator)
    }

    func removeChildCoordinator(_ coordinator: CoordinatorProtocol) {
        if let index = childCoordinators.index(where: { $0 === coordinator }) {
            childCoordinators.remove(at: index)
        }
    }

    func childCoordinatorDidFinish(_ coordinator: CoordinatorProtocol) {
        removeChildCoordinator(coordinator)
    }

    func childCoordinatorDidCancel(_ coordinator: CoordinatorProtocol) {
        removeChildCoordinator(coordinator)
    }

    func childCoordinatorDidDispose(_: CoordinatorProtocol) {
    }

    func getChildCoordinator(_ coordinator: AnyClass) -> CoordinatorProtocol? {
        for childCoordinator in childCoordinators {
            if type(of: childCoordinator) === coordinator {
                return childCoordinator
            }
        }
        return nil
    }
}

// MARK: - Coordinator

class Coordinator: NSObject, CoordinatorProtocol {

    // MARK: - Variables <CoordinatorProtocol>

    var childCoordinators: [CoordinatorProtocol] = []
    var parentCoordinator: CoordinatorProtocol?

    // MARK: - Variables

    var application: UIApplication?

    // Controllers

    var rootViewController: BasicViewController!
    var navigationController: UINavigationController!

    // MARK: - Init

    init(application: UIApplication?) {
        self.application = application
    }

    // MARK: - CoordinatorProtocol

    func start() {
        setupRootViewController()
    }

    // MARK: - Setup

    func setupRootViewController() {
        rootViewController = BasicViewController(nibName: String(describing: BasicViewController.self), bundle: nil)
        rootViewController.viewModel = BasicViewModel(coordinator: self)

        navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.navigationBar.isTranslucent = false
        
        application?.delegate?.window??.rootViewController = navigationController
        application?.delegate?.window??.makeKeyAndVisible()
    }

    // MARK: - Childs

    func openCustomExample() {
        let coordinator = CustomCoordinator(parentCoordinator: self, navigationController: navigationController)
        coordinator.start()

        childCoordinators.append(coordinator)
    }

    func openSynchronizationExample() {
        let coordinator = SynchronizationCoordinator(parentCoordinator: self, navigationController: navigationController)
        coordinator.start()

        childCoordinators.append(coordinator)
    }

    func openStateExample() {
        let coordinator = StateCoordinator(parentCoordinator: self, navigationController: navigationController)
        coordinator.start()

        childCoordinators.append(coordinator)
    }
    
    func openLoadingExample() {
        let coordinator = LoadingCoordinator(parentCoordinator: self, navigationController: navigationController)
        coordinator.start()
        
        childCoordinators.append(coordinator)
    }
}
