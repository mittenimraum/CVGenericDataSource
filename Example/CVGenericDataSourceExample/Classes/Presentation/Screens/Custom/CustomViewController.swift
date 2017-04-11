//
//  CustomViewController.swift
//  CVGenericDataSourceExample
//
//  Created by Stephan Schulz on 11.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import Foundation
import UIKit
import CVGenericDataSource

class CustomViewController: ViewController {

    // MARK: - Outlets

    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Variables

    var viewModel: CustomViewModel!

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
        title = "Custom"
    }

    func setupCollectionView() {
        viewModel.dataSource?.bind(collectionView: collectionView)
    }
}
