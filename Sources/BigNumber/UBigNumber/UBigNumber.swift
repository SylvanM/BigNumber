//
//  BigNumber.swift
//  BigNumber
//
//  Created by Sylvan Martin on 8/31/19.
//  Copyright © 2019 Sylvan Martin. All rights reserved.
//

import Foundation

/// An unsigned ```UBigNumber``` object
public typealias UBN = UBigNumber

/**
 * An unsigned integer type of unfixed size
 */
public struct UBigNumber: UBNProtocol {
    
    // MARK: - Typealiases
    
    public typealias WordType = UInt
    
    /// Word type of ```UBigNumber```
    public typealias Words = [WordType]
    // this has to be UInt's rather than UInt64's as per Swift's requirements.
    // my computer already has 64-bit words, so this isn't a problem, but I have yet to test it on other machines.
    
    /// The element type in the ```UBN``` array
    public typealias ArrayLiteralElement = WordType
    
    public typealias IntegerLiteralType = UInt
    
    public typealias FloatLiteralType = Float
    
    // MARK: - Public Properties
    
    /// Whether or not this number is a power of two
    public var isPowerOfTwo: Bool {
        self.nonzeroBitCount == 1
    }
    
    /// Whether or not this number represents 0
    public var isZero: Bool {
        self.words.allSatisfy { $0 == 0 }
    }
    
    /**
     * Words of the UBigNumber in the form of the word size on the machine
     *
     * - Invariant: This array is always *normalized*, as defined in `normalize()`
     */
    public internal(set) var words: UBigNumber.Words = [0]
    
    /// Size of the array
    @inlinable public var size: Int {
        words.count
    }
    
    /// The size of the integer represented by the ```UBN```, in bytes
    public var sizeInBytes: Int {
        size * MemoryLayout<WordType>.size
    }
    
    /// Size of the integer represented by the ```BN``` in bits
    public var bitWidth: Int {
        words.reduce(into: 0) { partialResult, word in
            partialResult += word.bitWidth
        }
    }
    
    /// The amount of trailing zero bits
    public var trailingZeroBitCount: Int {
        var zeros = 0
        for i in 0..<words.count {
            zeros += words[i].trailingZeroBitCount
            
            if words[i] != 0 {
                break
            }
        }
        return zeros
    }
    
    /// Hex string representation of the `BN`
    public var hexString: String {
        var string = ""
        
        let bnSizeCountdown = Array(1...words.count).reversed()
        for i in bnSizeCountdown {
            let uintIndexCountdown = Array(1...16).reversed()
            for j in uintIndexCountdown {
                string += toChar(self[i - 1] >> ((j - 1) * 4))
            }
        }
        
        // remove leading zeros
        while string.count > 1 && string.first == "0" {
            string.remove(at: string.startIndex)
        }
        
        return string
    }
    
    /// Binary string representation of this ```UBN```
    ///
    /// Leading zeros are not omitted
    public var binaryString: String {
        var string = "0b"
        for word in words.reversed() {
            string += ("0" * word.leadingZeroBitCount) + String(word, radix: 2)
        }
        return string
    }
    
    /// Hex string description of the `UBN` used when being printed
    public var description: String {
        "0x" + hexString
    }
    
    /// Checks if the last bit is set
    public var leastSignificantBitIsSet: Bool {
        words[0] % 2 == 1
    }
    
    /// Accesses the most significant word of this `UBN`
    public var mostSignificantWord: UInt {
        get { words[size - 1] }
    }
    
    /// Acesses the least significant word of this `UBN`
    public var leastSignificantWord: UInt {
        get { words[0] }
        set { words[0] = newValue }
    }
    
    /// Returns index of most significant set bit
    ///
    /// Note: If the number is 0, this will return -1, because there is no significant bit
    public var mostSignificantSetBitIndex: Int {
        if isZero { return -1 }
        else {
            let otherWordsBitWidth = (size - 1) * 64
            return otherWordsBitWidth + WordType.bitWidth - mostSignificantWord.leadingZeroBitCount - 1
        }
    }
    
    /// Whether or not the `UBN` is normal
    ///
    /// "Normal" means that there are no extraneous zeros in the `UBN`
    public var isNormal: Bool {
        words.count == 1 ? true : words.last! != 0
    }
    
    /// Number of nonzero bits in the binary representation of this `UBN`
    public var nonzeroBitCount: Int {
        words.map { $0.nonzeroBitCount }.reduce(0, +)
    }
    
    /// Whether or not this number is even
    public var isEven: Bool {
        words[0] % 2 == 0
    }
    
    // MARK: - Initializers
    
    /// Default initializer, creating a `UBigNumber` with a value of `0`
    public init() {
        /* Do nothing */
    }
    
