//
//  MapLocationAnnotation.swift
//  VirtualTourist
//
//  Created by Anton Efimenko on 01.04.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import MapKit

final class MapLocationAnnotation : MKPointAnnotation {
	let mapLocation: MapLocation
	
	init(mapLocation: MapLocation) {
		self.mapLocation = mapLocation
		super.init()
	}
}
