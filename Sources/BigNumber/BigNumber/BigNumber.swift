//
//  BigNumber.swift
//  
//
//  Created by Sylvan Martin on 5/31/22.
//

import Foundation

/// A signed ```BigNumber``` object
public typealias BN = BigNumber

/**
 * A signed integer type of arbitrary size
 */
public struct BigNumber: BNProtocol {
    
    public typealias WordType = Magnitude.WordType
    
    public typealias Words = Magnitude.Words
    
    public typealias StringLiteralType = Magnitude.StringLiteralType
    
    public typealias ArrayLiteralElement = Magnitude.ArrayLiteralElement
    
    public typealias FloatLiteralType = Magnitude.FloatLiteralType
    
    public typealias IntegerLiteralType = Int
    
    public typealias Magnitude = UBigNumber
    
    // MARK: Properties
    
    public internal(set) var magnitude: UBigNumber
    
    /**
     * `-1` if this value is negative, `0` if this value is zero, `1` if this value is positive
     */
    public internal(set) var sign: Int
    
    public var words: Magnitude.Words {
        get { magnitude.words }
    }
    
    public var bitWidth: Int {
        magnitude.bitWidth + sign.bitWidth
    }
    
    public var trailingZeroBitCount: Int {
        magnitude.trailingZeroBitCount
    }
    
    public var size: Int {
        magnitude.size
    }
    
    public var negative: BN {
        BN(sign: self.sign * -1, magnitude: self.magnitude)
    }
    
    public var isZero: Bool {
        sign == 0
    }
    
    var isPowerOfTwo: Bool {
        sign == 1 && magnitude.isPowerOfTwo
    }
    
    var sizeInBytes: Int {
        magnitude.sizeInBytes + MemoryLayout<Int>.size
    }
    
    var hexString: String {
        (sign == -1 ? "-" : "") + magnitude.hexString
    }
    
    public var description: String {
        (sign == -1 ? "-" : "") + magnitude.description
    }
    
    var leastSignificantBitIsSet: Bool {
        magnitude.leastSignificantBitIsSet
    }
    
    var mostSignificantWord: Magnitude.WordType {
        get { magnitude.mostSignificantWord }
    }
    
    var leastSignificantWord: Magnitude.WordType {
        get { magnitude.leastSignificantWord }
    }
    
    var mostSignificantSetBitIndex: Int {
        magnitude.mostSignificantSetBitIndex
    }
    
    var isNormal: Bool {
        magnitude.isNormal && ((sign == 0) == (words == [0]))
    }
    
    var nonzeroBitCount: Int {
        magnitude.nonzeroBitCount + sign.nonzeroBitCount
    }
    
    var isEven: Bool {
        magnitude.isEven
    }
    
    var absoluteValue: BigNumber {
        BigNumber(magnitude)
    }
    
    // MARK: Initializers
    
    /**
     * Initializes a `BigNumber` as another `BigNumber`, modulo some modulus.
     */
    public init(_ other: BigNumber, mod m: Int) {
        self.magnitude = UBN(other, mod: m)
        self.sign = 1
    }
    
    /**
     * Initializes a `BigNumber` as a `UBigNumber`, modulo some modulus.
     */
    public init(_ other: UBigNumber, mod m: Int) {
        self.init(UBN(other, mod: m))
    }
    
    public init(_ other: BN) {
        self.sign = other.sign
        self.magnitude = other.magnitude
    }
    
    public init(_ magnitude: UBN) {
        self.init(sign: 1, magnitude: magnitude)
    }
    
    public init(sign: Int, magnitude: UBN) {
        self.magnitude = magnitude
        self.sign = sign
        normalize()
    }
    
    public init(arrayLiteral elements: Magnitude.ArrayLiteralElement...) {
        self.magnitude = UBN(array: elements)
        self.sign = magnitude.isZero ? 0 : 1
    }
    
    public init(integerLiteral value: Int) {
        self.magnitude = UBN(integerLiteral: value.magnitude)
        self.sign = value.signum()
        normalize()
    }
    
    public init(floatLiteral value: Magnitude.FloatLiteralType) {
        self.init(exactly: value)!
    }
    
    public init(stringLiteral value: Magnitude.StringLiteralType) {
        self.init(value)
    }
    
    public init(_ string: String) {
        var fixedString = string
        
        if let firstCharacter = fixedString.first, firstCharacter == "-" {
            sign = -1
            fixedString = String(string.dropFirst())
        } else {
            sign = 1
        }
        
        self.magnitude = UBN(stringLiteral: fixedString)
        if magnitude.isZero { self.sign = 0 }
    }
    
    public init?<T>(exactly source: T) where T : BinaryFloatingPoint {
        self.magnitude = UBN(floatLiteral: source.magnitude)
        self.sign = source.sign == .minus ? -1 : 1
        if self.magnitude == 0 {
            self.sign = 0
        }
    }
    
    public init<T>(_ source: T) where T : BinaryFloatingPoint {
        self.init(exactly: source)!
    }
    
    public init<T>(_ source: T) where T : BinaryInteger {
        self.magnitude = UBN(source.magnitude)
        self.sign = Int(source.signum())
    }
    
    public init?<T>(exactly source: T) where T : BinaryInteger {
        guard let mag = UBN(exactly: source.magnitude) else { return nil }
        self.magnitude = mag
        self.sign = Int(source.signum())
    }
    
    public init<T>(clamping source: T) where T : BinaryInteger {
        self.magnitude = UBN(clamping: source.magnitude)
        self.sign = Int(source.signum())
    }
    
    public init<T>(truncatingIfNeeded source: T) where T : BinaryInteger {
        self.magnitude = UBN(truncatingIfNeeded: source.magnitude)
        self.sign = Int(source.signum())
    }
    
}
