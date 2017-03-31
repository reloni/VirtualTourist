//
//  DetailController.swift
//  VirtualTourist
//
//  Created by Anton Efimenko on 21.03.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit
import MapKit

class DetailController: UIViewController {
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var collectionView: UICollectionView!
	
	var location: CLLocationCoordinate2D!
	
	let sectionInsets = UIEdgeInsets(top: 10.0, left: 15.0, bottom: 10.0, right: 15.0)
	let itemsPerRow: CGFloat = 3
	
	var images = [FlickrImage]()
	
	override func viewDidLoad() {
		super.viewDidLoad()

		mapView.setRegion(MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: false)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		loadImages()
	}
	
	func loadImages() {
		flickrClient.loadImagesList(forLocation: location) { [weak self] result in
			if case ApiResult.error(let error) = result {
				print("Error: \(error.localizedDescription)")
			} else if case ApiResult.flickrImages(let images) = result {
				self?.images = images
				DispatchQueue.main.async { self?.collectionView.reloadSections(IndexSet(integer: 0)) }
			}
		}
	}
	
	@IBAction func newCollection(_ sender: Any) {
		images.removeAll()
		collectionView.reloadSections(IndexSet(integer: 0))
		loadImages()
	}
	
}

extension DetailController : UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return images.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
		let image = images[indexPath.row]
		if let img = image.image {
			cell.imageView.image = img
		} else {
			cell.activityIndicator.startAnimating()
			flickrClient.load(image: image) { result in
				DispatchQueue.main.async {
					cell.activityIndicator.stopAnimating()
					cell.activityIndicator.isHidden = true
				}
				if case ApiResult.flickrImage(let loaded) = result, let newImage = loaded.image {
					DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
						cell.imageView.image = newImage
					}
				}
			}
		}
		return cell
	}
}

extension DetailController : UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
	}
}

extension DetailController : UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
		let availableWidth = view.frame.width - paddingSpace
		let widthPerItem = availableWidth / itemsPerRow
		
		return CGSize(width: widthPerItem, height: widthPerItem)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return sectionInsets
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return sectionInsets.left
	}
}
