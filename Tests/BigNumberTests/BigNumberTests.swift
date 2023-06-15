import XCTest
@testable import BigNumber

final class BigNumberTests: XCTestCase {

    override func setUp() {
        // Put setup code here
    }

    override func tearDown() {
        // This code runs after all other tests
    }

    func testExample() {
        let x = UBN(UBigNumber.WordType.max)
        print(x)
        let y: UBN = "1555555555555555555555555555555555555555555555555555555555555555400000000000000000000000000000000"
        
        XCTAssertEqual(y.words, [1, 0x5555555555555555, 0x5555555555555555, 0x5555555555555555, 0x5555555555555554, 0x0000000000000000, 0x0000000000000000].reversed())
        
    }

    // MARK: Comparison Tests
    
    func testSignedComparisons() {
        
        for _ in 0...255 {
            var a = BN.random(words: 4)
            var b = BN.random(words: 4)
            
            a.set(sign: -1)
            b.set(sign: 1)
            
            XCTAssertTrue(a < b)
            XCTAssertTrue(b > a)
            XCTAssertTrue(a <= b)
            XCTAssertTrue(b >= a)
            
            a.set(sign: 1)
            
            let unsignedcmp = a.magnitude.compare(to: b.magnitude)
            
            XCTAssertEqual(unsignedcmp, a.compare(to: b))
            
            a.set(sign: -1)
            b.set(sign: -1)
            
            XCTAssertEqual(unsignedcmp * -1, a.compare(to: b))
        }
        
    }
    
    /**
     * Comparatison Tests
     */
    func testUnsignedComparisons() {

        var a = UBN()
        var b = UBN()
        var cmp: Int

        // test compare(to:) method

        a = [0, 0, 0, 0, 0, 0, 0, 0]
        b = [0]
        cmp = a.compare(to: b)
        XCTAssertEqual(cmp, 0)
        XCTAssertTrue(a == b)

        a = [0]
        b = [0, 0, 0, 0, 0, 0, 0, 0]
        cmp = a.compare(to: b)
        XCTAssertEqual(cmp, 0)
        XCTAssertTrue(a == b)

        a = [233423423]
        b = [131321312, 0]
        cmp = a.compare(to: b)
        XCTAssertEqual(cmp, 1)
        XCTAssertTrue(a > b)

        b = [1231312312321321]
        a = 0xffffffffffffffff
        cmp = b.compare(to: a)
        XCTAssertEqual(cmp, -1)
        XCTAssertTrue(b < a)


    }

    // MARK: Initializer Tests
    
    func testSignedInitializers() {
        
        var a: BN = -1134
        
        XCTAssertEqual(a.magnitude, 1134)
        XCTAssertEqual(a.sign, -1)
        XCTAssertTrue(a.isNormal)
        
        a = 0
        
        XCTAssertEqual(a.magnitude, 0)
        XCTAssertEqual(a.sign, 0)
        XCTAssertTrue(a.isNormal)
        
        a = "-9aa3aefe509eb84b19084a2954842c9b7694707b82efd3c1c68e13fbb10e40f4c1cb16845fdda9494fbe27e58f488570"
        
        XCTAssertEqual(a.magnitude, "9aa3aefe509eb84b19084a2954842c9b7694707b82efd3c1c68e13fbb10e40f4c1cb16845fdda9494fbe27e58f488570")
        XCTAssertEqual(a.sign, -1)
        XCTAssertTrue(a.isNormal)
        
        let b: BN = [2]
        
        XCTAssertEqual(b.sign, 1)
        
    }

