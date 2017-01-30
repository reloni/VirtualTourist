//
//  Extensions.swift
//  VirtualTourist
//
//  Created by Anton Efimenko on 30.01.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import MapKit

extension UserDefaults {
	var userMapPosition: CLLocationCoordinate2D? {
		get {
			guard let lat = object(forKey: "MapPositionLatitude") as? Double else { return nil }
			guard let lon = object(forKey: "MapPositionLongitude") as? Double else { return nil }
			return CLLocationCoordinate2D(latitude: lat, longitude: lon)
		}
		set {
			set(newValue?.latitude, forKey: "MapPositionLatitude")
			set(newValue?.longitude, forKey: "MapPositionLongitude")
		}
	}
	
	var userMapSpan: MKCoordinateSpan? {
		get {
			guard let lat = object(forKey: "MapSpanLatitudeDelta") as? Double else { return nil }
			guard let lon = object(forKey: "MapSpanLongitudeDelta") as? Double else { return nil }
			return MKCoordinateSpan(latitudeDelta: lat, longitudeDelta: lon)
		}
		set {
			set(newValue?.latitudeDelta, forKey: "MapSpanLatitudeDelta")
			set(newValue?.longitudeDelta, forKey: "MapSpanLongitudeDelta")
		}
	}
}
