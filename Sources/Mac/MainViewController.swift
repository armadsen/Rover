//
//  MainViewController.swift
//  Rover
//
//  Created by Andrew Madsen on 12/5/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		
		dataSource = MarsPhotoDataSource(collectionView: collectionView)
		collectionView.dataSource = dataSource
		collectionView.delegate = dataSource
		dataSource.loadData()
	}
	
	// Properties
	private var dataSource: MarsPhotoDataSource!
	
	@IBOutlet var collectionView: NSCollectionView!
}
