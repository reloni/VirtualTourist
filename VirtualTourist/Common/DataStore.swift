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
	
	@discardableResult
	func addPhoto(to location: MapLocation, url: URL, rawPhoto: Data?) -> Photo {
		let photo = Photo(context: context)
		photo.data = rawPhoto as NSData?
		photo.urlString = url.absoluteString
		photo.location = location
		try! context.save()
		return photo
	}
	
	func update(photo: Photo, withData data: Data?) {
		photo.data = data as NSData?
		try! context.save()
	}
	
	func deletePhotos(forLocation location: MapLocation) {
		location.photos?.allObjects.forEach { context.delete($0 as! Photo) }
		try! context.save()
	}
	
	func photos(for location: MapLocation) -> [Photo] {
		return location.photos?.allObjects.map {
			let photo = $0 as! Photo
			photo.isSelected = false
			return photo
		} ?? []
	}
	
	@discardableResult
	func deleteSelectedPhotos(for location: MapLocation) -> [Photo] {
		location.photos?.allObjects.map { $0 as! Photo }.filter { $0.isSelected }.forEach { context.delete($0) }
		try! context.save()
		return photos(for: location)
	}
}
