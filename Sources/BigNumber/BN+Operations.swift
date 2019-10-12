//
//  BigNumber+Operations.swift
//  BigNumber
//
//  Created by Sylvan Martin on 9/1/19.
//  Copyright © 2019 Sylvan Martin. All rights reserved.
//

import Foundation

public extension BigNumber {
    
    // MARK: - Casting
    
    static func matchSizes(a: inout BN, b: inout BN) {
        let size = max(a.array.count, b.array.count)
        
        while a.size < size {
            a.array.append(0)
        }
        
        while b.size < size {
            b.array.append(0)
        }
    }
    
    // MARK: - Bitwise Operations
    
    /// One's compliment
    ///
    /// - Parameters:
    ///     - rhs: The BN to get the compliment of
    ///
    /// - Returns: The binary compliment of the BN
    static prefix func ~ (rhs: BN) -> BN {
        return BN( rhs.array.map { ~($0) } )
    }
    
    /// Bitwise OR operator
    ///
    /// Casts the smaller BN to a BN of the same size as the larger, and performs the bitwise OR operation, returning the resulting BN
    ///
    /// - Parameters:
    ///     - lhs: BN
    ///     - rhs: BN
    ///
    /// - Returns: Bitwise OR of the two BNs
    static func | (lhs: BN, rhs: BN) -> BN {
        // get the larger bn
        
        var a = ((lhs.size >= rhs.size) ? lhs : rhs).keepingLeadingZeros
        var b = ((rhs.size >  lhs.size) ? lhs : rhs).keepingLeadingZeros
        
        matchSizes(a: &a, b: &b)
        
        // OR every UInt64 in a with b
        for i in 0..<a.size {
            a[i] |= b[i]
        }
        
        return a.erasingLeadingZeros
    }
    
    /// Bitwise AND operator
    ///
    /// Casts the smaller BN to a BN of the same size as the larger, and performs the bitwise AND operation, returning the resulting BN
    ///
    /// - Parameters:
    ///     - lhs: BN
    ///     - rhs: BN
    ///
    /// - Returns: Bitwise AND of the two BNs with a size of the larger BN
    static func & (lhs: BN, rhs: BN) -> BN {
        // get the larger bn
        
        var a = ((lhs.size >= rhs.size) ? lhs : rhs).keepingLeadingZeros
        var b = ((rhs.size >  lhs.size) ? lhs : rhs).keepingLeadingZeros
        
        matchSizes(a: &a, b: &b)
        
        // AND every UInt64 in a with b
        for i in 0..<a.size {
            a[i] &= b[i]
        }
        
        return a.erasingLeadingZeros
    }
    
    /// Bitwise XOR operator
    ///
    /// Casts the smaller BN to a BN of the same size as the larger, and performs the bitwise XOR operation, returning the resulting BN
    ///
    /// - Parameters:
    ///     - lhs: BN
    ///     - rhs: BN
    ///
    /// - Returns: Bitwise XOR of the two BNs with a size of the larger BN
    static func ^ (lhs: BN, rhs: BN) -> BN {
        // get the larger bn
        
        var a = ((lhs.size >= rhs.size) ? lhs : rhs).keepingLeadingZeros
        var b = ((rhs.size >  lhs.size) ? lhs : rhs).keepingLeadingZeros
        
        matchSizes(a: &a, b: &b)
        
        // XOR every UInt64 in a with b
        for i in 0..<a.size {
            a[i] ^= b[i]
        }
        
        return a.erasingLeadingZeros
    }
    
    /// Left bitshifts the given BN by a given integer amount
    ///
    /// - Parameters:
    ///     - lhs: BN to bitshift
    ///     - rhs: Amount to bit shift
    ///
    /// - Returns: Exactly what you would expect
    static func << (lhs: BN, rhs: Int) -> BN {
        var a = lhs.keepingLeadingZeros
        
        for _ in 0..<rhs {
            // left bit shift a by 1
            for i in (1..<a.array.count).reversed() {
                // get bit about to be discarded
                a[i] <<= 1
                a[i] += a[i-1] >> 63
            }
            a[0] <<= 1
        }
        
        return a
        
    }
    
    /// Right bitshifts the given BN by a given integer amount
    ///
    /// - Parameters:
    ///     - lhs: BN to bitshift
    ///     - rhs: Amount to bit shift
    ///
    /// - Returns: Exactly what you would expect
    static func >> (lhs: BN, rhs: Int) -> BN {
        var a = lhs.keepingLeadingZeros
        
        for _ in 0..<rhs {
            // right bit shift a by 1
            for i in 0..<(a.array.count-1) {
                a[i] >>= 1
                if (a[i] & (1 << 63)) != (a[i+1] & 1) {
                    a[i] ^= 1 << 63
                }
            }
            a[a.array.count-1] >>= 1
        }
        
        return a
        
    }
    
    // MARK: Compound Assignment Bitwise Operators
    
