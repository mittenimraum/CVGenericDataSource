//
//  StateViewController.swift
//  CVGenericDataSourceExample
//
//  Created by Stephan Schulz on 11.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import Foundation
import UIKit

class StateViewController: ViewController {

    // MARK: - Outlets

    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Variables

    var viewModel: StateViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
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
        title = "State"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reload", style: .plain, target: self, action: #selector(didTouchUpReload))
    }

    func setupCollectionView() {
        viewModel.dataSource?.bind(collectionView: collectionView)
    }

    // MARK: - Target Actions

    func didTouchUpReload() {
        viewModel.reload()
    }
}
