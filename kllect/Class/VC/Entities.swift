//
//  Entities.swift
//  kllect
//
//  Created by Christopher Primerano on 2016-10-02.
//  Copyright © 2016 topmobile. All rights reserved.
//

import Foundation
import ObjectMapper

typealias TagName = String

class Tag: Mappable {
	var tagName: String!
	
	required init?(map: Map) {
		
	}
	
	func mapping(map: Map) {
		self.tagName <- map["tagName"]
	}
}

class Page: Mappable {
	
	var articles: [Video]!
	var articleCount: Int!
	var nextPagePath: URL!
	
	required init?(map: Map) {
		
	}
	
	func mapping(map: Map) {
		self.articles <- map["articles"]
		self.articleCount <- map["articleCount"]
		self.nextPagePath <- (map["nextPagePath"], URLTransform())
	}
	
}

class Video: Mappable {
	
	var id: String!
	var title: String!
	var siteName: String!
	var parseDate: Date!
	var publishDate: Date!
	var articleUrl: URL!
	var articleBaseUrl: URL?
	var youtubeUrl: URL?
	var description: String!
	var isVideo: Bool!
	var videoSelector: String?
	var imageUrl: URL!
	var interest: String!
	var tags: [TagName]!
	var category: String!
	var secondsLength: Int?
	
	required init?(map: Map) {
		
	}
	
	func mapping(map: Map) {
		self.id <- map["id"]
		self.title <- map["title"]
		self.siteName <- map["siteNeme"]
		self.parseDate <- (map["parseDate"], DateTransform())
		self.publishDate <- (map["publishDate"], DateTransform())
		self.articleUrl <- (map["articleUrl"], URLTransform())
		self.articleBaseUrl <- (map["articleBaseUrl"], URLTransform())
		self.youtubeUrl <- (map["youtubeUrl"], URLTransform())
		self.description <- map["description"]
		self.isVideo <- map["isVideo"]
		self.videoSelector <- map["videoSelector"]
		self.imageUrl <- (map["imageUrl"], URLTransform())
		self.interest <- map["interest"]
		self.tags <- map["tags"]
		self.category <- map["category"]
	}
}
