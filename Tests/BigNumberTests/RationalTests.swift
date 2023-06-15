//
//  RationalTests.swift
//  
//
//  Created by Sylvan Martin on 6/6/23.
//

import XCTest
import BigNumber

final class RationalTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitializers() throws {
        
        let half: Rational = 0.5
        
        XCTAssertEqual(half.numerator, 1)
        XCTAssertEqual(half.denominator, 2)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
