import XCTest
@testable import BigNumber

final class BigNumberTests: XCTestCase {
    
   func testExample() {
    
        var rand: UBN {
            return UBN.random(bytes: 8)
        }

        for _ in 0..<128 {
            _ = rand ** rand % rand
        }
    
    }
    
    static var allTests = [
        ("testExample", testExample),
        
    ]
}
