//
//  MapController.swift
//  VirtualTourist
//
//  Created by Anton Efimenko on 29.01.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit
import MapKit

class MapController: UIViewController {
	@IBOutlet weak var mapView: MKMapView!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		if let center = UserDefaults.standard.userMapPosition, let span = UserDefaults.standard.userMapSpan {
			mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func editTap(_ sender: Any) {
	}
}

extension MapController : MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if annotation is MKUserLocation {
			return nil
		}
		
		let pinView: MKPinAnnotationView = {
			guard let view = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView else {
				let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
				pin.canShowCallout = true
				pin.animatesDrop = true
				pin.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
				return pin
			}
			return view
		}()
		
		return pinView
	}
	
	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
	}
	
	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		UserDefaults.standard.userMapPosition = mapView.region.center
		UserDefaults.standard.userMapSpan = mapView.region.span
	}
}
