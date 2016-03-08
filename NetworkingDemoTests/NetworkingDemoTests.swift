//
//  NetworkingDemoTests.swift
//  NetworkingDemoTests
//
//  Created by Jubin Jacob on 01/10/15.
//  Copyright © 2015 J. All rights reserved.
//

import XCTest
@testable import NetworkingDemo

class NetworkingDemoTests: XCTestCase {
    
    func testNetworkManager() {
        let networkManager = NetworkManager.sharedInstance
        let expectation : XCTestExpectation = self.expectationWithDescription("The request should successfully complete within the specific timeframe.")
        networkManager.getLondonWeather() { [expectation](response:(result:AnyObject?, error : NSError?))->Void in
            print("in main thread\(NSThread.isMainThread())")
            let dict = response.result as! Dictionary<String,AnyObject>
            XCTAssertTrue(dict["name"]?.isEqualToString("London") == true,"Met expected value")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0) { (error:NSError?) -> Void in
            print("error\(error?.description)")
        }
    }
}
