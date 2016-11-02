//
//  Remote.swift
//  kllect
//
//  Created by Christopher Primerano on 2016-11-01.
//  Copyright © 2016 Kllect. All rights reserved.
//

import Foundation
import ObjectMapper
import BrightFutures
import Result

class Remote {
	
	class func baseUrlString() -> String {
		return "http://api.app.kllect.com/"
	}
	
	class func getVideosForPage(url: URL) -> Future<Page, KCTError> {
		
		return Future { complete in
			let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
				guard let data = data else {
					if let error = error {
						complete(.failure(.networkError(error)))
					} else {
						complete(.failure(.unknownError))
					}
					return
				}
				guard let jsonString = String(data: data, encoding: .utf8) else {
					complete(.failure(.notStringConvertable))
					return
				}
				guard let page = Mapper<Page>().map(JSONString: jsonString) else {
					complete(.failure(.malformedType))
					return
				}
				complete(.success(page))
			}
			task.resume()
		}
	}
	
	class func getTags() -> Future<[Tag], KCTError> {
		
		let url = URL(string: Remote.baseUrlString().appending("tags"))!
		
		return Future { complete in
			let task = URLSession.shared.dataTask(with: url) { data, response, error in
				guard let data = data else {
					if let error = error {
						complete(.failure(.networkError(error)))
					} else {
						complete(.failure(.unknownError))
					}
					return
				}
				guard let jsonString = String(data: data, encoding: .utf8) else {
					complete(.failure(.notStringConvertable))
					return
				}
				guard let tags = Mapper<Tag>().mapArray(JSONString: jsonString) else {
					complete(.failure(.malformedType))
					return
				}
				complete(.success(tags))
			}
			task.resume()
		}
		
	}
	
}
