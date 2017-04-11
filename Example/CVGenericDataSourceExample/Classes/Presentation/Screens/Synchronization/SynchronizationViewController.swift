//
//  SynchronizationViewController.swift
//  CVGenericDataSourceExample
//
//  Created by Stephan Schulz on 11.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import Foundation
import UIKit
import CVGenericDataSource

class SynchronizationViewController: ViewController {

    // MARK: - Outlets

    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Variables

    var viewModel: SynchronizationViewModel!
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupCollectionView()
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        guard parent == nil else {
            return
        }
        viewModel.dispose()
    }

    // MARK: - Setup

    func setupNavigationBar() {
        title = "Synchronization"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Synchronize", style: .plain, target: self, action: #selector(didTouchUpSynchronize))
    }

    func setupCollectionView() {
        viewModel.dataSource?.bind(collectionView: collectionView)
    }

    // MARK: - Target Actions

    func didTouchUpSynchronize() {
        viewModel.didTouchUpSynchronize()
    }
}
