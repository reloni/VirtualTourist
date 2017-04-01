//
//  DataStore.swift
//  VirtualTourist
//
//  Created by Anton Efimenko on 01.04.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import CoreData

final class DataStore {
	private let context: NSManagedObjectContext

	init(context: NSManagedObjectContext) {
		self.context = context
	}
	
	func locations() -> [MapLocation] {
		return try! context.fetch(NSFetchRequest(entityName: "MapLocation")).map { $0 as! MapLocation }
	}
	
	func remove(location: MapLocation) {
		context.delete(location)
		try! context.save()
	}
	
	func addLocation(latitude: Double, longitude: Double) -> MapLocation {
		let location = MapLocation(context: context)
		location.latitude = latitude
		location.longitude = longitude
		try! context.save()
		return location
	}
}