    /**
     * Initializer tests
     */
    func testUnsignedInitializers() {

        var ubn: UBN = 0
        
        let maximumFloat: Float = .greatestFiniteMagnitude
        ubn = UBN(maximumFloat)
        
        let float: Float = 4.0023e+10
        
        ubn = UBN(float)

        XCTAssert(UBN(exactly: -123213.87) == nil)

        // test the truncating if needed initilizer, which should never really actually be needed
        ubn = UBN(truncatingIfNeeded: 0xfffffffffffffff)
        XCTAssertEqual(ubn, UBN(0xfffffffffffffff))

        // ok I'mma skip all the initializers that are literally the same

        // test the BinaryInteger initilization
        ubn = UBN(exactly: 0xffff34eac8)!
        XCTAssertEqual(ubn.words, [0xffff34eac8])

        XCTAssertEqual(UBN(0xffff34eac8), UBN(clamping: 0xffff34eac8))
        XCTAssertEqual(UBN(truncatingBits: 0xffff34eac8), UBN(0xffff34eac8))

        // test initializing from a string literal
        ubn = "9aa3aefe509eb84b19084a2954842c9b7694707b82efd3c1c68e13fbb10e40f4c1cb16845fdda9494fbe27e58f488570"
        XCTAssertEqual(ubn.words, [0x9aa3aefe509eb84b, 0x19084a2954842c9b, 0x7694707b82efd3c1, 0xc68e13fbb10e40f4, 0xc1cb16845fdda949, 0x4fbe27e58f488570].reversed())

        ubn = ""
        XCTAssertEqual(ubn.words, [0])

        ubn = "0x9aa3aefe509eb84b19084a2954842c9b7694707b82efd3c1c68e13fbb10e40f4c1cb16845fdda9494fbe27e58f488570"
        XCTAssertEqual(ubn.words, [0x9aa3aefe509eb84b, 0x19084a2954842c9b, 0x7694707b82efd3c1, 0xc68e13fbb10e40f4, 0xc1cb16845fdda949, 0x4fbe27e58f488570].reversed())

        ubn = "0x"
        XCTAssertEqual(ubn.words, [0])

        // test array initialization thingyyyyy
        let array: [UInt32] = [0, 0xffffffff, 0, 0xffffffff]
        ubn = UBN(array)

        XCTAssertEqual(ubn.words, [0xffffffff00000000, 0xffffffff00000000])

        // test integer initializer
        for _ in 0..<256 {
            let randInt = Int.random(in: (Int.min)...(Int.max))
            if randInt < 0 {
                XCTAssertEqual(UBN(randInt), nil)
                continue
            }

            ubn = UBN(randInt)
            XCTAssertEqual(ubn.words, [UInt(randInt)])

        }

        // test generate random bytes

        // I'm nut really sure how to test this...
        ubn = UBN(secureRandomBytes: Int.random(in: 1...8))

        // test data initialization

        let bytes: [UInt8] = [0, 34, 123, 255, 0, 62, 3, 241]
        let data = Data(bytes)
        ubn = UBN(data: data)
        XCTAssertEqual(ubn.words, [0xf1033e00ff7b2200])

        // test binary compliment

        let randomWords = [UInt.random(in: 0...UInt.max), UInt.random(in: 0...UInt.max), UInt.random(in: 0...UInt.max)]
        ubn = UBN(randomWords)
        XCTAssertEqual(ubn.binaryCompliment.words, [~randomWords[0], ~randomWords[1], ~randomWords[2]])

        // instead of directly testing the two's compliment, I'll test it by testing the other operations


        // test trailing zero bit count
        ubn = [0]
        XCTAssertEqual(ubn.trailingZeroBitCount, UInt(0).trailingZeroBitCount)
        for _ in 0...256 {
            ubn = [0, UInt.random(in: 0...UInt.max)]
            XCTAssertEqual(ubn.trailingZeroBitCount, UInt(0).trailingZeroBitCount + ubn.words[1].trailingZeroBitCount)
        }

        ubn = 0
        XCTAssertFalse(ubn.leastSignificantBitIsSet)

        ubn = 1
        XCTAssertTrue(ubn.leastSignificantBitIsSet)

        for _ in 0...256 {
            ubn = UBN((UInt.random(in: 0...(UInt.max / 2)) * 2))
            XCTAssertFalse(ubn.leastSignificantBitIsSet)
        }

        for _ in 0...256 {
            ubn = UBN((UInt.random(in: 0...(UInt.max / 2)) * 2) &+ 1)
            XCTAssertTrue(ubn.leastSignificantBitIsSet)
        }

    }

