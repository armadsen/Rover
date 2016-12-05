//
//  PlatformShims.swift
//  Rover
//
//  Created by Andrew Madsen on 12/5/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation

#if os(iOS)
	import UIKit
	typealias Image = UIImage
	typealias CollectionView = UICollectionView
	typealias CollectionViewDataSource = UICollectionViewDataSource
	typealias CollectionViewDelegate = UICollectionViewDelegate
	typealias CollectionViewCell = UICollectionViewCell
#else
	import Cocoa
	typealias Image = NSImage
	typealias CollectionView = NSCollectionView
	typealias CollectionViewDataSource = NSCollectionViewDataSource
	typealias CollectionViewDelegate = NSCollectionViewDelegate
	typealias CollectionViewCell = NSCollectionViewItem
	typealias ImageCollectionViewCell = NSCollectionViewItem
#endif
