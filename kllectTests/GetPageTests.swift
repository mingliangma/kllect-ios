//
//  GetPageTests.swift
//  kllect
//
//  Created by Christopher Primerano on 2016-11-01.
//  Copyright © 2016 Kllect Inc. All rights reserved.
//

import XCTest
import OHHTTPStubs
import BrightFutures
import Result
@testable import kllect

class GetPageTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		OHHTTPStubs.removeAllStubs()
		super.tearDown()
	}
	
	func testBaseUrl() {
		XCTAssertEqual(Remote.baseUrlString(), "http://api.app.kllect.com/")
	}
	
	func testGetPageValidEmpty() {
		stub(condition: isHost("api.app.kllect.com")) { _ in
			let stubPath = OHPathForFile("getPageValidEmpty.json", type(of: self))
			return fixture(filePath: stubPath!, status: 200, headers: ["Content-Type" as NSObject:"application/json" as AnyObject])
		}
		
		let expectation = self.expectation(description: "Get Page Valid Empty")
		
		let future = Remote.getVideosForPage(url: URL(string: Remote.baseUrlString().appending("/articles/tag/Test"))!)
		future.onComplete { response in
			XCTAssertNotNil(response)
			XCTAssertNotNil(response.value)
			XCTAssertNil(response.error)
			XCTAssertEqual(response.value!.articleCount, 0)
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 2.0) { _ in
		}
		
	}
	
	func testGetPageValid() {
		
		stub(condition: isHost("api.app.kllect.com")) { _ in
			let stubPath = OHPathForFile("getPageValid.json", type(of: self))
			return fixture(filePath: stubPath!, status: 200, headers: ["Content-Type" as NSObject:"application/json" as AnyObject])
		}
		
		let expectation = self.expectation(description: "Get Page Valid")
		
		let future = Remote.getVideosForPage(url: URL(string: Remote.baseUrlString().appending("/articles/tag/Test"))!)
		future.onComplete { response in
			XCTAssertNotNil(response)
			XCTAssertNotNil(response.value)
			XCTAssertGreaterThan(response.value!.articleCount, 0)
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 2.0) { _ in
		}
		
	}
	
	func testGetPageNotJSON() {
		
		stub(condition: isHost("api.app.kllect.com")) { _ in
			let stubPath = OHPathForFile("getTagsNotJSON.html", type(of: self))
			return fixture(filePath: stubPath!, status: 200, headers: ["Content-Type" as NSObject:"text/html" as AnyObject])
		}
		
		let expectation = self.expectation(description: "Get Page Not JSON")
		
		let future = Remote.getVideosForPage(url: URL(string: Remote.baseUrlString().appending("/articles/tag/Test"))!)
		future.onComplete { response in
			XCTAssertNotNil(response)
			XCTAssertNotNil(response.error)
			XCTAssertNil(response.value)
			switch response.error! {
			case .malformedType:
				break
			default:
				XCTFail("Not correct error type")
			}
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 2.0) { _ in
		}
		
	}
	
	func testGetPageNetworkError() {
		
		stub(condition: isHost("api.app.kllect.com")) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue), userInfo: nil)
			return OHHTTPStubsResponse(error: notConnectedError)
		}
		
		let expectation = self.expectation(description: "Get Page Network Error")
		
		let future = Remote.getVideosForPage(url: URL(string: Remote.baseUrlString().appending("/articles/tag/Test"))!)
		future.onComplete { response in
			XCTAssertNotNil(response)
			XCTAssertNotNil(response.error)
			XCTAssertNil(response.value)
			switch response.error! {
			case let .networkError(error):
				XCTAssertNotNil(error)
			default:
				XCTFail("Not correct error type")
			}
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 2.0) { _ in
		}
		
	}
	
}
