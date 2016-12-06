/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Custom NSScrubberItemView class for thumbnail images.
 */

import Cocoa

class ThumbnailItemView: NSScrubberItemView {
    
    private let imageView: NSImageView
    
    private let spinner: NSProgressIndicator
    
    private var thumbnail: NSImage {
        didSet {
            spinner.isHidden = true
            spinner.stopAnimation(nil)
            imageView.isHidden = false
            imageView.image = thumbnail
        }
    }
	
	var image: NSImage? {
        didSet {
            guard oldValue != image else { return }
            guard let image = image else {
                imageView.image = nil
                return
            }
			
            spinner.isHidden = false
            spinner.startAnimation(nil)
            imageView.isHidden = true
			
			let currentImage = image
            DispatchQueue.global(qos: .background).async {
                let imageSize = image.size
                let thumbnailHeight: CGFloat = 30
                let thumbnailSize = NSSize(width: ceil(thumbnailHeight * imageSize.width / imageSize.height), height: thumbnailHeight)
                
                let thumbnail = NSImage(size: thumbnailSize)
                thumbnail.lockFocus()
                image.draw(in: NSRect(origin: .zero, size: thumbnailSize), from: NSRect(origin: .zero, size: imageSize), operation: .sourceOver, fraction: 1.0)
                thumbnail.unlockFocus()
				
                DispatchQueue.main.async {
                    if currentImage === self.image {
                        self.thumbnail = thumbnail
                    }
                }
            }
        }
    }
    
    required override init(frame frameRect: NSRect) {
        image = nil
        thumbnail = NSImage(size: frameRect.size)
        imageView = NSImageView(image: thumbnail)
        imageView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        spinner = NSProgressIndicator()
        
        super.init(frame: frameRect)
        
        spinner.isIndeterminate = true
        spinner.style = .spinningStyle
        spinner.sizeToFit()
        spinner.frame = bounds.insetBy(dx: (bounds.width - spinner.frame.width)/2, dy: (bounds.height - spinner.frame.height)/2)
        spinner.isHidden = true
        spinner.controlSize = .small
        spinner.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
        spinner.autoresizingMask = [.viewMinXMargin, .viewMaxXMargin, .viewMinYMargin, .viewMaxXMargin]
        
        subviews = [imageView, spinner]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateLayer() {
        layer?.backgroundColor = NSColor.controlColor.cgColor
    }
    
    override func layout() {
        super.layout()
        
        imageView.frame = bounds
        spinner.sizeToFit()
        spinner.frame = bounds.insetBy(dx: (bounds.width - spinner.frame.width)/2, dy: (bounds.height - spinner.frame.height)/2)
    }
}