    // MARK: Method Tests

    /**
     * Method tests
     */
    func testMethods() {

        // test normalize function
        let randomZeroPadding = [UInt](repeating: 0, count: Int.random(in: 0...16))
        let array = [UInt.random(in: 0...UInt.max), UInt.random(in: 0...UInt.max), UInt.random(in: 0...UInt.max), UInt.random(in: 0...UInt.max)] + randomZeroPadding
        var a = UBN(array)
        a.normalize()
        XCTAssertTrue(a.words.allSatisfy { $0 != 0 || (a[0] == 0 && a.size == 1) } )

        // not really sure how much testing the "zero()" method needs...
        let expectedCount = a.size
        XCTAssertEqual(expectedCount, a.size)

    }

    // MARK: Computed Property Tests

    /**
     * Computed Property Tests
     */
    func testUnsignedComputedProperties() {

        // test isPowerOfTwo

        // general cases
        for _ in 0...255 {
            let powOfTwo = UBN(1) << UBN.init(secureRandomBytes: 1)
            if !powOfTwo.isPowerOfTwo {
                print(powOfTwo)
            }
            XCTAssertTrue(powOfTwo.isPowerOfTwo)
        }

        // corner cases
        let zero: UBN = 0
        XCTAssertFalse(zero.isPowerOfTwo)

        // test size properties

        for _ in 0...255 {
            let rand = UBN(secureRandomBytes: Int.random(in: 1...8))
            XCTAssertEqual(rand.size, rand.words.count)
        }

        for _ in 0...255 {
            let integer = Int.random(in: 0...Int.max)
            let ubn = UBN(integer)!
            XCTAssertEqual(ubn.bitWidth, Int(log2(Double(integer))) + 1)
        }

    }

    
    // MARK: Test addition and subtraction
    
    func testSignedMultiplication() {
        
        let a: BN = "F7CD5267A01FC10A"
        
        XCTAssertEqual(a + a, 2 * a)
        
    }
    
    func testSignedAdditionAndSubtraction() {
        
        measure {
            for _ in 0...255 {
                
                var a = BN.random(words: 1)
                let b = a
                
                a.add(a)
                
                XCTAssertEqual(a.sign, b.sign)
                XCTAssertEqual(a, b + b)
                
                XCTAssertEqual((b + b).sign, (2 * b).sign)
                XCTAssertEqual((b + b).sign, b.sign)
                XCTAssertEqual((2 * b).sign, b.sign)
                
                XCTAssertEqual(a, b * 2)
                
                XCTAssertEqual(a + a, 2 * a)

                XCTAssertEqual(-a, a.negative)
                XCTAssertEqual(-a, a - (2 * a))
                
            }
        }
        
    }
    
    // MARK: Test Methods
    
    func testSignedModuloOperator() {
       
        for _ in 0...255 {
            
            let a = BN.random(words: 3) * 2
            
            XCTAssertEqual(a % 2, 0)
            
        }
        
    }
    
    
    
    func testExtGcd() {
        
        let a: BN = 1398
        let b: BN = 324
        
        let (g, x, y) = BN.extgcd(a: a, b: b)
        
        XCTAssertEqual(a.gcd(b), 6)
        XCTAssertEqual(g, 6)
        XCTAssertEqual(x, -19)
        XCTAssertEqual(y, 82)
        
        XCTAssertEqual(a.gcd(b), b.gcd(a))
        XCTAssertEqual(a.gcd(b), g)
        
        XCTAssertEqual(a * x + b * y, g)
        XCTAssertEqual(a * -19 + b * 82, 6)
        
    }
    
}
