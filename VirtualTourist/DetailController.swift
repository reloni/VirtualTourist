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
	
	override func viewDidLoad() {
		super.viewDidLoad()

		mapView.setRegion(MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: false)
	}
}