    /**
     * Initializes a `UBigNumber` as a `BigNumber`, modulo some modulus.
     */
    init(_ other: BigNumber, mod m: Int) {
        self.init(other.mod(BN(m)).magnitude)
    }
    
    /**
     * Initializes a `UBigNumber` as another `UBigNumber`, modulo some modulus.
     */
    init(_ other: UBigNumber, mod m: Int) {
        self.init(other % UBN(m))
    }
    
    /// Creates a new ```UBigNumber``` with the integer value of `source`
    ///
    /// - Parameters:
    ///     - source: Object conforming to ```BinaryFloatingPoint``` to convert to ```UBigNumber```
    ///
    /// - Warning: This is imprecise, and I have yet to figure out whether it's due to floating point error or this initializer just being written wrong.
    ///
    /// - Returns: The `UBN` representation of the integer value of `source` if `source > 0`. If not, this returns `nil`
    public init?<T>(exactly source: T) where T : BinaryFloatingPoint {
        
        guard source.isFinite else { return nil }
        
        if source < 0 {
            return nil
        }
        
        // if the source is less than 1, it's just 0
        if source.exponent < 1 {
            self.words = [0]
            return
        }
        
        let division = Int(source.exponent + 1).quotientAndRemainder(dividingBy: UInt.bitSize)
        let arraySize = division.quotient + (division.remainder != 0 ? 1 : 0)
        self.words = Words(repeating: 0, count: Int(arraySize))

        let hiBitCount = Int(source.exponent + 1) % UInt.bitSize
        let loBitCount = (T.significandBitCount + 1) - hiBitCount
        
        

        self.words[words.count - 1] = UInt(source.significandBitPattern + (1 << T.significandBitCount)) >> loBitCount // shift out the lo bits and only have the hi bits as the least significant bits for this word
        if self.words.count == 1 { return } // because we don't care about the fractional component
        self.words[words.count - 2] = UInt((source.significandBitPattern + (1 << T.significandBitCount)) << UInt(UInt.bitWidth - loBitCount)) // set this equal to the lo bits, shifted so that they are all the most significant bits of the word
        
    }
    
    public init<T>(_ source: T) where T : BinaryFloatingPoint {
        self.init(exactly: source)!
    }
    
    /// Creates a new ```UBigNumber``` with the integer value of `source`
    ///
    /// - Parameters:
    ///     - source: Object conforming to ```BinaryFloatingPoint``` to convert to ```UBigNumber```
    ///
    /// - Returns: The `UBN` representation of the integer value of `source` if `source > 0`. If not, this returns `nil`
    public init<T>(floatLiteral source: T) where T : BinaryFloatingPoint {
        self.init(exactly: source)!
    }
         
    /// Creates a new ```UBigNumber``` from a given integer value
    ///
    /// - Parameters:
    ///     - source: Object conforming to ```BinaryInteger``` to convert to ```UBigNumber```
    ///
    /// - Returns: ```source``` as a ```UBigNumber```
    public init<T>(truncatingIfNeeded source: T) where T : BinaryInteger {
        // truncating should not be needed because this creates an integer of a non-fixed width
        self.init(exactly: source)!
    }
    
    /// Creates a new ```UBigNumber``` from a ```BinaryInteger```
    ///
    /// Required by `BinaryInteger` protocol, no clamping should actually be needed.
    ///
    /// - Parameters:
    ///     - source: Object conforming to ```BinaryInteger``` to convert to ```UBigNumber```
    ///
    /// - Returns: A ```UBigNumber``` with the value of ```source```
    public init<T>(clamping source: T) where T : BinaryInteger {
        self.init(exactly: source)!
    }
    
    /// Creates a new ```UBigNumber``` from a `BinaryInteger` value
    ///
    /// Required by protocol, no truncating should be necessary.
    ///
    /// - Parameters:
    ///     - source: Object conforming to ```BinaryInteger``` to convert to ```UBigNumber```
    ///
    /// - Returns: ```source``` as a ```UBigNumber```
    public init<T>(truncatingBits source: T) where T : BinaryInteger {
        self.init(exactly: source)!
    }
    
    /// Creates a new ```UBigNumber``` with the value of the passed ```BinaryInteger```.
    ///
    /// - Parameters:
    ///     - source: Object conforming to ```BinaryInteger``` to convert to ```UBigNumber```
    ///
    /// - Returns: The exact value of ```source``` as a ```UBigNumber```
    public init?<T>(exactly source: T) where T : BinaryInteger {
        
        self.init()
        
        if source < 0 {
            return nil
        }
        
        if source.bitWidth <= UInt.bitWidth {
            self.words = [UInt(source)]
            return
        }
        
        self.init(Array(source.words))
        
    }

