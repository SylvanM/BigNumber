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
    func equals(_ other: UBigNumber) -> Bool {
        
        if other.size != self.size {
            return false
        }
        
        for i in 0..<self.size {
            if self[i] != other[i] {
                return false
            }
        }
        
        return true
        
    }
    
    /**
     * Compares this `UBN` to a `BinaryInteger, returning an `Int` representing their relation
     *
     * - Parameters:
     *      - other: `UBN` to compare
     *
     * - Returns: a positive integer if `self` is greater than `other`, a negative integer if `self` is less than `other`, and `0` if `self` is equal to `other`
     */
    func compare(to other: UBigNumber) -> Int {
        
        if self.size > other.size {
            return 1
        } else if self.size < other.size {
            return -1
        }

        // Compare most significant words
        for i in (0..<size).reversed() {
            if self[i] > other[i] {
                return 1
            }
            if self[i] < other[i] {
                return -1
            }
        }

        return 0

    }
    
    // MARK: - Bitwise Operations
    
    @discardableResult
    private mutating func applyWordwiseOp <T: BinaryInteger> (with other: T, operation: (WordType, WordType) -> WordType) -> UBigNumber {
        
        var otherWords = Words(other.words)
        otherWords += [WordType](repeating: 0, count: size > otherWords.count ? size - otherWords.count : 0)
        
        for i in 0..<otherWords.count {
            self[safe: i] = operation(self[safe: i], otherWords[i])
        }
        
        return normalize()
    }
    
    /**
     * OR's every word of this `UBigNumber` with the respective word of another `UBigNumber`
     *
     * - Parameters:
     *      - other: another `BinaryInteger` to OR with this one
     */
    @discardableResult mutating func or <T: BinaryInteger> (with other: T) -> UBigNumber {
        applyWordwiseOp(with: other, operation: |)
    }
    
    /**
     * AND's every word of this `UBigNumber` with the corresponding word of another `UBigNumber`
     *
     * - Parameters:
     *      - other: another `UBigNumber` to AND with this one
     */
    @discardableResult mutating func and <T: BinaryInteger> (with other: T) -> UBigNumber {
        applyWordwiseOp(with: other, operation: &)
    }
    
    /**
     * XOR's every word of this `UBigNumber` with the corresponding word of another `UBigNumber`
     *
     * - Parameters:
     *      - other: another `UBigNumber` to XOR with this one
     */
    @discardableResult mutating func xor <T: BinaryInteger> (with other: T) -> UBigNumber {
        applyWordwiseOp(with: other, operation: ^)
    }
    
    /**
     * Left shifts this `UBigNumber` by some integeral amount
     *
     * - Parameters:
     *      - shift: Amount by which to left shift this `UBigNumber`
     *      - handleOverflow: if `true`, this operation will append any necessary words to the `UInt` words of this `UBigNumber`
     */
    @discardableResult mutating func leftShift <T: BinaryInteger> (by shift: T) -> UBigNumber {
        
        if shift.signum() == -1 {
            rightShift(by: shift.magnitude)
        }
        
        if self.isZero || shift == 0 {
            return self
        }
        
        let wordShift = Int(shift) / WordType.bitWidth
        let bitShift  = Int(shift) % WordType.bitWidth
        
        // This is my implementation
        words += Words(repeating: 0, count: wordShift + (bitShift > mostSignificantWord.leadingZeroBitCount ? 1 : 0))

        for i in (wordShift..<size).reversed() {
            words[i] = words[i - wordShift]
        }

        for i in 0..<wordShift {
            words[i] = 0
        }

        for i in (1..<size).reversed() {
            words[i] <<= bitShift
            words[i] += words[i - 1] >> (WordType.bitWidth - bitShift)
        }

        words[0] <<= bitShift
        
        return self.normalize()
        
    }
    
    /**
     * Right shifts this `UBigNumber` by some integeral amount
     *
     * - Parameters:
     *   - shift: Amount by which to left shift this `BigNumber`
     */
    @discardableResult mutating func rightShift <T: BinaryInteger> (by shift: T) -> UBigNumber {
        
        if shift.signum() == -1 {
            leftShift(by: shift.magnitude)
        }
        
        let wordShift = Int(shift) / WordType.bitWidth
        let bitShift  = Int(shift) % WordType.bitWidth
        
        if wordShift >= size {
            self = 0
            return self
        }
        
        for i in 0..<(size - wordShift) {
            words[i] = words[i + wordShift]
        }
        
        for i in (size - wordShift)..<size {
            words[i] = 0
        }
        
        for i in 0..<(size - 1) {
            words[i] >>= bitShift
            words[i] += words[i + 1] << (WordType.bitWidth - bitShift)
        }
        words[size - 1] >>= bitShift
        
        return self.normalize()
        
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
    @discardableResult mutating func add <T: BinaryInteger> (_ other: T, withOverflowHandling handleOverflow: Bool = true) -> UBigNumber {
        
        let b = UBN(other)
        
        var carry: UInt
        
        let size = handleOverflow ? Swift.max(self.size, b.size) + 1 : size
        
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
    
    @discardableResult
    mutating func modadd(_ other: UBigNumber, m: UBigNumber) -> UBigNumber {
        self %= m
        self.add(other % m)
        self %= m
        return self
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
    
    mutating func modsub(_ other: UBigNumber, m: UBigNumber) -> UBigNumber {
        self %= m
        self.subtract(other % m)
        self %= m
        return self
    }
    
    /**
     * Multiplies `x` by another `y` and stores the result in `result`
     *
     * - Parameters:
     *      - x: `BinaryInteger` to multiply
     *      - y: `BinaryInteger` to multiply by
     *      - result: `UBigNumber` to store product of `x` and `y`
     *      - handleOverflow: if `true`, this operation will append any necessary words to this `UBigNumber`
     */
    static func multiply <T: BinaryInteger> (x: T, y: T, result: inout UBigNumber) {
        
        result = 0
        
        let a = UBN(x)
        let b = UBN(y)
        
        var carry: UInt = 0
        var i = 0
        
        if result.size < a.size + b.size {
            result.words = Words(repeating: 0, count: a.size + b.size)
        }
        
        if a == 0 || b == 0 {
            result.words = [0]
            return
        }
        
        if a == 1 {
            result = b
            return
        }
        
        if b == 1 {
            result = a
            return
        }
        
        for j in 0..<b.size {
            carry = 0
            
            i = 0
            while i < a.size {
                UInt.addmul(lo: &result[i+j], hi: &carry, a: a[i], b: b[j], c: carry, d: result[i+j])
                i += 1 // Swift doesn't have C-style for loops :(
            }
            
            result[i+j] = carry
            
        }
        
        result.normalize()
        
    }

    /**
     * Raises `self` to the power of `power`
     */
    func pow(_ power: UBigNumber) -> UBigNumber {
        // TODO: Make this not super slow!
        
        var countdown = power
        var product = UBN(1)
        
        while countdown != 0 {
            product *= self
            countdown -= 1
        }
        
        return product
        
    }
    
    static func modmul(x: UBigNumber, y: UBigNumber, m: UBigNumber, result: inout UBigNumber) {
        multiply(x: x % m, y: y % m, result: &result)
        result %= UBN(m)
    }
    
    /**
     * Divides `dividend` by `divisor`, and stores the quotient and remainder in given objects
     *
     * - Parameters:
     *      - dividend: `BinaryInteger` dividend
     *      - divisor: `BinaryInteger`
     *      - quotient: `UBigNumber` object that stores the quotient
     *      - remainder: `UBigNumber` object that stores the remainder
     */
    static func divide (dividend: UBigNumber, divisor: UBigNumber, quotient: inout UBigNumber, remainder: inout UBigNumber) {
        
        quotient = 0
        remainder = dividend
        
        let cmp = dividend.compare(to: divisor)
        
        if divisor == 0 {
            fatalError("Cannot divide by 0")
        }
        
        if cmp == -1 {
            return
        }
            
        else if cmp == 0 {
            remainder = 0
            quotient = 1
            return
        }
        
        if quotient.size < dividend.size - divisor.size + 1 {
            quotient.words = Words(repeating: 0, count: dividend.size - divisor.size + 1)
        }
        
        var partialProduct: UBigNumber = 0
        
        while remainder >= divisor {
            
            var partialQuotient: UBigNumber = 1
            
            if remainder.mostSignificantWord >= divisor.mostSignificantWord {
                // these are checking different actual words. the MSW of remainder may be its 2nd word, MSB of divisor might be 1st word. is that okay?
                partialQuotient.leastSignificantWord = remainder.mostSignificantWord / divisor.mostSignificantWord
                
                partialQuotient.leftShift(by: (remainder.size - divisor.size) * WordType.bitWidth)
            }
            else {
                partialQuotient.leftShift(by: (remainder.size - divisor.size) * WordType.bitWidth
                                          + divisor.mostSignificantWord.leadingZeroBitCount
                                          - remainder.mostSignificantWord.leadingZeroBitCount)
            }
            
            
            multiply(x: divisor, y: partialQuotient, result: &partialProduct)
            
            while partialProduct > remainder {
                
                if partialQuotient.leastSignificantWord & 1 == 0 {
                    partialProduct.rightShift(by: 1)
                    partialQuotient.rightShift(by: 1)
                }
                else {
                    partialQuotient.leastSignificantWord -= 1
                    partialProduct.subtract(divisor)
                }
                
            }
            remainder.subtract(partialProduct)
            quotient.add(partialQuotient)
            
        }
        
    }
    
    func moddiv(by other: UBigNumber, m: UBigNumber) -> UBigNumber {
        let invm = other.invMod(m)
        var product = UBN()
        UBN.modmul(x: self, y: invm, m: m, result: &product)
        return product
    }
    
}
