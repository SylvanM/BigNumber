//
//  DivisionTesting.swift
//  
//
//  Created by Sylvan Martin on 6/13/23.
//

import XCTest
import BigNumber

final class DivisionTesting: XCTestCase {
    
    let maxBytes = 200
    let trials = 100

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSuperSpecificMul() throws {
        let a: UBN = "0x2DEE4E2519"
        let b: UBN = "0x2000000000"
        
        let expected: UBN = "0x5bdc9c4a32000000000"
        let computed = a * b
        
        XCTAssertEqual(computed, expected)
    }
    
    func testVerySpecificExample() throws {
        let divisor: UBN = "0x2DEE4E2519"
        let dividend: UBN = "0x1DA627265E343E9E14DA"
        let expectedQuotient: UBN = "0xA5406B0CEA"
        
        let (quotient, remainder) = dividend.quotientAndRemainder(dividingBy: divisor)
        
        XCTAssertEqual(expectedQuotient, quotient)
        XCTAssertEqual(remainder, 0)
    }
    
    func testKnownExamples() throws {
        XCTAssertEqual(
            UBN(stringLiteral: "0x20CBEDA03D3C8DBAA094F73F34E841648B00C7AD3C3D5F95B9DFCC7F34BB83EF3B2E6401FA56B560BD3E929DA115A73070D3") /
            UBN(stringLiteral: "0x9058571D9F8715030FB9D1E17CB8314473BA3144C4E78A810A0D741B98D65E4DDD57EABA12A15BFA2D3CF0B9973E942BED71"),
            UBN(stringLiteral: "0x0")
        )
        
        XCTAssertEqual(
            UBN(stringLiteral: "0xD694E2F1175E52B6F464C6E8662EAE9B367296FA6E8D58C0A72637BEBA18CA52AAF5EA430BA5E853F771E7608B1DDCDFD17A") /
            UBN(stringLiteral: "0x6CCA08CF09CD9175F871CF2238CD173B3AE6D92C1C7B20C2C91C14D456A9B990F25D744271FE592F3443627265DAF7E469"),
            UBN(stringLiteral: "0x1f8")
        )
        
        XCTAssertEqual(
            UBN(stringLiteral: "0x38EE1C1B4FFF50BA9F4CE4CE8F3EBF100650FF24ACBEACF147844EEE04209478AF3D39360DEBF90A146EF3AC29A279DF5BAF") /
            UBN(stringLiteral: "0x1E33CF03B82943AFFF3959AA390537EAD6424058DFBB2A7AB5"),
            UBN(stringLiteral: "0x1e28c65c00e57b4ec12b3a55627313868fe8758fad8272f83d7")
        )
    }

    func testPerfectDivision() throws {
        
        for _ in 1...trials {
            let divisor = UBN.random(bytes: maxBytes)
            let knownQuotient = UBN.random(bytes: maxBytes)
            let product = divisor * knownQuotient
            
            let (quotient, remainder) = product.quotientAndRemainder(dividingBy: divisor)
            
            XCTAssertEqual(knownQuotient, quotient)
            XCTAssertEqual(remainder, 0)
        }
    }
    
    func testProperties() throws {
        
        for _ in 1...trials {
            let dividend = UBN.random(bytes: maxBytes * 2)
            let divisor = UBN.random(bytes: maxBytes)
            
            let (quotient, remainder) = dividend.quotientAndRemainder(dividingBy: divisor)
            
            XCTAssertEqual(divisor * quotient + remainder, dividend)
        }
        
    }
    
    func testEuclideanAlgs() throws {
        
        let a: BN = 1398
        let b: BN = 324
        
        XCTAssertEqual(BN.gcd(a, b), 6)
        
    }
    
    func testMod() throws {
        
        
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
