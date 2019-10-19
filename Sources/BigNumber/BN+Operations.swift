//
//  BigNumber+Operations.swift
//  BigNumber
//
//  Created by Sylvan Martin on 9/1/19.
//  Copyright © 2019 Sylvan Martin. All rights reserved.
//

import Foundation

extension BigNumber: BinaryInteger {
    
    
    // MARK: - Casting
    
    static func matchSizes(a: inout BigNumber, b: inout BigNumber) {
        let size = maxOf(a.array.count, b.array.count)
        
        while a.size < size {
            a.array.append(0)
        }
        
        while b.size < size {
            b.array.append(0)
        }
    }
    
    // MARK: Range Operators
    
    /// Returns all values between two values, inclusive
    ///
    /// - Parameters:
    ///     - a: Lower bound
    ///     - b: Upper bound
    ///
    /// - Returns: An array of all values between ```a``` and ```b```
    #warning("This is an incredibly bad way of doing this and it's slow")
    public static func ... <RHS: BinaryInteger>(lhs: BigNumber, rhs: RHS) -> [BigNumber] {
        var range: [BigNumber] = []
        var lower = lhs
        
        while lower <= rhs {
            range.append(lower)
            lower += 1
        }
        return range
    }
    
    /// Returns all values between two values, excluding the upper bound
    ///
    /// - Parameters:
    ///     - a: Lower bound
    ///     - b: Upper bound
    ///
    /// - Returns: An array of all values between ```a``` and ```b```, excluding ```b```
    #warning("This is incredibly slow")
    public static func ..< <RHS: BinaryInteger>(lhs: BigNumber, rhs: RHS) -> [BigNumber] {
        var range: [BigNumber] = []
        var lower = lhs
        
        while lower < rhs {
            range.append(lower)
            lower += 1
            print(lower)
        }
        return range
    }
    
    // MARK: - Bitwise Operations
    
    /// One's compliment
    ///
    /// - Parameters:
    ///     - rhs: The BigNumber to get the compliment of
    ///
    /// - Returns: The binary compliment of the BigNumber
    public static prefix func ~ (rhs: BigNumber) -> BigNumber {
        return BigNumber( rhs.array.map { ~($0) } )
    }
    
