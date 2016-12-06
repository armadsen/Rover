//
//  MainViewController.swift
//  Rover
//
//  Created by Andrew Madsen on 11/1/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class CollectionViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		collectionView.dataSource = dataSource
		dataSource.collectionView = collectionView
	}
	
	// Properties
	private let dataSource = MarsPhotosDataSource()
	
	@IBOutlet var collectionView: UICollectionView!
}
