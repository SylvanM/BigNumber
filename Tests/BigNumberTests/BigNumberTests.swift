import XCTest
@testable import BigNumber

final class BigNumberTests: XCTestCase {
    
    func testExample() {
        
        let a: BN = "38d3f0746f2"
        let b: BN = "dee2d"
        
        let c = a * b
        print(c)
        print(c / b)
        print(c / a)
        
        
    }
    
//    static func / (lhs: UInt64, rhs: UInt64) -> Int {
//
//        assert(rhs != 0, "Cannot divide by 0")
//
//        var (a, b) = (lhs, rhs)
//
//        // now do the division
//
//        var quotient: UInt64 = 0
//        var lastBit: Int = 0
//
//        for i in 0..<b.sizeInBits {
//            if b & (1 << i) != 0 {
//                quotient += ( b & (1 << i) )
//                lastBit = i
//                break
//            }
//        }
//
//        for i in lastBit..<b.sizeInBits {
//            quotient -= ( b & (1 << i) )
//        }
//
//        return quotient
//    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
