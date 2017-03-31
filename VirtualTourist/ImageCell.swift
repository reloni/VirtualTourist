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
	}
}