    /// Bitwise OR operator
    ///
    /// Casts the smaller BigNumber to a BigNumber of the same size as the larger, and performs the bitwise OR operation, returning the resulting BigNumber
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: Bitwise OR of the two BigNumbers
    public static func | (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        // get the larger BigNumber
        
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
    /// Casts the smaller BigNumber to a BigNumber of the same size as the larger, and performs the bitwise AND operation, returning the resulting BigNumber
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: Bitwise AND of the two BigNumbers with a size of the larger BigNumber
    public static func & (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        // get the larger BigNumber
        
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
    /// Casts the smaller BigNumber to a BigNumber of the same size as the larger, and performs the bitwise XOR operation, returning the resulting BigNumber
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: Bitwise XOR of the two BigNumbers with a size of the larger BigNumber
    public static func ^ (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        // get the larger BigNumber
        
        var a = ((lhs.size >= rhs.size) ? lhs : rhs).keepingLeadingZeros
        var b = ((rhs.size >  lhs.size) ? lhs : rhs).keepingLeadingZeros
        
        matchSizes(a: &a, b: &b)
        
        // XOR every UInt64 in a with b
        for i in 0..<a.size {
            a[i] ^= b[i]
        }
        
        return a.erasingLeadingZeros
    }
    
    /// Left bitshifts the given BigNumber by a given integer amount, with no overflow handling
    ///
    /// - Parameters:
    ///     - lhs: BigNumber to bitshift
    ///     - rhs: Amount to bit shift
    ///
    /// - Returns: Exactly what you would expect
    static func &<< (lhs: BigNumber, rhs: Int) -> BigNumber {
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
    
    /// Right bitshifts the given BigNumber by a given integer amount
    ///
    /// - Parameters:
    ///     - lhs: BigNumber to bitshift
    ///     - rhs: Amount to bit shift
    ///
    /// - Returns: Exactly what you would expect
    public static func >> <RHS>(lhs: BigNumber, rhs: RHS) -> BigNumber where RHS : BinaryInteger {
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
    
    /// Left bitshifts the given BigNumber by a given integer amount with overflow handling.
    ///
    /// Any bit that would usually be discarded is instead put into a new array
    ///
    /// - Parameters:
    ///     - lhs: BigNumber to bitshift
    ///     - rhs: Amount to bit shift
    ///
    /// - Returns: Exactly what you would expect
    public static func << <RHS>(lhs: BigNumber, rhs: RHS) -> BigNumber where RHS : BinaryInteger {
        var a = lhs.keepingLeadingZeros
        a.array.append(0)
        
        for _ in 0..<rhs {
            // left bit shift a by 1
            for i in (1..<a.array.count).reversed() {
                // get bit about to be discarded
                a[i] <<= 1
                a[i] += a[i-1] >> 63
            }
            a[0] <<= 1
        }
        
        return a.erasingLeadingZeros
        
    }
    
    // MARK: Compound Assignment Bitwise Operators
    
    /// Stores the result of performing a bitwise OR operation on the two given
    /// values in the left-hand-side variable.
    ///
    /// - Parameters:
    ///   - lhs: A BigNumber value.
    ///   - rhs: Another BigNumber value.
    public static func |= (lhs: inout BigNumber, rhs: BigNumber) {
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
    }
    
    /// Stores the result of performing a bitwise AND operation on the two given
    /// values in the left-hand-side variable.
    ///
    /// - Parameters:
    ///   - lhs: A BigNumber value.
    ///   - rhs: Another BigNumber value.
    public static func &= (lhs: inout BigNumber, rhs: BigNumber) {
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

    }
    
    /// Stores the result of performing a bitwise XOR operation on the two given
    /// values in the left-hand-side variable.
    ///
    /// - Parameters:
    ///   - lhs: A BigNumber value.
    ///   - rhs: Another BigNumber value.
//    @discardableResult
    public static func ^= (lhs: inout BigNumber, rhs: BigNumber) /*-> BigNumber*/ {
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
        
    }
    
    
    public static func <<= <RHS>(lhs: inout BigNumber, rhs: RHS) where RHS : BinaryInteger {
        lhs = lhs << rhs
    }
    
    public static func >>= <RHS>(lhs: inout BigNumber, rhs: RHS) where RHS : BinaryInteger {
        lhs = lhs << rhs
    }
    
    // TODO: Do bit shift operators
    
    // MARK: - Comparative Operators
    
    /// Compares two BigNumbers, returns true if they are equal
    ///
    /// - Parameters:
    ///     - lhs: BigNumber to compare
    ///     - rhs: Another BigNumber to compare
    ///
    /// - Returns: True if they are equal, false if not
    public static func == (lhs: BigNumber, rhs: BigNumber) -> Bool {
        
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
    
    /// Compares two BigNumbers and retuns true if they are not equal
    ///
    /// - Parameters:
    ///     - lhs: BigNumber to compare
    ///     - rhs: Another BigNumber to compare
    ///
    /// - Returns: True if they are equal, false if not
    public static func != (lhs: BigNumber, rhs: BigNumber) -> Bool {
        return !(lhs == rhs)
    }
    
    /// Greater than operator
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: True if lhs > rpublic hs
    public static func > (lhs: BigNumber, rhs: BigNumber) -> Bool {
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
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: True if lhs < rhs
    public static func < (lhs: BigNumber, rhs: BigNumber) -> Bool {
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
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: Trpublic ue if lhs >= rpublic hs
    public static func >= (lhs: BigNumber, rhs: BigNumber) -> Bool {
        return lhs > rhs || lhs == rhs
    }
    
    /// Less than or Equal to Operator
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: True if lhs <= rpublic hs
    public static func <= (lhs: BigNumber, rhs: BigNumber) -> Bool {
        return lhs < rhs || lhs == rhs
    }
    
    // MARK: - Arithmetic Operators
    
    /// Adds two BigNumbers, with overflow allowed
    ///
    /// This won't add any elements to the BigNumber array
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: Sum of lhs and rhs without overflow prevention
    public static func &+ (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        var r = BigNumber(0).keepingLeadingZeros
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
    
    /// Adds two BigNumbers
    ///
    /// This will add elements to the array if needed
    ///
    /// - Parameters:
    ///     - lhs: BigNumber to add
    ///     - rhs: BigNumber to add
    ///
    /// - Returns: Sum of ```lhs``` and ```rhs```
    public static func + (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        
        var r = BigNumber(0).keepingLeadingZeros
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
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber to subtract from ```lhs```
    ///
    /// - Returns: Difference of ```lhs``` and ```rhs```
    public static func - (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        // cast smaller BigNumber to larger array
        //
        // note: in this operation, the numbers are treated as raw arrays, NOT BigNumber objects.
        // this is because a BigNumber will automatically get rid of leading zeros, which we actually need in order
        // to make sure the numbers have the same size of array
        
        var a = lhs.keepingLeadingZeros
        var b = rhs.keepingLeadingZeros
        
        // make sure both are the same size
        
        let size = maxOf(a.size, b.size)
        
        while a.size < size {
            a.array.append(0)
        }
        
        while b.size < size {
            b.array.append(0)
        }
        
        // Now do two's compliment subtraction and return
        return ((~b &+ 1) &+ a).erasingLeadingZeros
    }
    
    /// Multiplies two BigNumbers
    ///
    /// - Parameters:
    ///     - lhs: A BigNumber to multiply
    ///     - rhs: A BigNumber to multiply
    ///
    /// - Returns: Product of ```lhs``` and ```rhs```
    public static func * (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        var (a, b, product) : (BigNumber, BigNumber, BigNumber) = (lhs.keepingLeadingZeros, rhs.keepingLeadingZeros, 0)
        
        matchSizes(a: &a, b: &b)
        
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
    
    /// Divides two BigNumbers
    ///
    /// - Parameters:
    ///     - lhs: A BigNumber to divide
    ///     - rhs: BigNumber to divide ```rhs``` by
    ///
    /// - Returns: Product of ```lhs``` and ```rhs```
    public static func / (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        
        assert(rhs != 0, "Cannot divide by 0")
        
        var (a, b) = (lhs.keepingLeadingZeros, rhs.keepingLeadingZeros)
        
        // make them have the same size
        let size = maxOf(a.size, b.size)
        
        while a.size < size {
            a.array.append(0)
        }
        
        while b.size < size {
            b.array.append(0)
        }
        
        // now do the division
        
        var (quotient, remainder) : (BigNumber, BigNumber) = (0, 0)
        
        for i in (0..<b.bitWidth).reversed() {
            quotient = quotient << 1
            remainder = remainder << 1
            
            remainder |= (a & (BigNumber(1) << i)) >> i
            
            if (remainder >= b) {
                remainder = remainder - b;
                quotient |= 1;
            }
        }
        
        return quotient
    }
    
    /// Modulo operation for two ```BigNumber```'s
    ///
    /// - Parameters:
    ///     - lhs: ```BigNumber``` to modulo by another ```BigNumber```
    ///     - rhs: ```BigNumber``` by which to modulo
    ///
    /// - Returns: ```lhs``` modulo ```rhs```
    public static func % (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        assert(rhs != 0, "Cannot divide by 0")
        
        var (a, b) = (lhs.keepingLeadingZeros, rhs.keepingLeadingZeros)
        
        // make them have the same size
        let size = maxOf(a.size, b.size)
        
        while a.size < size {
            a.array.append(0)
        }
        
        while b.size < size {
            b.array.append(0)
        }
        
        // now do the division
        
        var remainder: BigNumber = 0
        
        for i in (0..<b.bitWidth).reversed() {
            remainder = remainder << 1
            
            remainder |= (a & (BigNumber(1) << i)) >> i
            
            if (remainder >= b) {
                remainder = remainder - b;
            }
        }
        
        return remainder
    }
    
    // MARK: Compound Assignment Arithmetic Operators
    
    /// Adds two BigNumbers and assigns the sum to the left operand
    ///
    /// This will add elements to the array if needed
    ///
    /// - Parameters:
    ///     - a: BigNumber to add and also the variable to store the result
    ///     - rhs: BigNumber to add to ```a```
    ///
    /// - Returns: Sum of ```a``` and ```rhs```
//    @discardableResult
    public static func += (a: inout BigNumber, rhs: BigNumber) /*-> BigNumber*/ {
        
        //var r = BigNumber(0).keepingLeadingZeros
        a.setShouldEraseLeadingZeros(to: false)
        let b = rhs.keepingLeadingZeros
        
        var carryOut: UInt64 = 0
        var carryIn:  UInt64 = 0
        
        let largerSize: Int = {
            let x = a.size
            let y = b.size
            return x >= y ? x : y
        }()
        
        for i in 0...largerSize {
            a[zeroing: i] &+= b[zeroing: i]
            if a[i] < a[zeroing: i] {
                carryOut = 1
            }
            if carryIn != 0 {
                a[i] &+= 1
                if ( 0 == a[i]) {
                    carryOut = 1
                }
            }
            carryIn = carryOut
            carryOut = 0
        }
        
//        return r.erasingLeadingZeros
    }
    
    #warning("This could be more efficient")
    public static func -= (lhs: inout BigNumber, rhs: BigNumber) {
        lhs = lhs - rhs
    }
    
    #warning("This could be more efficient")
    public static func *= (lhs: inout BigNumber, rhs: BigNumber) {
        lhs = lhs * rhs
    }
    
    #warning("This could be more efficient")
    public static func /= (lhs: inout BigNumber, rhs: BigNumber) {
        lhs = lhs / rhs
    }
    
    #warning("This could be more efficient")
    public static func %= (lhs: inout BigNumber, rhs: BigNumber) {
        lhs = lhs % rhs
    }
    
    
    
    // MARK: Private functions
    
    /// Returns the maximum of two comparables
    ///
    /// The reason this is being redeclafred is because of ambiguity errors
    ///
    /// - Parameters:
    ///     - a: Value to compare
    ///     - b: Another value to compate
    ///
    /// - Returns: The maximum of ```a``` and ```b```. If equal, it returns ```b```.
    private static func maxOf<T: Comparable>(_ a: T, _ b: T) -> T {
        return a > b ? a : b
    }
    
}
