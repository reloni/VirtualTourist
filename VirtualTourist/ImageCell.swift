//
//  ImageCell.swift
//  VirtualTourist
//
//  Created by Anton Efimenko on 21.03.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	override func prepareForReuse() {
		imageView.image = nil
		imageView.alpha = 1
	}
	
	func loading() {
		imageView.image = nil
		imageView.alpha = 1
		activityIndicator.isHidden = false
		activityIndicator.startAnimating()
	}
	
	func set(image: UIImage) {
		imageView.alpha = 1
		imageView.image = image
		activityIndicator.stopAnimating()
		activityIndicator.isHidden = true
	}
	
	func select() {
		imageView.alpha = 0.5
	}
	
	func deselect() {
		imageView.alpha = 1
	}
	
	func changeSelectedState() {
		if !isImageSelected {
			select()
		} else {
			deselect()
		}
	}
	
	var isImageSelected: Bool {
		return imageView.alpha != 1
	}
}
