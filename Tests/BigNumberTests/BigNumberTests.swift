import XCTest
@testable import BigNumber

final class BigNumberTests: XCTestCase {
    
    func testExample() {
        
        let a: BN = "0x38d3f0746f2"//27bc3b7d1"
        let b: BN = "0xdff5ae28fca"//d0fdfde99"
        let c = b + a
        
        print(c)
        
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
