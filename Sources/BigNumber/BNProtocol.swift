//
//  File.swift
//  
//
//  Created by Sylvan Martin on 5/31/22.
//

import Foundation

// These protocols are internal, and therfore are
// only so that I don't forget things. They are of no use to a client,
// they just make my job easier.

internal protocol RawBNProtocol: BinaryInteger, ExpressibleByStringLiteral, ExpressibleByArrayLiteral, ExpressibleByFloatLiteral {
    
    associatedtype WordType
    
    // MARK: Properties
    
    var isPowerOfTwo: Bool { get }
    
    var isZero: Bool { get }
    
    var words: Words { get }
    
    var size: Int { get }
    
    var sizeInBytes: Int { get }
    
    var binaryCompliment: Self { get }
    
    var hexString: String { get }
    
    var leastSignificantBitIsSet: Bool { get }
    
    var mostSignificantWord: WordType { get set }
    
    var leastSignificantWord: WordType { get set }
    
    var mostSignificantSetBitIndex: Int { get }
    
    var isNormal: Bool { get }
    
    var nonzeroBitCount: Int { get }
    
    // MARK: - Methods
    
    // MARK: Utility
    
    @discardableResult mutating func normalize() -> Self

    static func random(size: Int, generator: SecRandomRef?) -> Self
    
    mutating func setToZero() -> Self
    
    // MARK: Modular Methods
    
    func invMod(_ m: Self) -> Self
    
    static func modexp(a: Self, b: Self, m: Self, invPower: Bool) -> Self
    
    func gcd(_ b: Self) -> Self
    
    // MARK: Primality Tests
    
    func isProbablePrime() -> Bool
    
    static func generateProbablePrime(bytes: Int) -> Self
    
    // MARK: - Comparisons and Operations
    
    func equals(_ other: Self) -> Bool
    
    func compare <T : BinaryInteger> (to other: T) -> Int
    
    // MARK: Bitwise Operations
    
    @discardableResult mutating func or <T : BinaryInteger> (with other: T) -> Self
    
    @discardableResult mutating func and <T : BinaryInteger> (with other: T) -> Self
    
    @discardableResult mutating func xor <T : BinaryInteger> (with other: T) -> Self
    
    @discardableResult mutating func leftShift <T : BinaryInteger> (by other: T) -> Self
    
    @discardableResult mutating func rightShift <T : BinaryInteger> (by other: T) -> Self
    
    // MARK: Arithmetic Operations
    
    @discardableResult mutating func add <T : BinaryInteger> (_ other: T, withOverflowHandling: Bool) -> Self
    
    @discardableResult mutating func modadd (_ other: Self, m: Self) -> Self

    @discardableResult mutating func modsub (_ other: Self, m: Self) -> Self
    
    @discardableResult mutating func subtract <T : BinaryInteger> (_ other: T) -> Self
    
    static func multiply <T : BinaryInteger> (x: T, y: T, result: inout Self)
    
    static func modmul (x: Self, y: Self, m: Self, result: inout Self)
    
    static func divide <T : BinaryInteger> (dividend: T, divisor: T, quotient: inout Self, remainder: inout Self)
    
    func moddiv (by other: Self, m: Self) -> Self
    
    // MARK: Subscripts
    
    subscript (index: Int) -> WordType { get set }
    
    subscript (safe index: Int) -> WordType { get set }
    
    subscript (bit index: Int) -> WordType { get set }
    
    // MARK: Operators
    
    static func == (lhs: Self, rhs: Self) -> Bool
    
    static func != (lhs: Self, rhs: Self) -> Bool
    
    static func < (lhs: Self, rhs: Self) -> Bool
    
    static func > (lhs: Self, rhs: Self) -> Bool
    
    static func <= (lhs: Self, rhs: Self) -> Bool
    
    static func >= (lhs: Self, rhs: Self) -> Bool
    
    static func ... (lhs: Self, rhs: Self) -> ClosedRange<Self>
    
    static func ..< (lhs: Self, rhs: Self) -> Range<Self>
    
    static func |= (lhs: inout Self, rhs: Self)
    
    static func &= (lhs: inout Self, rhs: Self)
    
    static func ^= (lhs: inout Self, rhs: Self)
    
    static func <<= (lhs: inout Self, rhs: Self)
    
    static func >>= (lhs: inout Self, rhs: Self)
    
    static prefix func ~ (x: Self) -> Self
    
    static func | (lhs: Self, rhs: Self) -> Self
    
    static func & (lhs: Self, rhs: Self) -> Self
    
    static func ^ (lhs: Self, rhs: Self) -> Self
    
    static func << (lhs: Self, rhs: Self) -> Self
    
    static func >> (lhs: Self, rhs: Self) -> Self
    
    static func += (lhs: inout Self, rhs: Self)
    
    static func -= (lhs: inout Self, rhs: Self)
    
    static func *= (lhs: inout Self, rhs: Self)
    
    static func /= (lhs: inout Self, rhs: Self)
    
    static func %= (lhs: inout Self, rhs: Self)
    
    static func + (lhs: Self, rhs: Self) -> Self
    
    static func - (lhs: Self, rhs: Self) -> Self
    
    static func * (lhs: Self, rhs: Self) -> Self
    
    static func / (lhs: Self, rhs: Self) -> Self
    
    static func % (lhs: Self, rhs: Self) -> Self
    
}

internal protocol UBNProtocol: RawBNProtocol, UnsignedInteger {
    
    // MARK: Properties
    
    var twosCompliment: Self { get }
    
    // MARK: Initializers
    
    init(data: Data)
    
}

internal protocol BNProtocol: RawBNProtocol, SignedInteger {
    
    // MARK: Properties
    
    var negative: Self { get }
    
    var sign: Int { get }
    
    // MARK: Methods
    
    static func extgcd(a: Self, b: Self, x: inout Self, y: inout Self) -> Self
    
    mutating func set(sign: Int) -> Self
    
    
    
}
