import XCTest
@testable import BigNumber

final class BigNumberTests: XCTestCase {
    
    func testExample() {
        
//        var b: BN = [0b0000000000000000000000000000000000000000000000000000000000000000, 1]
        
        var a: UBN = [0b1000000000000000000000000000000000000000000000000000000000000000] {
            didSet {
                print(a.binaryString)
            }
        }
        print(a.binaryString)
        while a > 0 {
            a >>= 0x10
        }
        
    }
    
    static var allTests = [
        ("testExample", testExample)
    ]
}
