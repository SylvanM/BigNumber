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
public struct UBigNumber: BinaryInteger, CustomStringConvertible, ExpressibleByStringLiteral, ExpressibleByArrayLiteral, ExpressibleByIntegerLiteral, UnsignedInteger, Hashable {
    
    // MARK: - Typealiases
    
    /// Word type of ```UBigNumber```
    public typealias Words = [UInt]
    // this has to be UInt's rather than UInt64's as per Swift's requirements.
    // my computer already has 64-bit words, so this isn't a problem, but I have yet to test it on other machines.
    
    /// The element type in the ```UBN``` array
    public typealias ArrayLiteralElement = UInt
    
    /// The integer literal type
    public typealias IntegerLiteralType = UInt
    
    // MARK: - Public Properties
    
    /// Whether or not this number is a power of two
    public var isPowerOfTwo: Bool {
        self != 0 && (self & (self - 1) == 0)
    }
    
    /// Whether or not this number represents 0
    #warning("make this match dad's code")
    public var isZero: Bool {
        self.words.allSatisfy { $0 == 0 } // this is a cool swift feature I just discovered when the syntax was auto completing!
    }
    
    /// Words of the UBigNumber in the form of the word size on the machine
    public var words: UBigNumber.Words = [0]
    
    /// Size of the array
    @inlinable public var size: Int {
        words.count
    }
    
    /// The size of the integer represented by the ```UBN```, in bytes
    public var sizeInBytes: Int {
        size * MemoryLayout<UInt>.size
    }
    
    /// Size of the integer represented by the ```BN``` in bits
    #warning("Possibly rewrite this to match dad's code")
    public var bitWidth: Int {
        let norm = normalized
        let otherWordsBitWidth = (norm.size - 1) * 64
        return otherWordsBitWidth + Int(log2(Double(norm.mostSignificantWord))) + 1
    }
    
    /// The binary compliment of this `UBN`
    public var binaryCompliment: UBigNumber {
        UBigNumber( words.map { ~$0 } )
    }
    
