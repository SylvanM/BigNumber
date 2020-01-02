//
//  File.swift
//
//
//  Created by Sylvan Martin on 12/10/19.
//

import Foundation

extension BigNumber: BinaryInteger, Comparable, Equatable {

    // MARK: - Comparison Operators

    public static func == (lhs: BigNumber, rhs: BigNumber) -> Bool {
        return ( lhs.sign == 0 && rhs.sign == 0 ) || ( lhs.magnitude == rhs.magnitude && lhs.sign == rhs.sign )
    }

    public static func != (lhs: BigNumber, rhs: BigNumber) -> Bool {
        return !(lhs == rhs)
    }

    public static func > (lhs: BigNumber, rhs: BigNumber) -> Bool {
        return ( lhs.sign > rhs.sign ) ? true : (
                !( lhs.sign == 0 && rhs.sign == 0 ) && ( lhs.sign >= rhs.sign ) &&
                (lhs.sign < 0) ? (lhs.magnitude < rhs.magnitude) : (lhs.magnitude > rhs.magnitude))
    }

    public static func < (lhs: BigNumber, rhs: BigNumber) -> Bool {
        return lhs != rhs && !(lhs > rhs)
    }

    public static func >= (lhs: BigNumber, rhs: BigNumber) -> Bool {
        return lhs == rhs || lhs > rhs
    }

    public static func <= (lhs: BigNumber, rhs: BigNumber) -> Bool {
        return lhs == rhs || lhs < rhs
    }
    
    // MARK: Bitwise Operators
    
    public static prefix func - (a: BigNumber) -> BigNumber {
        var neg = a
        neg.sign *= -1
        return neg
    }
    
    public static func <<= <RHS>(lhs: inout BigNumber, rhs: RHS) where RHS : BinaryInteger {
        lhs.magnitude <<= rhs.magnitude
    }
    
    public static func >>= <RHS>(lhs: inout BigNumber, rhs: RHS) where RHS : BinaryInteger {
        lhs.magnitude >>= rhs.magnitude
    }
    
    public static func &= (lhs: inout BigNumber, rhs: BigNumber) {
        lhs.magnitude &= rhs.magnitude
    }
    
    public static func |= (lhs: inout BigNumber, rhs: BigNumber) {
        lhs.magnitude |= rhs.magnitude
    }
    
    public static func ^= (lhs: inout BigNumber, rhs: BigNumber) {
        lhs.magnitude ^= rhs.magnitude
    }
    
    
    // MARK: Arithmetic Operators
    
    public static prefix func ~ (x: BigNumber) -> BigNumber {
        return BigNumber(~(x.magnitude))
    }
    
    public static func / (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        var a = lhs
        a /= rhs
        return a
    }
    
    public static func /= (lhs: inout BigNumber, rhs: BigNumber) {
        lhs.magnitude /= rhs.magnitude
        lhs.sign *= rhs.sign
    }
    
    public static func % (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        var a = lhs
        a %= rhs
        return a
    }
    
    public static func %= (lhs: inout BigNumber, rhs: BigNumber) {
        lhs.magnitude %= rhs.magnitude
    }
    
    public static func -= (lhs: inout BigNumber, rhs: BigNumber) {
        lhs += -rhs
    }
    
    public static func - (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        var a = lhs
        a -= rhs
        return a
    }
    
    public static func += (lhs: inout BigNumber, rhs: BigNumber) {
        if lhs.sign == rhs.sign {
            lhs.magnitude += rhs.magnitude
            return
        }

        if rhs.magnitude > lhs.magnitude {
            lhs.magnitude -= rhs.magnitude
            lhs.sign *= -1
        }

        lhs.magnitude += rhs.magnitude
    }

    public static func + (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        var a = lhs
        a += rhs
        return a
    }

    public static func *= (lhs: inout BigNumber, rhs: BigNumber) {
        // first just multiply the magnitudes
        lhs.magnitude *= rhs.magnitude
        
        // now do the sign stuff
        lhs.sign *= rhs.sign
    }

    public static func * (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        var a = lhs
        a *= rhs
        return rhs
    }
    
}
