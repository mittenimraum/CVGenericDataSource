//
//  LoadingViewController.swift
//  CVGenericDataSourceExample
//
//  Created by Stephan Schulz on 22.04.17.
//  Copyright © 2017 Stephan Schulz. All rights reserved.
//

import Foundation
import UIKit
import CVGenericDataSource

class LoadingViewController: ViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Variables
    
    var viewModel: LoadingViewModel!
    
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
        title = "Progressive Loading"
    }
    
    func setupCollectionView() {
        viewModel.dataSource?.bind(collectionView: collectionView)
    }
}
