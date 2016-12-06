//
//  Observe.swift
//  MixedInKey
//
//  Created by Andrew Madsen on 12/16/15.
//  Copyright © 2015 Mixed In Key LLC. All rights reserved.
//

import Foundation

protocol KVOAble: NSObjectProtocol {
	func addObserver(_ observer: NSObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions, context: UnsafeMutableRawPointer?)
	func removeObserver(_ observer: NSObject, forKeyPath keyPath: String, context: UnsafeMutableRawPointer?)
}

extension NSObject: KVOAble {}

class Observe : NSObject {
	
	init(_ objectToObserve: KVOAble, keyPath: String, options: NSKeyValueObservingOptions = [], observationBlock: @escaping (AnyObject?) -> Void) {
		self.objectToObserve = objectToObserve
		self.keyPath = keyPath
		self.observationBlock = observationBlock
		
		super.init()
		
		objectToObserve.addObserver(self, forKeyPath: keyPath, options: options, context: &KVOContext)
	}
	
	deinit {
		self.objectToObserve.removeObserver(self, forKeyPath: self.keyPath, context: &KVOContext)
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		guard let keyPath = keyPath, let object = object else { return }
		
		// Make sure the notification is intended for us, and not a superclass
		if context != &KVOContext {
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
			return
		}
		
		let newValue = (object as AnyObject).value(forKeyPath: keyPath)
		self.observationBlock(newValue as AnyObject?)
	}
	
	let objectToObserve: KVOAble
	let keyPath: String
	let observationBlock: (AnyObject?) -> Void
	
	fileprivate var KVOContext = 1
}
