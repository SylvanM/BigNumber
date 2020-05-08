//
//  File.swift
//  
//
//  Created by Sylvan Martin on 5/6/20.
//

import Foundation

public typealias BN = BigNumber

/**
 * A signed integer type of unfixed size
 */
public struct BigNumber: CustomStringConvertible, ExpressibleByStringLiteral, ExpressibleByArrayLiteral, ExpressibleByIntegerLiteral, SignedInteger, BinaryInteger, Hashable {
    
    // MARK: - Typealiases
    
    /// Words of a `BigNumber`
    public typealias Words = UBigNumber.Words
    
    /// The element type in array literal
    public typealias ArrayLiteralElement = Words.Element
    
    /// Integer literal type from which this type can be initialized
    public typealias IntegerLiteralType = Int
    
    public typealias StringLiteralType = String
    
    // MARK: - Public Properties
    
    /// Sign of this `BigNumber`
    ///
    /// - `-1`: Negative
    /// - `0`: Zero
    /// - `1`: Positive
    public var sign: Int = 0
    
    /// Unsigned magnitude of this value
    public var magnitude: UBigNumber = 0
    
    /// Whether or not this number is a power of two
    public var isPowerOfTwo: Bool {
        magnitude.isPowerOfTwo
    }
    
    /// Whether or not this number represents 0
    public var isZero: Bool {
        magnitude.isZero
    }
    
    /// Acesses the words of the magnitude of this `BigNumber`
    #warning("Speed test this")
    @inlinable public var words: UBigNumber.Words {
        get { magnitude.words }
        set { magnitude.words = newValue }
    }
    
    /// Size of the words array
    @inlinable public var size: Int {
        magnitude.size
    }
    
    /// The size, in bytes, of the integer represented by this `BN`
    @inlinable public var sizeInBytes: Int {
        magnitude.sizeInBytes
    }
    
    /// Size of the integer represented by this `UBigNumber` in bits
    @inlinable public var bitWidth: Int {
        magnitude.bitWidth
    }
    
    /// The binary compliment of this `BigNumber`, ignoring the `sign`
    public var binaryCompliment: BigNumber {
        BigNumber( words.map { $0 } )
    }
    
    /// Amount of leading zero bits
    @inlinable public var leadingZeroBitCount: Int {
        magnitude.leadingZeroBitCount
    }

    /// Amount of trailing zero bits
    @inlinable public var trailingZeroBitCount: Int {
        magnitude.leadingZeroBitCount
    }
    
    /// Hex string representation of the `BN`
    public var hexString: String {
        (sign == -1 ? "-" : "") + magnitude.hexString
    }
    
    /// Binary string representation of this `BN`
    public var binaryString: String {
        (sign == -1 ? "-" : "") + magnitude.binaryString
    }
    
    /// Hex description of the BN when being printed
    public var description: String {
        (sign == -1 ? "-" : "") + magnitude.description
    }
    
    /// `true` if the least significant bit is `1`
    @inlinable public var leastSignificantBitIsSet: Bool {
        magnitude.leastSignificantBitIsSet
    }
    
    /// Acesses the most significant word of this `BN`
    @inlinable public var mostSignificantWord: UInt {
        get { magnitude.mostSignificantWord }
        set { magnitude.mostSignificantWord = newValue }
    }
    
    /// Acesses the least significant word of this `BN`
    @inlinable public var leastSignificantWord: UInt {
        get { magnitude.leastSignificantWord }
        set { magnitude.leastSignificantWord = newValue }
    }
    
    /// Returns the index of the most significant set bit
    ///
    /// **Note:** If this `BN` is equivalent to `0`, this will return `-1`
    @inlinable public var mostSignificantSetBitIndex: Int {
        magnitude.mostSignificantSetBitIndex
    }
    
    /// Whether or not the array representation of this `BN` is normal
    ///
    /// "Normal" means that it is not using excess memory
    @inlinable public var isNormal: Bool {
        magnitude.isNormal
    }
    
    /// The normalized version of this `BN`
    public var normalized: BigNumber {
        var norm = self
        return norm.normalize()
    }
    
    /// The number of nonzero buts in the binary representation of this `BN`
    @inlinable public var nonzeroBitCount: Int {
        magnitude.nonzeroBitCount
    }
    
    // MARK: Initializers
    
    /// Default initializer, creating a `BigNumber` with a value of `0`
    public init() {
        // do nothing
    }
    
    /// Creates a `BN` from a `UBN`
    public init(_ ubn: UBigNumber) {
        self.magnitude = ubn
        if ubn > 0 {
            self.sign = 1
        }
    }
    
    public init?<T>(exactly source: T) where T : BinaryFloatingPoint {
        
        self.magnitude = UBN(exactly: source.magnitude)!
        self.sign = source.sign.rawValue
        
    }
    
    public init<T>(_ source: T) where T : BinaryFloatingPoint {
        self.magnitude = UBN(source.magnitude)
        self.sign = source.sign.rawValue
    }
    
    public init<T>(truncatingIfNeeded source: T) where T : BinaryInteger {
        self.magnitude = UBN(truncatingIfNeeded: source.magnitude)
        self.sign = Int(source.signum())
    }
    
    public init<T>(clamping source: T) where T : BinaryInteger {
        self.magnitude = UBN(clamping: source.magnitude)
        self.sign = Int(source.signum())
    }
    
    public init<T>(truncatingBits source: T) where T : BinaryInteger {
        self.magnitude = UBN(truncatingBits: source.magnitude)
        self.sign = Int(source.signum())
    }
    
    public init?<T>(exactly source: T) where T : BinaryInteger {
        self.magnitude = UBN(exactly: source.magnitude)!
        self.sign = Int(source.signum())
    }
    
    public init<T>(_ source: T) where T : BinaryInteger {
        self.magnitude = UBN(source.magnitude)
        self.sign = Int(source.signum())
    }
    
    public init(integerLiteral value: Int) {
        self.magnitude = UBigNumber(value.magnitude)
        self.sign = value.signum()
    }
    
    public init(arrayLiteral elements: UInt...) {
        self.magnitude = UBN(elements)
        self.sign = self.isZero ? 0 : 1
    }
    
    public init(stringLiteral hex: String) {
        if hex == "" { return }
        let stringIsNegative = hex.first! == "-"
        let string = stringIsNegative ? String(hex.dropFirst()) : hex
        self.magnitude = UBN(stringLiteral: string)
        self.sign = self.isZero ? 0 : (stringIsNegative ? -1 : 1)
    }
    
    public init(size: Int) {
        self.magnitude = UBN(size: size)
    }
    
    public init <T: BinaryInteger>(_ array: [T], bigEndian: Bool = false) {
        self.magnitude = UBN(array, bigEndian: bigEndian)
        self.sign = self.isZero ? 0 : 1
    }
    
    public init?(_ integer: Int) {
        self.magnitude = UBN(integer.magnitude)
        self.sign = integer.signum()
    }
    
    public init(randomBytes: Int, generator: SecRandomRef? = kSecRandomDefault) {
        
        self.magnitude = UBN(randomBytes: randomBytes, generator: generator)
        self.sign = self.isZero ? 0 : [-1, 1].randomElement()!
    
    }
    
    public init(data: Data) {
        
        self.magnitude = UBN(data: data)
        self.sign = self.isZero ? 0 : 1
        
    }

}
