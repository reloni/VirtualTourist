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
	enum Mode {
		case delete
		case newCollection
	}
	
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var newCollectionButton: UIButton!
	
	var location: MapLocation!
	var mode: Mode {
		return (images.first(where: { $0.isSelected }) == nil) ? .newCollection : .delete
	}
	
	var buttonTitle: String {
		switch mode {
		case .delete: return "Remove Selected Pictures"
		case .newCollection: return "New Collection"
		}
	}
	
	let sectionInsets = UIEdgeInsets(top: 10.0, left: 15.0, bottom: 10.0, right: 15.0)
	let itemsPerRow: CGFloat = 3
	
	var images = [Photo]()
	
	override func viewDidLoad() {
		super.viewDidLoad()

		mapView.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: false)
		
		images = dataStore.photos(for: location)
		
		print("images: \(images.count)")
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if images.count == 0 {
			loadImages()
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
	}
	
	func loadImages() {
		flickrClient.loadImagesList(forLocation: location.coordinate) { [weak self] result in
			if case ApiResult.error(let error) = result {
				print("Error: \(error.localizedDescription)")
			} else if case ApiResult.flickrImages(let images) = result {
				DispatchQueue.main.async {
					guard let object = self else { return }
					images.forEach {
						object.dataStore.addPhoto(to: object.location, url: $0.url, rawPhoto: nil)
					}
					self?.images = object.location.photos?.allObjects.map { $0 as! Photo } ?? []
					
					self?.collectionView.reloadSections(IndexSet(integer: 0))
				}
			}
		}
	}
	
	@IBAction func buttonTapped(_ sender: Any) {
		switch mode {
		case .delete: deleteSelectedPhotos()
		case .newCollection: newCollection()
		}
	}
	
	func newCollection() {
		dataStore.deletePhotos(forLocation: location)
		images.removeAll()
		collectionView.reloadSections(IndexSet(integer: 0))
		loadImages()
	}
	
	func deleteSelectedPhotos() {
		images = dataStore.deleteSelectedPhotos(for: location)
		collectionView.reloadSections(IndexSet(integer: 0))
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
		let photo = images[indexPath.row]
		if let img = photo.image {
			cell.set(image: img)
		} else {
			cell.loading()
			flickrClient.load(image: photo) { result in

				if case ApiResult.flickrImage(let loaded) = result, let newImage = loaded.image {
					DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
						self.dataStore.update(photo: photo, withData: UIImageJPEGRepresentation(newImage, 1))
						
						cell.set(image: newImage)
					}
				}
			}
		}
		return cell
	}
}

extension DetailController : UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath) as! ImageCell
		cell.changeSelectedState()
		images[indexPath.row].isSelected = !images[indexPath.row].isSelected
		newCollectionButton.setTitle(buttonTitle, for: .normal)
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
