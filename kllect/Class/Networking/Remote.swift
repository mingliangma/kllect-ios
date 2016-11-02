//
//  Remote.swift
//  kllect
//
//  Created by Christopher Primerano on 2016-11-01.
//  Copyright © 2016 Kllect Inc. All rights reserved.
//

import Foundation
import ObjectMapper
import BrightFutures
import Result

class Remote {
	
	// Implement this as a function so it can be overridden in an extension if ever necessary
	class func baseUrlString() -> String {
		return "http://api.app.kllect.com/"
	}
	
	// Implement this as a function so it can be overridden in an extension if ever necessary
	class func youtubeBaseUrlString() -> String {
		return "https://www.youtube.com/embed/"
	}
	
	class func getVideosForPage(url: URL) -> Future<Page, KCTError> {
		// Return Future for network call
		return Future { complete in
			let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
				guard let data = data else {
					if let error = error {
						log.error("Network error on call: \(error)")
						complete(.failure(.networkError(error)))
					} else {
						log.error("Unknown Error occured")
						complete(.failure(.unknownError))
					}
					return
				}
				guard let jsonString = String(data: data, encoding: .utf8) else {
					log.error("Response data could not be converted to a String")
					complete(.failure(.notStringConvertable))
					return
				}
				// Use ObjectMapper to parse JSON directly into Swift object
				guard let page = Mapper<Page>().map(JSONString: jsonString) else {
					log.debug("Could not parse String as JSON/Not correct JSON for Swift object")
					complete(.failure(.malformedType))
					return
				}
				log.debug("Successfully retrieved Page: \(page)")
				complete(.success(page))
			}
			task.resume()
		}
	}
	
	// TODO: Probably a way to combine these two network calls into a single generic call
	class func getTags() -> Future<[Tag], KCTError> {
		
		let url = URL(string: Remote.baseUrlString().appending("tags"))!
		// Return Future for network call
		return Future { complete in
			let task = URLSession.shared.dataTask(with: url) { data, response, error in
				guard let data = data else {
					if let error = error {
						log.error("Network error on call: \(error)")
						complete(.failure(.networkError(error)))
					} else {
						log.error("Unknown Error occured")
						complete(.failure(.unknownError))
					}
					return
				}
				guard let jsonString = String(data: data, encoding: .utf8) else {
					log.error("Response data could not be converted to a String")
					complete(.failure(.notStringConvertable))
					return
				}
				// Use ObjectMapper to parse JSON directly into Swift object
				guard let tags = Mapper<Tag>().mapArray(JSONString: jsonString) else {
					log.debug("Could not parse String as JSON/Not correct JSON for Swift object")
					complete(.failure(.malformedType))
					return
				}
				log.debug("Successfully retrieved Tags: \(tags)")
				complete(.success(tags))
			}
			task.resume()
		}
		
	}
	
}