    /// Stores the result of performing a bitwise OR operation on the two given
    /// values in the left-hand-side variable.
    ///
    /// - Parameters:
    ///   - lhs: A BN value.
    ///   - rhs: Another BN value.
    @discardableResult
    static func |= (lhs: inout BN, rhs: BN) -> BN {
        let largerSize: Int = {
            let x = lhs.size
            let y = rhs.size
            return x >= y ? x : y
        }()
        
        for i in 0..<largerSize {
            
            // make sure lhs is a valid size so we can actually assign values
            while lhs.size < i {
                lhs.array.append(0x0)
            }
            
            // now do the OR!
            lhs[i] |= rhs[safe: i] ?? 0x0
        }
        
        return lhs
    }
    
    /// Stores the result of performing a bitwise AND operation on the two given
    /// values in the left-hand-side variable.
    ///
    /// - Parameters:
    ///   - lhs: A BN value.
    ///   - rhs: Another BN value.
    @discardableResult
    static func &= (lhs: inout BN, rhs: BN) -> BN {
        let largerSize: Int = {
            let x = lhs.size
            let y = rhs.size
            return x >= y ? x : y
        }()
        
        for i in 0..<largerSize {
            
            // make sure lhs is a valid size so we can actually assign values
            while lhs.size < i {
                lhs.array.append(0x0)
            }
            
            // now do the OR!
            lhs[i] &= rhs[safe: i] ?? 0x0
        }
        
        return lhs
    }
    
    /// Stores the result of performing a bitwise XOR operation on the two given
    /// values in the left-hand-side variable.
    ///
    /// - Parameters:
    ///   - lhs: A BN value.
    ///   - rhs: Another BN value.
    @discardableResult
    static func ^= (lhs: inout BN, rhs: BN) -> BN {
        let largerSize: Int = {
            let x = lhs.size
            let y = rhs.size
            return x >= y ? x : y
        }()
        
        for i in 0..<largerSize {
            
            // make sure lhs is a valid size so we can actually assign values
            while lhs.size < i {
                lhs.array.append(0x0)
            }
            
            // now do the OR!
            lhs[i] ^= rhs[safe: i] ?? 0x0
        }
        
        return lhs
    }
    
    
    
    // TODO: Do bit shift operators
    
    // MARK: - Comparative Operators
    
    /// Compares two BNs, returns true if they are equal
    ///
    /// - Parameters:
    ///     - lhs: BN to compare
    ///     - rhs: Another BN to compare
    ///
    /// - Returns: True if they are equal, false if not
    static func == (lhs: BN, rhs: BN) -> Bool {
        
        let a = lhs.erasingLeadingZeros
        let b = rhs.erasingLeadingZeros
        
        guard a.size == b.size else { return false }
        
        for i in 0..<a.size {
            if a[i] != b[i] {
                return false
            }
        }
        
        return true
    }
    
    /// Compares two BNs and retuns true if they are not equal
    ///
    /// - Parameters:
    ///     - lhs: BN to compare
    ///     - rhs: Another BN to compare
    ///
    /// - Returns: True if they are equal, false if not
    static func != (lhs: BN, rhs: BN) -> Bool {
        return !(lhs == rhs)
    }
    
    /// Greater than operator
    ///
    /// - Parameters:
    ///     - lhs: BN
    ///     - rhs: BN
    ///
    /// - Returns: True if lhs > rhs
    static func > (lhs: BN, rhs: BN) -> Bool {
        let a = lhs.erasingLeadingZeros
        let b = rhs.erasingLeadingZeros
        
        if      a.size > b.size { return true  }
        else if a.size > b.size { return false }
        
        // the sizes are equal at this point
        for i in (0..<a.size).reversed() {
            if a[i] > b[i] {
                return true
            }
        }
        
        return false
    }
    
    /// Less than operator
    ///
    /// - Parameters:
    ///     - lhs: BN
    ///     - rhs: BN
    ///
    /// - Returns: True if lhs < rhs
    static func < (lhs: BN, rhs: BN) -> Bool {
        if      lhs.size < rhs.size { return true  }
        else if rhs.size < lhs.size { return false }
        
        // the sizes are equal at this point
        for i in (0..<lhs.size).reversed() {
            if lhs[i] > rhs[i] {
                return false
            }
        }
        
        return true
    }
    
    /// Greater than or Equal to Operator
    ///
    /// - Parameters:
    ///     - lhs: BN
    ///     - rhs: BN
    ///
    /// - Returns: True if lhs >= rhs
    static func >= (lhs: BN, rhs: BN) -> Bool {
        return lhs > rhs || lhs == rhs
    }
    
    /// Less than or Equal to Operator
    ///
    /// - Parameters:
    ///     - lhs: BN
    ///     - rhs: BN
    ///
    /// - Returns: True if lhs <= rhs
    static func <= (lhs: BN, rhs: BN) -> Bool {
        return lhs < rhs || lhs == rhs
    }
    
    // MARK: - Arithmetic Operators
    
