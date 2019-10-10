import XCTest
@testable import BigNumber

final class BigNumberTests: XCTestCase {
    
    func testExample() {
        
        let a: BN = "dff5ae28f"
        let b: BN = "7743f6fdf"
        print((a * b) / b)
        
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
