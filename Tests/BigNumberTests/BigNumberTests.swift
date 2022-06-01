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

    // MARK: Subscript Testing

    /**
     * Subscript tests
     */
    func testUnsignedSubscripts() {

        // tests the safe subscript

        var ubn: UBN = 0
        ubn[safe: 8] = 1
        XCTAssertEqual(ubn.words, [0, 0, 0, 0, 0, 0, 0, 0, 1])

        ubn = [13471348, 9921369, 118891239923, 238, 1023]
        ubn[safe: 5] = 2341234
        XCTAssertEqual(ubn.words, [13471348, 9921369, 118891239923, 238, 1023, 2341234])

        // test the bit subscript

        // test the "8" bit (so the 4th bit from 0)
        var number = UBN(secureRandomBytes: Int.random(in: 1...5))
        number |= 8
        XCTAssertTrue(number[bit: 3] == 1)

        // generate random power of 2 to test
        let bitIndex = Int.random(in: 0...UInt.bitSize)
        let powOfTwo = 1 << bitIndex
        number = UBN(powOfTwo)
        XCTAssertTrue(number[bit: bitIndex] == 1)
        XCTAssertTrue(number[bit: bitIndex + 1] == 0)

        // do performance tests on subscripts so we can find the fastest way to do each one

        self.measure {
            
        }

    }

    // MARK: Bit Manipulation Testing

    /**
     * Tests subscripts and methods for bit manipulation
     */
    func testUnsignedBitManipulators() {

        var x = UBN()
        let y: UBN = "7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffee"

        XCTAssertTrue(x.isNormal)

        x[bit: 0] = 1
        XCTAssertTrue(x.isNormal && x[bit: 0] == 1 && x.bitWidth == 1)

        x[bit: 0] = 0
        XCTAssertTrue(x.isNormal && x[bit: 0] == 0 && x.bitWidth == 0)

        x[bit: 63] = 1
        XCTAssertTrue(x.isNormal && x[bit: 63] == 1 && x.bitWidth == 64)

        x[bit: 63] = 0
        XCTAssertTrue(x.isNormal && x[bit: 63] == 0 && x.bitWidth == 0)

        x[bit: 64] = 1
        XCTAssertTrue(x.isNormal)
        XCTAssertTrue(x[bit: 64] == 1)
        XCTAssertTrue(x.bitWidth == 65)

        x[bit: 64] = 0
        XCTAssertTrue(x.isNormal && x[bit: 64] == 0 && x.bitWidth == 0)

        x[bit: 256] = 0
        XCTAssertTrue(x.isNormal && x.isZero)

        x[bit: 256] = 1
        XCTAssertTrue(x.isNormal && x[bit: 256] == 1 && x.bitWidth == 257)

        x[bit: 256] = 0
        XCTAssertTrue(x.isNormal && x.isZero)

        x.normalize()
        XCTAssertTrue(x.isNormal && x.isZero)

        for i in 0..<255 {
            x[bit: i] = 1
        }

        x[bit: 0] = 0
        x[bit: 4] = 0

        XCTAssertEqual(x, y)
    }

    // MARK: Bitwise Shift Testing

    /**
     * Bit shifting!
     */
    func testUnsignedBitwiseShifting() {

        var x = UBN()
        let y: UBN = "7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffed"
        let z: UBN = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

        x[bit: 0] = 1
        x <<= 255
        x -= 19
        XCTAssertTrue(x.isNormal)
        XCTAssertEqual(x, y) // XCTAssertEqual failed: ("0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFED") is not equal to ("0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFED")

        x >>= 255
        XCTAssertTrue(x.isNormal)
        XCTAssertTrue(x.isZero)
        x.normalize()
        x[bit: 0] = 1
        x <<= 256
        x -= 1
        XCTAssertTrue(x.words.allSatisfy { $0 == UInt.max } )

        XCTAssertTrue(x.isNormal)
        XCTAssertEqual(x.bitWidth, 256)

        x = z << 129
        XCTAssertEqual(x, "1555555555555555555555555555555555555555555555555555555555555555400000000000000000000000000000000")

        for i in 0...129 {
            XCTAssertFalse(x[bit: i] == 1)
        }

        XCTAssertTrue(x.isNormal)

        x >>= 380
        XCTAssertTrue(x.isNormal)
        XCTAssertEqual(x, 0x15)

        x >>= 73
        XCTAssertTrue(x.isNormal)
        XCTAssertTrue(x.isZero)
        XCTAssertEqual(x.bitWidth, 0)

    }

    // MARK: Bitwise Operator Testing

    /**
     * Bitwise operator testing
     *
     * Tests:
     * - AND
     * - OR
     * - XOR
     */
    func testBitwiseLogicalOperators() {

        let x: UBN = "aaaaaaaaaaaaaaaa6666666666666666aaaaaaaaaaaaaaaa6666666666666666"
        var y: UBN = "f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0"

        var correctAnd: UBN = "a0a0a0a0a0a0a0a06060606060606060a0a0a0a0a0a0a0a06060606060606060"
        var result = x & y
        XCTAssertTrue(result.isNormal)
        XCTAssertEqual(result, correctAnd, "AND Failed")

        var correctOr: UBN = "fafafafafafafafaf6f6f6f6f6f6f6f6fafafafafafafafaf6f6f6f6f6f6f6f6"
        result = x | y
        XCTAssertTrue(result.isNormal)
        XCTAssertEqual(result, correctOr, "OR Failed")

        var correctXor: UBN = "5a5a5a5a5a5a5a5a96969696969696965a5a5a5a5a5a5a5a9696969696969696"
        result = x ^ y
        XCTAssertTrue(result.isNormal)
        XCTAssertEqual(result, correctXor, "XOR Failed")
        
        // test with unequal lengths

        y.rightShift(by: 64)

        correctAnd = "6060606060606060a0a0a0a0a0a0a0a06060606060606060"
        result = x & y
        XCTAssertTrue(result.isNormal)
        XCTAssertEqual(result, correctAnd, "AND with unequal lengths failed")
        
        correctOr = "aaaaaaaaaaaaaaaaf6f6f6f6f6f6f6f6fafafafafafafafaf6f6f6f6f6f6f6f6"
        result = x | y
        XCTAssertTrue(result.isNormal)
        XCTAssertEqual(result, correctOr, "OR with unequal lengths failed")
    
        correctXor = "aaaaaaaaaaaaaaaa96969696969696965a5a5a5a5a5a5a5a9696969696969696"
        result = x ^ y
        XCTAssertTrue(result.isNormal) // XCTAssertTrue failed
        XCTAssertEqual(result, correctXor, "XOR with unequal lengths failed")
        
    }

    // MARK: Test addition and subtraction
    
    func testUnsignedAdditionMultiplicationSymmetry() {
        
        for i in 1...256 {
            
            let a = UBN.random(size: i)
            
            var accumulator: UBN = 0
            
            let scalar = Int.random(in: 0...100)
            
            for _ in 0..<scalar {
                accumulator.add(a)
            }
            
            XCTAssertEqual(accumulator, scalar * a, "Repeated addition and multiplication are the same")
        }
        
    }
    
    func testSignedAdditionAndSubtraction() {
        
        
        
    }
    
}