    /// Creates a new instance of ```UBigNumber``` from the given integer
    ///
    /// May result in a runtime error if ```source``` is not representable as a UBigNumber
    public init<T>(_ source: T) where T : BinaryInteger {
        self.init(exactly: source)!
    }
    
    /// Creates a UBN from an integer literal
    ///
    /// - Parameters:
    ///     - value: The value of the integer literal
    public init(integerLiteral value: UInt) {
        assert(value >= 0, "Integer literal must be an unsigned integer")
        self.init(value)
    }
    
    public init(floatLiteral value: FloatLiteralType) {
        
        assert(value.isFinite, "value must be finite")
        
        self.init(exactly: value)!
    }
    
    /// Creates a ```UBN``` from an array literal
    ///
    /// - Parameters:
    ///     - elements: Array of type ```[WordType]```
    public init(arrayLiteral elements: WordType...) {
        self.init(array: elements)
    }
    
    /// Creates a `UBN` from an array
    ///
    /// - Parameters:
    ///     - words: Array of typee `[WordType]`
    public init(array: [WordType]) {
        self.words = array
        normalize()
    }
    
    /// Creates a ```UBN``` from a hexadecimal string
    ///
    /// - Parameters:
    ///     - hex: A value hexadecimal string
    public init(stringLiteral hex: String) {
        
        // sanitize the string, add leading zeros if necessary
        
        var sanatizedString = (hex.count >= 2) ? ((hex[1] == "x" || hex[1] == "X") ? String(hex.dropFirst(2)) : hex) : hex
        
        sanatizedString = sanatizedString.filter { c in
            c != " "
        }
        
        let arraySize = hex.count >= 16 ? (sanatizedString.count / 16 + (sanatizedString.count % 16 == 0 ? 0 : 1)) : 1
        
        words = Words(repeating: 0, count: arraySize)
        
        for i in 0..<hex.count {
            
            let reversedSequence = (1..<words.count).reversed()
            
            for j in reversedSequence {
                self[j] <<= 4
                self[j] |= (self[j - 1] >> 60) & 0x0f
            }
            
            self[0] <<= 4
            self[0] |= UInt(toNibble(hex[i]) & 0x0f)
        }
        
    }
    
    /// Creates a `UBN` from an array object representing a number with element type `BinaryInteger`.
    ///
    /// - Parameters:
    ///     - array: The array object
    ///     - bigEndian: `true` if the input array is in the Big Endian format. The default is `false`
    public init <T: BinaryInteger> (_ array: [T], bigEndian: Bool = false) {
        
        let typeSize = MemoryLayout<T>.size
        
        var newArray = array
        
        while (newArray.count * typeSize) % UInt.size != 0 {
            if bigEndian {
                newArray.insert(T(0), at: 0)
            } else {
                newArray.append(T(0))
            }
        }
        
        let values: Words = newArray.withUnsafeBytes {
            $0.bindMemory(to: UInt.self)
        }.map {
            if bigEndian {
                return $0.bigEndian
            } else {
                return $0.littleEndian
            }
        }
        
        self.words = values
        
    }
    
    /// Creates a UBN with a given ```Int``` value
    ///
    /// - Parameters:
    ///     - integer: ```Int``` to be converted to a ```UBN```
    public init?(_ integer: Int) {
        if integer < 0 {
            return nil
        }
        self.words = [UInt(integer)]
    }
    
    /// Returns a random ```UBN``` of a specified word size
    ///
    /// This uses Apples secure random bytes generator
    ///
    /// - Parameters:
    ///     - bytes: Amount of bytes in randomly generated ```UBN```
    ///     - generator: Generator to use (degault is ```kSecRandomDefault```)
    ///
    /// - Returns: Random ```UBN```
    public init(secureRandomBytes bytes: Int, generator: SecRandomRef? = kSecRandomDefault) {
        
        // simplify this dude
        let arraySize = bytes / UInt.size + ( bytes % UInt.size > 0 ? 1 : 0 )
        
        let newArray = Words(repeating: 0, count: arraySize)
        self.init(newArray)
        
        _ = SecRandomCopyBytes(generator, bytes, &self.words)
    
    }
    
    /**
     * Creates a `UBigNumber` object from the underlying bytes of a given `Data` object
     *
     * - Parameters:
     *      - data: `Data` to convert to a `UBigNumber`
     */
    public init(data: Data) {
        
        let rawData = Array(data)
        
        self.words = rawData.withUnsafeBytes {
            $0.bindMemory(to: UInt.self)
        }.map {
            $0.littleEndian
        }
        
    }
    
}