    /// Adds two BNs, with overflow allowed
    ///
    /// This won't add any elements to the BN array
    ///
    /// - Parameters:
    ///     - lhs: BN
    ///     - rhs: BN
    ///
    /// - Returns: Sum of lhs and rhs without overflow prevention
    static func &+ (lhs: BN, rhs: BN) -> BN {
        var r = BN(0).keepingLeadingZeros
        let a = lhs.keepingLeadingZeros
        let b = rhs.keepingLeadingZeros
        
        var carryOut: UInt64 = 0
        var carryIn:  UInt64 = 0
        
        let largerSize: Int = {
            let x = a.size
            let y = b.size
            return x >= y ? x : y
        }()
        
        for i in 0..<largerSize {
            r[zeroing: i] = a[zeroing: i] &+ b[zeroing: i]
            if r[i] < a[zeroing: i] {
                carryOut = 1
            }
            if carryIn != 0 {
                r[i] &+= 1
                if ( 0 == r[i]) {
                    carryOut = 1
                }
            }
            carryIn = carryOut
            carryOut = 0
        }
        
        return r.erasingLeadingZeros
    }
    
    /// Adds two BNs
    ///
    /// This will add elements to the array if needed
    ///
    /// - Parameters:
    ///     - lhs: BN to add
    ///     - rhs: BN to add
    ///
    /// - Returns: Sum of ```lhs``` and ```rhs```
    static func + (lhs: BN, rhs: BN) -> BN {
        
        var r = BN(0).keepingLeadingZeros
        let a = lhs.keepingLeadingZeros
        let b = rhs.keepingLeadingZeros
        
        var carryOut: UInt64 = 0
        var carryIn:  UInt64 = 0
        
        let largerSize: Int = {
            let x = a.size
            let y = b.size
            return x >= y ? x : y
        }()
        
        for i in 0...largerSize {
            r[zeroing: i] = a[zeroing: i] &+ b[zeroing: i]
            if r[i] < a[zeroing: i] {
                carryOut = 1
            }
            if carryIn != 0 {
                r[i] &+= 1
                if ( 0 == r[i]) {
                    carryOut = 1
                }
            }
            carryIn = carryOut
            carryOut = 0
        }
        
        return r.erasingLeadingZeros
    }
    
    
    
    /// Subtraction
    ///
    /// - Parameters:
    ///     - lhs: BN
    ///     - rhs: BN to subtract from ```lhs```
    ///
    /// - Returns: Difference of ```lhs``` and ```rhs```
    static func - (lhs: BN, rhs: BN) -> BN {
        // cast smaller bn to larger array
        //
        // note: in this operation, the numbers are treated as raw arrays, NOT BN objects.
        // this is because a BN will automatically get rid of leading zeros, which we actually need in order
        // to make sure the numbers have the same size of array
        
        var a = lhs.keepingLeadingZeros
        var b = rhs.keepingLeadingZeros
        
        // make sure both are the same size
        
        let size = max(a.size, b.size)
        
        while a.size < size {
            a.array.append(0)
        }
        
        while b.size < size {
            b.array.append(0)
        }
        
        // Now do two's compliment subtraction and return
        return ((~b &+ 1) &+ a).erasingLeadingZeros
    }
    
    /// Multiplies two BNs
    ///
    /// - Parameters:
    ///     - lhs: A BN to multiply
    ///     - rhs: A BN to multiply
    ///
    /// - Returns: Product of ```lhs``` and ```rhs```
    static func * (lhs: BN, rhs: BN) -> BN {
        var (a, b, product) : (BN, BN, BN) = (lhs.keepingLeadingZeros, rhs.keepingLeadingZeros, 0)
        
        // make them have the same size
        let size = max(a.size, b.size)
        
        while a.size < size {
            a.array.append(0)
        }
        
        while b.size < size {
            b.array.append(0)
        }
        
        var i = 0
        
        while ( b > 0 ) {
            if (b & 1 == 1) {
                product = product + a << i
            }
            
            i += 1
            b = b >> 1
        }
        
        return product.erasingLeadingZeros
    }
    
    /// Divides two BNs
    ///
    /// - Parameters:
    ///     - lhs: A BN to divide
    ///     - rhs: BN to divide ```rhs``` by
    ///
    /// - Returns: Product of ```lhs``` and ```rhs```
    static func / (lhs: BN, rhs: BN) -> BN {
        
        assert(rhs != 0, "Cannot divide by 0")
        
        var (a, b) = (lhs.keepingLeadingZeros, rhs.keepingLeadingZeros)
        
        // make them have the same size
        let size = max(a.size, b.size)
        
        while a.size < size {
            a.array.append(0)
        }
        
        while b.size < size {
            b.array.append(0)
        }
        
        // now do the division
        
        var (quotient, remainder) : (BN, BN) = (0, 0)
        
        for i in (0..<b.sizeInBits).reversed() {
            quotient = quotient << 1
            remainder = remainder << 1
            
            remainder |= (a & (BN(1) << i)) >> i
            
            if (remainder >= b) {
                remainder = remainder - b;
                quotient |= 1;
            }
        }
        
        return quotient
    }
    
}
