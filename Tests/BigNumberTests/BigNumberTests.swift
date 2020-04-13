import XCTest
@testable import BigNumber

final class BigNumberTests: XCTestCase {
    
    func testExample() {
        
        var a: UBN = [UInt.max, UInt.max, UInt.max, UInt.max]
        let b: UBN = [18446744073709551615, 0, 0, 0]
        print(b.twosCompliment)
        a.add(1, withOverflowHandling: false)
        print(a)
        
    }
    
    static var allTests = [
        ("testExample", testExample),
        
    ]
}