    /// Amount of leading zero bits
    public var leadingZeroBitCount: Int {
        var zeros = 0
        for i in (0..<words.count).reversed() {
            zeros += words[i].leadingZeroBitCount
            
            if words[i] == 0 {
                break
            }
        }
        return zeros
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
    @inlinable public var mostSignificantWord: UInt {
        get { words[size - 1] }
        set { words[size - 1] = newValue }
    }
    
    /// Acesses the least significant word of this `UBN`
    @inlinable public var leastSignificantWord: UInt {
        get { words[0] }
        set { words[0] = newValue }
    }
    
    /// Returns index of most significant set bit
    ///
    /// Note: If the number is 0, this will return -1, because there is no significant bit
    public var mostSignificantSetBitIndex: Int {
        if self == 0 {
            return -1
        }
    
        return Int(log2(Double(normalized.mostSignificantWord))) + size - 1
        
    }
    
    /// Whether or not the `UBN` is normal
    ///
    /// "Normal" means that there are no extraneous zeros in the `UBN`
    public var isNormal: Bool {
        words.count == 1 ? true : words.last! != 0
    }
    
    /// The normalized version of this `UBN`
    public var normalized: UBigNumber {
        var norm = self
        return norm.normalize()
    }
    
    /// Number of nonzero bits in the binary representation of this `UBN`
    public var nonzeroBitCount: Int {
        words.map { $0.nonzeroBitCount }.reduce(0, +)// Look at this cool swift feature! I've been actually reading Apple's documentation.
    }
    
    // MARK: Private Properties
    
    /// The two's compliment of this `UBN`
    public var twosCompliment: UBigNumber {
        var comp = binaryCompliment
        return comp.add(1, withOverflowHandling: false)
    }
    
    // MARK: - Initializers
    
    /// Default initializer, creating a `UBigNumber` with a value of `0`
    public init() {
        
    }
    
    /// Creates a new ```UBigNumber``` with the integer value of `source`
    ///
    /// - Parameters:
    ///     - source: Object conforming to ```BinaryFloatingPoint``` to convert to ```UBigNumber```
    ///
    /// - Returns: The `UBN` representation of the integer value of `source` if `source > 0`. If not, this returns `nil`
    public init?<T>(exactly source: T) where T : BinaryFloatingPoint {
        
        if source < 0 {
            return nil
        }
        
        // if the source is less than 1, it's just 0
        if source.exponent < 1 {
            self.words = [0]
            return
        }
        
        // should just be able to pass it to the other initializer with the float's integer value
        
        let arraySize = (source.exponent / 64) + (source.exponent % 64 != 0 ? 1 : 0)
        self.words = Words(repeating: 0, count: Int(arraySize))
        
        #warning("Do this")
        
    }
    
    /// Creates a new ```UBigNumber``` with the integer value of `source`
    ///
    /// - Parameters:
    ///     - source: Object conforming to ```BinaryFloatingPoint``` to convert to ```UBigNumber```
    ///
    /// - Returns: The `UBN` representation of the integer value of `source` if `source > 0`. If not, this returns `nil`
    public init<T>(_ source: T) where T : BinaryFloatingPoint {
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
        
        self.words = source.words.map { $0 }
        
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
    
    /// Creates a ```UBN``` from an array literal
    ///
    /// - Parameters:
    ///     - elements: Array of type ```[UInt]```
    public init(arrayLiteral elements: UInt...) {
        self.words = elements
    }
    
    /// Creates a ```UBN``` from a hexadecimal string
    ///
    /// - Parameters:
    ///     - hex: A value hexadecimal string
    public init(stringLiteral hex: String) {
        
        // sanitize the string, add leading zeros if necessary
        
        let sanatizedString = (hex.count >= 2) ? ((hex[1] == "x" || hex[1] == "X") ? String(hex.dropFirst(2)) : hex) : hex
        let arraySize = hex.count >= 16 ? sanatizedString.count / 16 : 1
        
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
    
    /**
     * Creates a `UBN` with an empty array
     *
     * - Parameters:
     *      - size: Number of words in this new `UBN`
     */
    public init(size: Int) {
        self.words = Words(repeating: 0, count: size)
    }
    
    /// Creates a `UBN` from an array object representing a number with element type `BinaryInteger`.
    ///
    /// - Parameters:
    ///     - array: The array object
    ///     - bigEndian: `true` if the input array is in the Big Endian format. The default is `false`
    public init <T: BinaryInteger>(_ array: [T], bigEndian: Bool = false) {
        
        // A nice fellow on stackoverflow helped me with this after I asked how to do C-style array/pointer casting
        // in Swift. It was one of the only wholesome experiences I've ever had on stack overflow. Every other time, I've
        // been downvoted (with no explanation whatsoever) after I gave a comment or answer I legitemately (sp?) thought
        // was helpful, but I guess someone was content with simply downvoting my response with no actual will to tell me why
        // I might have been wrong.
        //
        // I wonder if there are long, rambly, informal, and unrelated comment blurbs like this in
        // actual production. If not, there sure will be when I get hired!
        //
        // Here is some ASCII art:
        //
        //     --------
        //    /  O  O  \
        //    |   J    |
        //    |  ----  |
        //    \________/
        //        |
        //      ~~|~~
        //        |
        //        /\
        //       /  \
        //      /    \
        //
        
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
    
    /// Returns a random ```UBN of a specified word size```
    ///
    /// This uses Apples secure random bytes generator
    ///
    /// - Parameters:
    ///     - bytes: Amount of bytes in randomly generated ```UBN```
    ///     - generator: Generator to use (degault is ```kSecRandomDefault```)
    ///
    /// - Returns: Random ```UBN```
    public init(randomBytes: Int, generator: SecRandomRef? = kSecRandomDefault) {
        
        // simplify this dude
        let arraySize = randomBytes / UInt.size + ( randomBytes % UInt.size > 0 ? 1 : 0 )
        
        let newArray = Words(repeating: 0, count: arraySize)
        self.init(newArray)
        
        _ = SecRandomCopyBytes(generator, randomBytes, &self.words)
    
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
