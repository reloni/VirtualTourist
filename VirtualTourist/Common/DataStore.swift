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
	private let queue = DispatchQueue(label: "CoreDataQueue", qos: .background)
	
	private var context: NSManagedObjectContext {
		return persistentContainer.viewContext
	}
	
	lazy var persistentContainer: NSPersistentContainer = {
		return self.queue.sync {
			//NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
			let container = NSPersistentContainer(name: "VirtualTourist")
			//container.viewContext.concurrencyType = .privateQueueConcurrencyType
			container.loadPersistentStores(completionHandler: { (storeDescription, error) in
				if let error = error as NSError? {
					fatalError("Unresolved error \(error), \(error.userInfo)")
				}
				
			})
			return container
		}
	}()
//	var persistentContainer: NSPersistentContainer!

	init() {
		print("CREATE")
//		 explicitly loading container
		_ = persistentContainer
//		queue.sync {
//			persistentContainer = NSPersistentContainer(name: "VirtualTourist")
//			persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
//				if let error = error as NSError? {
//					fatalError("Unresolved error \(error), \(error.userInfo)")
//				}
//			})
//		}
	}
	
	func locations() -> [MapLocation] {
		return queue.sync {
			return try! context.fetch(NSFetchRequest(entityName: "MapLocation")).map { $0 as! MapLocation }
		}
	}
	
	func remove(location: MapLocation) {
		queue.sync {
			context.delete(location)
			try! context.save()
		}
	}
	
	func addLocation(latitude: Double, longitude: Double) -> MapLocation {
		return queue.sync {
			let location = MapLocation(context: context)
			location.latitude = latitude
			location.longitude = longitude
			try! context.save()
			return location
		}
	}
	
	@discardableResult
	func addPhoto(to location: MapLocation, url: URL, rawPhoto: Data?) -> Photo {
		return queue.sync {
			let photo = Photo(context: context)
			photo.data = rawPhoto as NSData?
			photo.urlString = url.absoluteString
			photo.location = location
			try! context.save()
			return photo
		}
	}
	
	func update(photo: Photo, withData data: Data?) {
		queue.sync {
			photo.data = data as NSData?
			try! context.save()
		}
	}
	
	func deletePhotos(forLocation location: MapLocation) {
		queue.sync {
			location.photos?.allObjects.forEach { context.delete($0 as! Photo) }
			try! context.save()
		}
	}
	
	func photos(for location: MapLocation) -> [Photo] {
		return queue.sync {
			return location.photos?.allObjects.map {
				let photo = $0 as! Photo
				photo.isSelected = false
				return photo
				} ?? []
		}
	}
	
	@discardableResult
	func deleteSelectedPhotos(for location: MapLocation) -> [Photo] {
		return queue.sync {
			location.photos?.allObjects.map { $0 as! Photo }.filter { $0.isSelected }.forEach { context.delete($0) }
			try! context.save()
			return photos(for: location)
		}
	}
	
	func loadSync<T: NSManagedObject>(id: NSManagedObjectID) -> T {
		return sync {
			return context.object(with: id) as! T
		}
	}
	
	func sync<T>(execute: () -> T) -> T {
		return queue.sync {
			return execute()
		}
	}
}
