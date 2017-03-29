//
//  Network.swift
//  VirtualTourist
//
//  Created by Anton Efimenko on 28.03.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import UIKit

typealias UrlRequestResult = (Data?, URLResponse?, Error?) -> ()

struct FlickrImage {
	let id: String
	let url: URL
	let image: UIImage?
}

extension FlickrImage {
	init?(json: [String: Any]) {
		guard let id: String = json["id"] as? String else { return nil }
		guard let url: URL = URL(string: json["url_m"] as? String ?? "") else { return nil }
		
		self.id = id
		self.url = url
		self.image = nil
	}
}

/// Represents response from network
enum NetworkRequestResult {
	case success([String: Any])
	case error(Data?, Error, HTTPURLResponse?)
}

enum ApiResult {
	case flickrImages([FlickrImage])
	case flickrImage(FlickrImage)
	case error(Error)
}

enum ApplicationErrors : Error {
	case jsonParseError(Error)
	case unknownNetworkError
}

final class NetworkClient {
	let session: URLSession
	
	init(session: URLSession = URLSession(configuration: .default)) {
		self.session = session
	}
	
	/// Executes URL request
	func execute(_ request: URLRequest, completion: @escaping UrlRequestResult) {
		print("Execute url: \(request.url?.absoluteString ?? "")")
		session.dataTask(with: request, completionHandler: completion).resume()
	}
}

final class FlickrClient {
	let networkClient: NetworkClient
	
	init(networkClient: NetworkClient = NetworkClient()) {
		self.networkClient = networkClient
	}
	
	func loadImagesList(completion: @escaping (ApiResult) -> Void) {
		let request = URLRequest.flickrPhotos()
		networkClient.execute(request, completion: FlickrClient.parseResponse(responseHandler: { result in
			switch result {
			case .success(let json):
				guard let images = json[jsonKey: "photos"]?["photo"] as? [[String: Any]] else {
					completion(ApiResult.flickrImages([]))
					return
				}

				completion(ApiResult.flickrImages(images.map { FlickrImage(json: $0) }.flatMap { $0 }))
			case .error(_, let error, _): completion(.error(error))
			}
		}))
	}
	
	func load(image: FlickrImage, completion: @escaping (ApiResult) -> Void) {
		let request = URLRequest(url: image.url)
		networkClient.execute(request) { result in
			if case NetworkRequestResult.error(_, let error, _)? = FlickrClient.checkError(data: result.0, response: result.1, error: result.2) {
				completion(.error(error))
			}
			
			let uiImage = UIImage(data: result.0!)
			completion(.flickrImage(FlickrImage(id: image.id, url: image.url, image: uiImage)))
		}
	}
	
	private static func checkError(data: Data?, response: URLResponse?, error: Error?) -> NetworkRequestResult? {
		guard let response = response as? HTTPURLResponse else {
			guard let error = error else {
				
				return .error(nil, ApplicationErrors.unknownNetworkError, nil)
			}
			
			return .error(nil, error, nil)
		}
		
		guard 200...299 ~= response.statusCode else {
			return .error(nil, ApplicationErrors.unknownNetworkError, response)
		}
		
		guard let _ = data else {
			guard let error = error else { return .error(nil, ApplicationErrors.unknownNetworkError, response) }
			return .error(data, error, response)
		}
		
		return nil
	}
	
	private static func parseResponse(responseHandler: @escaping (NetworkRequestResult) -> ()) -> UrlRequestResult {
		return { data, response, error in
			guard let response = response as? HTTPURLResponse else {
				guard let error = error else {
					responseHandler(.error(nil, ApplicationErrors.unknownNetworkError, nil))
					return
				}
				
				responseHandler(.error(nil, error, nil))
				
				return
			}
			
			guard 200...299 ~= response.statusCode else {
				responseHandler(.error(nil, ApplicationErrors.unknownNetworkError, response))
				return
			}
			
			guard let unwrappedData = data else {
				guard let error = error else { responseHandler(.error(nil, ApplicationErrors.unknownNetworkError, response)); return }
				responseHandler(.error(data, error, response))
				return
			}
			
			do {
				let json: [String: Any] = try unwrappedData.toJson()
				responseHandler(.success(json))
			} catch let e {
				responseHandler(.error(data, ApplicationErrors.jsonParseError(e), response))
			}
		}
	}
}
