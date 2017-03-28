//
//  Network.swift
//  VirtualTourist
//
//  Created by Anton Efimenko on 28.03.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation

typealias UrlRequestResult = (Data?, URLResponse?, Error?) -> ()

struct FlickrImage {
	let url: URL
}

/// Represents response from network
enum NetworkRequestResult {
	case success([String: Any])
	case error(Data?, Error, HTTPURLResponse?)
}

enum ApiResult {
	case flickrImages([FlickrImage])
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
			case .success(let json): print(json)
			case .error(_, let error, _): completion(.error(error))
			}
		}))
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
				responseHandler(.error(nil, ApplicationErrors.unknownNetworkError, nil))
				return
			}
			
			guard let unwrappedData = data else {
				guard let error = error else { responseHandler(.error(nil, ApplicationErrors.unknownNetworkError, nil)); return }
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
