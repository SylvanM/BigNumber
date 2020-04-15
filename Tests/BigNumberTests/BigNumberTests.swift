import XCTest
@testable import BigNumber

final class BigNumberTests: XCTestCase {
    
    func testExample() {
        
        var a = UBN(size: 8)
        var b = UBN(size: 8)
        var r: UBN = 0
        
        for _ in 0..<2048 {
            a.setToRandom()
            b.setToRandom()
            
            UBN.multiply(x: a, by: b, result: &r)
            print(r)
        }
        
    }
    
    static var allTests = [
        ("testExample", testExample),
        
    ]
}
