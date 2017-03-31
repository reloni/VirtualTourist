//
//  Extensions.swift
//  VirtualTourist
//
//  Created by Anton Efimenko on 30.01.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import MapKit

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

extension URLRequest {
	static func flickrPhotos(forLocation location: CLLocationCoordinate2D) -> URLRequest {
		let bbox =
			(minLon: location.longitude - 0.01, minLat: location.latitude - 0.01, maxLon: location.longitude + 0.01, maxLat: location.latitude + 0.01)
		
		let url = URL(baseUrl: "https://api.flickr.com/services/rest",
		              parameters: ["method": "flickr.photos.search",
		                           "safe_search": "1",
		                           "extras": "url_m",
		                           "per_page": "20",
		                           "page": "\(arc4random_uniform(200))",
		                           "format": "json",
		                           "nojsoncallback": "1",
		                           "api_key": "aabe16685306a6964bad3b38648b9192",
		                           "bbox": "\(bbox.minLon),\(bbox.minLat),\(bbox.maxLon),\(bbox.maxLat)"])!

		return URLRequest(url: url)
	}
}
extension Data {
	func toJson() throws -> [String: Any] {
		return try JSONSerialization.jsonObject(with: self, options: []) as! [String: Any]
	}
}
