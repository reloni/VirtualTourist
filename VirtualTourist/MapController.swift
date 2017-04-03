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
	enum PinMode {
		case add
		case delete
	}
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var deleteButtonHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var editButton: UIBarButtonItem!
	
	var mode = PinMode.add

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		deleteButtonHeightConstraint.constant = 0
		
		if let center = UserDefaults.standard.userMapPosition, let span = UserDefaults.standard.userMapSpan {
			mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
		}
		
		let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(addPin))
		recognizer.minimumPressDuration = 1.0
		mapView.addGestureRecognizer(recognizer)
		
		loadLocations()
	}
	
	func loadLocations() {
		dataStore.locations().forEach { 
			let annotation = MapLocationAnnotation(mapLocation: $0)
			annotation.coordinate = $0.coordinate
			self.mapView.addAnnotation(annotation)
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func editTap(_ sender: Any) {
		if mode == .add {
			deleteButtonHeightConstraint.constant = 60
			mode = .delete
			editButton.title = "Done"
		} else {
			deleteButtonHeightConstraint.constant = 0
			mode = .add
			editButton.title = "Edit"
		}
		
		UIView.animate(withDuration: 0.5, animations: { self.view.layoutIfNeeded() })
	}
	
	func addPin(gestureRecognizer: UIGestureRecognizer) {
		guard mode == .add else { return }
		
		guard gestureRecognizer.state == .began else { return }
		
		let coordinate = mapView.convert(gestureRecognizer.location(in: mapView), toCoordinateFrom: mapView)
		
		let location = dataStore.addLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
		
		let annotation = MapLocationAnnotation(mapLocation: location)
		annotation.coordinate = location.coordinate
		mapView.addAnnotation(annotation)
	}
	
	func showDetailController(forLocation location: MapLocation) {
		let controller = storyboard!.instantiateViewController(withIdentifier: "DetailController") as! DetailController
		controller.location = location
		navigationController?.pushViewController(controller, animated: true)
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
				pin.canShowCallout = false
				pin.animatesDrop = true
				return pin
			}
			return view
		}()
		
		return pinView
	}
	
	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
	
	}
	
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		guard let annotation = view.annotation as? MapLocationAnnotation else { return }
		
		mapView.deselectAnnotation(annotation, animated: false)
		
		switch mode {
		case .add: showDetailController(forLocation: annotation.mapLocation)
		case .delete:
			dataStore.remove(location: annotation.mapLocation)
			mapView.removeAnnotation(annotation)
		}
	}
	
	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		UserDefaults.standard.userMapPosition = mapView.region.center
		UserDefaults.standard.userMapSpan = mapView.region.span
	}
}
