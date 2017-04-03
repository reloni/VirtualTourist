//
//  Extensions.swift
//  VirtualTourist
//
//  Created by Anton Efimenko on 30.01.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import MapKit

extension MapLocation {
	var coordinate: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
	}
}

extension Photo {
	var url: URL {
		return URL(baseUrl: urlString!)!
	}
	
	var image: UIImage? {
		guard let data = data as Data? else { return nil }
		return UIImage(data: data)
	}
}

extension UIViewController {
	var dataStore: DataStore {
		return (UIApplication.shared.delegate as! AppDelegate).dataStore
	}
}

public extension URL {
	init?(baseUrl: String, parameters: [String: String]? = nil) {
		var components = URLComponents(string: baseUrl)
		components?.queryItems = parameters?.map { key, value in
			URLQueryItem(name: key, value: value)
		}
		
		guard let absoluteString = components?.url?.absoluteString else { return nil }
		
		self.init(string: absoluteString)
	}
}

extension Dictionary {
	subscript(jsonKey key: Key) -> [String:Any]? {
		return self[key] as? [String:Any]
	}
}

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

extension CLLocationCoordinate2D {
	var bbox: String {
		let box = (minLon: longitude - 0.03, minLat: latitude - 0.03, maxLon: longitude + 0.03, maxLat: latitude + 0.03)
		return "\(box.minLon),\(box.minLat),\(box.maxLon),\(box.maxLat)"
	}
}

extension URLRequest {
	static let flickrApiKey = "aabe16685306a6964bad3b38648b9192"
	
	static func flickrPhotosPagesCount(forLocation location: CLLocationCoordinate2D) -> URLRequest {
		let url = URL(baseUrl: "https://api.flickr.com/services/rest",
		              parameters: ["method": "flickr.photos.search",
		                           "safe_search": "1",
		                           "extras": "url_m",
		                           "per_page": "1",
		                           "page": "1",
		                           "format": "json",
		                           "nojsoncallback": "1",
		                           "api_key": flickrApiKey,
		                           "bbox": location.bbox])!
		
		return URLRequest(url: url)
	}
	
	static func flickrPhotos(forLocation location: CLLocationCoordinate2D, page: UInt32 = 1, itemsPerPage: UInt32 = 20) -> URLRequest {
		let url = URL(baseUrl: "https://api.flickr.com/services/rest",
		              parameters: ["method": "flickr.photos.search",
		                           "safe_search": "1",
		                           "extras": "url_m",
		                           "per_page": "\(itemsPerPage)",
		                           "page": "\(page)",
		                           "format": "json",
		                           "nojsoncallback": "1",
		                           "api_key": flickrApiKey,
		                           "bbox": location.bbox])!

		return URLRequest(url: url)
	}
}
extension Data {
	func toJson() throws -> [String: Any] {
		return try JSONSerialization.jsonObject(with: self, options: []) as! [String: Any]
	}
}
