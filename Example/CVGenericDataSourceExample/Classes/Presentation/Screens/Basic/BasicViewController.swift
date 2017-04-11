//
//  BasicViewController.swift
//  CVGenericDataSourceExample
//
//  Created by Stephan Schulz on 11.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import UIKit
import CVGenericDataSource

class BasicViewController: ViewController {

    // MARK: - Outlets

    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Variables

    var viewModel: BasicViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupCollectionView()
    }

    // MARK: - Setup

    func setupNavigationBar() {
        title = "Basic"
    }

    func setupCollectionView() {
        viewModel.dataSource?.bind(collectionView: collectionView)
    }
}
