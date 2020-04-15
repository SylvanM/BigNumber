//
//  File.swift
//  
//
//  Created by Sylvan Martin on 3/16/20.
//

import Foundation

public extension UBigNumber {
    
    // MARK: - Comparison
    
    /**
     * Checks if another `UBN` equals this one
     *
     * - Parameters:
     *      - other: `UBN` to compare
     *
     * - Returns: `true` if the numbers are numerically equivalent
     */
    func equals(_ other: UBN) -> Bool {
        
        var thisHash  = Hasher()
        var otherHash = Hasher()
        
        self.hash(into: &thisHash)
        other.hash(into: &otherHash)
        
        return thisHash.finalize() == otherHash.finalize()
    }
    
    /**
     * Compares this `UBN` to another, returning an `Int` representing their relation
     *
     *
     */
    func compare(to other: UBN) -> Int {
        
        let a = self.normalized
        let b = other.normalized
        
        if a.size > b.size {
            return 1
        }
        
        if a.size < b.size {
            return -1
        }
        
        if a.equals(b) {
            return 0
        }
        
        for i in 0..<size {
            if a[a.size - 1 - i] < b[b.size - 1 - i] {
                return -1
            }
            // I figured that checking for non-equivalence would be faster than checking for it being greater than.
            if a[a.size - 1 - i] != b[b.size - 1 - i] {
                return 1
            }
        }
        
        return -2 // this should not be reached, so return -2 to show an error was made
        
    }
    
    // MARK: - Bitwise Operations
    
    /**
     * OR's every word of this `UBigNumber` with the respective word of another `UBigNumber`
     *
     * - Parameters:
     *      - other: another `UBigNumber` to OR with this one
     */
    @discardableResult mutating func or <T: BinaryInteger> (with other: T) -> UBigNumber {
        let size = self.words.count > other.words.count ? self.words.count : other.words.count
        
        for i in 0..<size {
            self.words[i] |= other.words[i]
        }
        
        return self
    }
    
    /**
     * AND's every word of this `UBigNumber` with the corresponding word of another `UBigNumber`
     *
     * - Parameters:
     *      - other: another `UBigNumber` to AND with this one
     */
    @discardableResult mutating func and <T: BinaryInteger> (with other: T) -> UBigNumber {
        let size = self.words.count > other.words.count ? self.words.count : other.words.count
        
        for i in 0..<size {
            self.words[i] &= other.words[i]
        }
        
        return self
    }
    
    /**
     * XOR's every word of this `UBigNumber` with the corresponding word of another `UBigNumber`
     *
     * - Parameters:
     *      - other: another `UBigNumber` to XOR with this one
     */
    @discardableResult mutating func xor <T: BinaryInteger> (with other: T) -> UBigNumber {
        let size = self.words.count > other.words.count ? self.words.count : other.words.count
        
        for i in 0..<size {
            self.words[i] ^= other.words[i]
        }
        
        return self
    }
    
    /**
     * Left shifts this `UBigNumber` by some integeral amount
     *
     * - Parameters:
     *   - shift: Amount by which to left shift this `UBigNumber`
     *   - handleOverflow: if `true`, this operation will append any necessary words to the `UInt64` words of this `UBigNumber`
     */
    @discardableResult mutating func leftShift <T: BinaryInteger> (by shift: T, withOverflowHandling handleOverflow: Bool = true) -> UBigNumber {
        
        if shift.signum() == -1 {
            rightShift(by: shift * -1)
        }
        
        let wordShift = Int(shift) / UInt.bitSize
        let bitShift  = Int(shift) % UInt.bitSize
        
        if handleOverflow && wordShift != 0 {
            words += Words(repeating: 0, count: Int(wordShift))
        }
        
        if wordShift != 0 {
            for i in (1..<size).reversed() {
                words[i] = words[i - 1]
            }
            words[0] = 0
        }
        
        if bitShift != 0 {
            for i in (1..<size).reversed() {
                words[i] <<= bitShift
                words[i] += words[i - 1] >> (UInt.bitSize - bitShift)
            }
            words[0] <<= bitShift
        }
        
        return self.normalize()
        
    }
    
    /**
     * Left shifts this `UBigNumber` by some integeral amount
     *
     * - Parameters:
     *   - shift: Amount by which to left shift this `UBigNumber`
     */
    @discardableResult mutating func rightShift <T: BinaryInteger> (by shift: T) -> UBigNumber {
        
        if shift.signum() == -1 {
            leftShift(by: shift * -1)
        }
        
        let wordShift = Int(shift) / UInt.bitSize
        let bitShift  = Int(shift) % UInt.bitSize
        
        if wordShift != 0 {
            for i in 0..<(size - 1) {
                words[i] = words[i + 1]
            }
            words[size - 1] = 0
        }
        
        if bitShift != 0 {
            for i in 0..<(size - 1) {
                words[i] >>= bitShift
                words[i] += words[i + 1] << (UInt.bitSize - bitShift)
            }
            words[size - 1] >>= bitShift
        }
        
        normalize()
        
        return self
        
    }
    
    // MARK: - Arithmetic Operations
    
