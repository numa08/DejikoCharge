//
//  PixivDejikoProviderTest.swift
//  DejikoCharge
//
//  Created by numa08 on 2015/01/10.
//  Copyright (c) 2015年 numanuma08. All rights reserved.
//

import UIKit
import XCTest
import DejikoProvider

class PixivDejikoProviderTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCreateRequset() {
        let request = PixivDejikoRequest(page : 0)
        let expected = "http://spapi.pixiv.net/iphone/search.php?&s_mode=s_tag&word=%E3%81%A7%E3%81%98%E3%81%93&p=0"
        let actual = request.query!.description
        XCTAssertEqual(expected, actual, "Can not get collect URL")
    }
    
    func testRequestDejiko() {
        let result = PixivDejikoProvider().requestDejiko(PixivDejikoRequest(page: 1))
        for r in result {
            switch(r){
            case let .Success(resp):
                NSLog("\(resp)")
            case let .Error(e):
                NSLog("\(e.localizedDescription)")
            }
        }
    }
}
