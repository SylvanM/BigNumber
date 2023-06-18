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
    
    var hexString: String { get }
    
    var mostSignificantWord: WordType { get }
    
    var leastSignificantWord: WordType { get }
    
    var mostSignificantSetBitIndex: Int { get }
    
    var isNormal: Bool { get }
    
    var nonzeroBitCount: Int { get }
    
    // MARK: - Methods
    
    // MARK: Utility
    
    @discardableResult mutating func normalize() -> Self
    
    static func random(bytes: Int, generator: SecRandomRef?) -> Self

    static func random(words: Int, generator: SecRandomRef?) -> Self
    
    mutating func setToZero() -> Self
    
    // MARK: Initializers
    
    init(_: BigNumber, mod: Int)
    
    init(_: UBigNumber, mod: Int)
    
    init(_: Self)
    
    // MARK: Modular Methods
    
    func invMod(_ m: Self) -> Self
    
    static func gcd(_ a: Self, _ b: Self) -> Self
    
    // MARK: Primality Tests
    
    func isProbablePrime() -> Bool
    
    static func generateProbablePrime(bytes: Int) -> Self
    
    // MARK: Subscripts
    
    subscript (index: Int) -> WordType { get set }
    
    subscript (safe index: Int) -> WordType { get set }
    
    subscript (bit index: Int) -> WordType { get set }
    
    // MARK: Operators
    
    func quotientAndRemainder(dividingBy divisor: Self) -> (quotient: Self, remainder: Self)
    
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
    
    // MARK: Initializers
    
    init(data: Data)
    
}

internal protocol BNProtocol: RawBNProtocol, SignedInteger {
    
    // MARK: Properties
    
    var negative: Self { get }
    
    var absoluteValue: Self { get }
    
    var sign: Int { get }
    
    // MARK: Methods
    
    func mod(_ m: Self) -> Self
    
    static func extendedEuclidean(a: Self, b: Self) -> (g: Self, x: Self, y: Self)
    
    static prefix func - (x: Self) -> Self
    
}