    /**
     * Adds another `BinaryInteger` to this `UBigNumber`
     *
     * - Parameters:
     *   - other: A `BinaryInteger` to add to this `UBigNumber`
     *   - handleOverflow: if `true`, this operation will append any necessary words to this `UBigNumber`
     *
     * - Returns: Sum of `self` and `other`
     */
    @discardableResult mutating func add (_ b: UBigNumber, withOverflowHandling handleOverflow: Bool = true) -> UBigNumber {
        
        var carry: UInt
        
        let size = handleOverflow ? Swift.max(self.size, b.size) + 1 : self.size
        
        if size > self.size {
            self.words += Words(repeating: 0, count: size - self.size)
        }
        
        carry = 0
        
        for i in 0..<size {
            self[i] &+= carry
            carry = self[i] < carry ? 1 : 0
            self[i] &+= b[safe: i]
            carry = self[i] < b[safe: i] ? 1 : carry
        }
        
        return self.normalize()
        
    }
    
    /// Subtracts a numerical value from this `UBN`
    /// - Parameter other: `BinaryInteger` to subtract
    /// - Returns: difference of `self` and `other`
    @discardableResult mutating func subtract <T: BinaryInteger> (_ other: T) -> UBigNumber {
        var b = UBN(other)
        
        if b.size < self.size {
            b.words += Words(repeating: 0, count: self.size - b.size)
        }
        
        self.add(b.twosCompliment, withOverflowHandling: false)
        return self.normalize()
    }
    
    /**
     * Multiplies `self` by another `BinaryInteger` and stores the result in `result`
     *
     * - Parameters:
     *      - x: `BinaryInteger` to multiply
     *      - y: `BinaryInteger` to multiply by
     *      - result: `UBigNumber` to store product of `a` and `b`
     *      - handleOverflow: if `true`, this operation will append any necessary words to this `UBigNumber`
     */
    static func multiply <T: BinaryInteger> (x: T, by y: T, result: inout UBigNumber, withOverflowHandling handleOverflow: Bool = true) {
        
        let a = UBN(x)
        let b = UBN(y)
        
        var carry: UInt = 0
        var i = 0
        
        if result.size < a.size + b.size {
            result.words = Words(repeating: 0, count: a.size + b.size)
        }
        
        if a == 0 || b == 0 {
            result.normalize()
            return
        }
        
        if a == 1 {
            result = b
            result.normalize()
            return
        }
        
        if b == 1 {
            result = a
            result.normalize()
            return
        }
        
        for j in 0..<b.size {
            carry = 0
            
            i = 0
            while i < a.size {
                UInt.addmul(lo: &result[i+j], hi: &carry, a: a[i], b: b[j], c: carry, d: result[i+j])
                i += 1 // Swift 5 doesn't have C-style for loops :(
            }
            
            result[i+j] = carry
            
        }
        
        result.normalize()
        
    }
    
    /**
     * Divides `a` by `b`, and stores the quotient and remainder in given objects
     *
     * - Parameters:
     *      - dividend: `BinaryInteger` dividend
     *      - divisor: `BinaryInteger`
     *      - quotient: `UBigNumber` object that stores the quotient
     *      - remainder: `UBigNumber` object that stores the remainder
     */
    static func divide <T: BinaryInteger> (dividend: T, divisor: T, quotient: inout UBigNumber, remainder: inout UBigNumber) {
        
        let a = UBN(dividend)
        let b = UBN(divisor)
        
        quotient = 0
        remainder = a
        
        let cmp = a.compare(to: b)
        
        if divisor == 0 {
            fatalError("Cannot divide by 0")
        }
        
        if cmp == -1 {
            return
        }
        else if cmp == 0 {
            remainder = 0
            remainder.normalize()
            quotient = 1
            return
        }
        
        if quotient.size < a.size - b.size + 1 {
            quotient.words = Words(repeating: 0, count: a.size - b.size + 1)
        }
        
        var partialProduct = a
        var partialQuotient = a
        
        while -1 != remainder.compare(to: b) {
            
            partialQuotient = 1
            
            if remainder.mostSignificantWord >= b.mostSignificantWord {
                partialQuotient[0] = remainder.mostSignificantWord / b.mostSignificantWord
                partialQuotient.leftShift(by: (remainder.size - b.size) * 64)
            }
            else {
                partialQuotient.leftShift(by: (remainder.size - b.size) * 64 + b.mostSignificantWord.leadingZeroBitCount - remainder.mostSignificantWord.leadingZeroBitCount)
            }
            
            multiply(x: b, by: partialQuotient, result: &partialProduct)
            
            while 1 == partialProduct.compare(to: remainder) {
                
                if partialProduct.leastSignificantWord & 1 == 0 {
                    partialProduct.rightShift(by: 1)
                    partialQuotient.rightShift(by: 1)
                }
                else {
                    partialQuotient[0] &-= 1
                    partialProduct.subtract(b)
                }
                
            }
            
            remainder.subtract(partialProduct)
            quotient.add(partialQuotient)
            
        }
        
    }
    
    // MARK: - Logarithmic Operations
    
    /**
     * The Binary Logarithm
     *
     * - Parameters:
     *      - a: `UBigNumber` of which to computer the binary logarithm
     *
     * - Returns: The binary logarithm of `a`
     */
    static func log(_ a: UBigNumber) -> UBigNumber {
        a.mostSignificantBitIndex
    }
    
}
