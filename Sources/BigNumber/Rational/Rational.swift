//
//  Rational.swift
//  
//
//  Created by Sylvan Martin on 6/3/23.
//

import Foundation

/**
 * A representation of an arbitrary-precision rational number, composed of a numerator and denominator of `BigNumber`s.
 */
public struct Rational: SignedNumeric, ExpressibleByFloatLiteral, ExpressibleByStringLiteral, Comparable {
    
    public typealias Magnitude = Rational
    
    public typealias IntegerLiteralType = Int
    
    public typealias StringLiteralType = String
    
    public typealias FloatLiteralType = Double
    
    // MARK: Properties
    
    /**
     * The numerator of this fraction.
     * - Invariant: `numerator / denominator` is always in simplest form.
     */
    public internal(set) var numerator: BigNumber
    
    /**
     * The denominator of this fraction.
     * - Invariant: `denominator` is never zero, is always positive, and `numerator / denominator` is always in simplest form.
     */
    public internal(set) var denominator: BigNumber
    
    /**
     * The sign of this `Rational`
     */
    public var sign: Int {
        numerator.sign
    }
    
    /**
     * Whether or not this number represents 0
     */
    public var isZero: Bool {
        numerator == 0
    }
    
    /**
     * Whether or not this number is an integer
     */
    public var isIntegral: Bool {
        denominator == 1
    }
    
    /**
     * The inverse of this number, if this isn't zero
     */
    public var inverse: Rational {
        var inv = self
        inv.invert()
        return inv
    }
    
    public var magnitude: Rational {
        Rational(numerator: numerator * BN(sign), denominator: denominator)
    }
    
    // MARK: Initializers
    
    public init(numerator: BigNumber, denominator: BigNumber) {
        self.numerator = numerator
        self.denominator = denominator
        self.simplify()
    }
    
    public init(floatLiteral value: FloatLiteralType) {
        self.init(stringLiteral: value.description) // lol
    }
    
    /**
     * Initializes a `Rational` from a base-10 string literal
     */
    public init(stringLiteral value: String) {
        self.init(value)
    }
    
    public init(integerLiteral value: Int) {
        self.numerator = BN(value)
        self.denominator = 1
    }
    
    /**
     * Initializes a `Rational` from a string written in base 10, perhaps with some e notation, like `"4.23443e-10"` or something
     */
    public init(_ string: String) {
        var fullStringLiteral = string
        var exponent = 0
        
        // if the string ends in "e23" or "e-199" or something, get that component!
        if let ePosition = fullStringLiteral.firstIndex(of: "e") {
            let exponentString = fullStringLiteral[(fullStringLiteral.index(after: ePosition))..<fullStringLiteral.endIndex]
            exponent = Int(exponentString)!
            
            fullStringLiteral = String(fullStringLiteral.dropLast(exponentString.count + 1))
        }
        
        // find out how far the decimal was from the end
        if let decimalIndex = fullStringLiteral.firstIndex(of: ".") {
            exponent -= fullStringLiteral.distance(from: decimalIndex, to: fullStringLiteral.endIndex) - 1
            
            // now get rid of that decimal!
            fullStringLiteral.remove(at: decimalIndex)
        }
        
        // by now, fullStringLiteral should be an integer
        
        numerator = BN(stringLiteral: fullStringLiteral.appending(String(repeating: "0", count: max(0, exponent))))
        denominator = BN(10).pow(BigNumber(max(0, -exponent)))
        simplify()
    }
    
    public init?<T>(exactly source: T) where T : BinaryInteger {
        numerator = BigNumber(source)
        denominator = 1
    }
    
    // MARK: Utility
    
    /**
     * Inverts this `Rational`
     */
    public mutating func invert() {
        assert(!isZero, "Division by zero error")
        let temp = numerator
        self.numerator = denominator
        self.denominator = temp
    }
    
    internal mutating func simplify() {
        if isZero {
            numerator = 0
            denominator = 1
        } else {
            let g = numerator.gcd(denominator)
            numerator /= g
            denominator /= g
        }
    }
    
}
