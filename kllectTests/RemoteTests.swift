//
//  RemoteTests.swift
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

class RemoteTests: XCTestCase {
    
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
	
	func testGetTagsValidEmpty() {
		stub(condition: isHost("api.app.kllect.com")) { _ in
			let stubPath = OHPathForFile("getTagsValidEmpty.json", type(of: self))
			return fixture(filePath: stubPath!, status: 200, headers: ["Content-Type" as NSObject:"application/json" as AnyObject])
		}
		
		let expectation = self.expectation(description: "Get Tags Valid Empty")
		
		let future = Remote.getTags()
		future.onComplete { response in
			XCTAssertNotNil(response)
			XCTAssertNotNil(response.value)
			XCTAssertNil(response.error)
			XCTAssertEqual(response.value!.count, 0)
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 2.0) { _ in
		}

	}
    
	func testGetTagsValid() {
		
		stub(condition: isHost("api.app.kllect.com")) { _ in
			let stubPath = OHPathForFile("getTagsValid.json", type(of: self))
			return fixture(filePath: stubPath!, status: 200, headers: ["Content-Type" as NSObject:"application/json" as AnyObject])
		}
		
		let expectation = self.expectation(description: "Get Tags Valid")
		
		let future = Remote.getTags()
		future.onComplete { response in
			XCTAssertNotNil(response)
			XCTAssertNotNil(response.value)
			XCTAssertGreaterThan(response.value!.count, 0)
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 2.0) { _ in
		}
		
	}
	
	func testGetTagsNotJSON() {
		
		stub(condition: isHost("api.app.kllect.com")) { _ in
			let stubPath = OHPathForFile("getTagsNotJSON.html", type(of: self))
			return fixture(filePath: stubPath!, status: 200, headers: ["Content-Type" as NSObject:"text/html" as AnyObject])
		}
		
		let expectation = self.expectation(description: "Get Tags Not JSON")
		
		let future = Remote.getTags()
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
	
	func testGetTagsNetworkError() {
		
		stub(condition: isHost("api.app.kllect.com")) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue), userInfo: nil)
			return OHHTTPStubsResponse(error: notConnectedError)
		}
		
		let expectation = self.expectation(description: "Get Tags Network Error")
		
		let future = Remote.getTags()
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
	
//	func testGetTagsNotStringConvertable() {
//		
//		stub(condition: isHost("api.app.kllect.com")) { _ in
//			let data = Data()
//			return OHHTTPStubsResponse(data: data, statusCode: 200, headers: nil)
//		}
//		
//		let expectation = self.expectation(description: "Get Tags Network Error")
//		
//		let future = Remote.getTags()
//		future.onComplete { response in
//			XCTAssertNotNil(response)
//			XCTAssertNotNil(response.error)
//			XCTAssertNil(response.value)
//			switch response.error! {
//			case .notStringConvertable:
//				break
//			default:
//				XCTFail("Not correct error type")
//			}
//			expectation.fulfill()
//		}
//		
//		waitForExpectations(timeout: 2.0) { _ in
//		}
//		
//	}
	
}
