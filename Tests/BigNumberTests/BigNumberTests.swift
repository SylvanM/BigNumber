import XCTest
@testable import BigNumber

final class BigNumberTests: XCTestCase {
    
    func testExample() {
        
        let a = UBN(randomBytes: 8)
        let b = UBN(randomBytes: 8)
        
        print(a)
        print(b)
        
        print(a * b)
        
    }
    
    static var allTests = [
        ("testExample", testExample),
        
    ]
}
