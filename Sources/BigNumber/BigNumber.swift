//
//  BigNumber.swift
//  BigNumber
//
//  Created by Sylvan Martin on 8/31/19.
//  Copyright © 2019 Sylvan Martin. All rights reserved.
//

import Foundation

/// Convenience typealias
public typealias BN = BigNumber

/// A BigNumber object
///
/// An integer that has dynamically allocated memory
public struct BigNumber: CustomStringConvertible, ExpressibleByStringLiteral, ExpressibleByArrayLiteral, ExpressibleByIntegerLiteral, Comparable/*, BinaryInteger, UnsignedInteger*/ {
    
    
    // MARK: - Typealiases
    
    /// The element type in the ```BN``` array
    public typealias ArrayLiteralElement = UInt64
    
    /// The integer literal type
    public typealias IntegerLiteralType = Int
    
    /// Whether or not the BN should automatically optimize storage
    ///
    /// When set to ```true```, the BN will always get rid of leading zeros
    ///
    /// In order to prevent errors where someone may forget to enable this after disabling it, you cannot directly set this value. Instead, you can only
    /// get a copy of the BN with this value set to ```true``` or ```false```.
    ///
    /// It is very much **not** reccommended to do
    /// ```swift
    /// let a: BN = 0
    /// a = a.keepingLeadingZeros
    /// ```
    /// Instead, just store it to another variable
    private var shouldEraseLeadingZeros = true {
        didSet {
            if shouldEraseLeadingZeros {
                while array.last == 0 && array.count > 1 {
                    array.removeLast()
                }
            }
        }
    }
    
    public var erasingLeadingZeros: BigNumber {
        var a = self
        a.shouldEraseLeadingZeros = true
        return a
    }
    
    public var keepingLeadingZeros: BigNumber {
        var a = self
        a.shouldEraseLeadingZeros = false
        return a
    }
    
    // MARK: - Properties
    
    /// The array representation of the ```BN```, in Little-Endian format
    public var array: [UInt64] {
        // this automatically makes sure we are never using a larger array than we need
        // if the last UInt64 is 0, it removes it.
        didSet {
            if shouldEraseLeadingZeros {
                while array.last == 0 && array.count > 1 {
                    array.removeLast()
                }
            }
        }
    }
    
    /// Size of the array
    public var size: Int {
        return array.count
    }
    
    /// The size of the integer represented by the ```BN```, in bytes
    public var sizeInBytes: Int {
        return size * MemoryLayout<UInt64>.size
    }
    
    /// Size of the integer represented by the ```BN``` in bits
    public var sizeInBits: Int {
        return sizeInBytes * 8
    }
    
    /// Hex string representation of the ```BN```
    public var hexString: String {
        var string = ""
        let bnSizeCountdown = Array(1...array.count).reversed()
        for i in bnSizeCountdown {
            let uint64IndexCountdown = Array(1...16).reversed()
            for j in uint64IndexCountdown {
                string += toChar(self[i - 1] >> ((j - 1) * 4))
            }
        }
        
        // remove leading zeros
        while string.count > 1 && string.first == "0" {
            string.remove(at: string.startIndex)
        }
        
        return "0x" + string
    }
    
    /// Hex string description of the BN used when being printed
    public var description: String {
        return hexString
    }
    
    // MARK: - Initializers
    
    /// Creates a BN from an integer literal
    ///
    /// - Parameters:
    ///     - value: The value of the integer literal
    public init(integerLiteral value: Int) {
        assert(value >= 0, "Integer literal must be an unsigned integer")
        self = [UInt64(value)]
    }
    
    /// Creates a ```BN``` from an array literal
    ///
    /// - Parameters:
    ///     - elements: Array of type ```[UInt64]```
    public init(arrayLiteral elements: UInt64...) {
        array = elements
    }
    
    /// Creates a ```BN``` from a hexadecimal string
    ///
    /// - Parameters:
    ///     - hex: A value hexadecimal string
    public init(stringLiteral hex: String) {
        
        // sanitize the string, add leading zeros if necessary
        
        let sanatizedString = (hex.count >= 2) ? ((hex[1] == "x" || hex[1] == "X") ? String(hex.dropFirst(2)) : hex) : hex
        let arraySize = hex.count >= 16 ? sanatizedString.count / 16 : 1
        
        shouldEraseLeadingZeros = false
        array = [UInt64](repeating: 0, count: arraySize)
        
        for i in 0..<hex.count {
            let reversedSequence = (1..<array.count).reversed()
            
            for j in reversedSequence {
                self[j] <<= 4
                self[j] |= (self[j - 1] >> 60) & 0x0f
            }
            
            self[0] <<= 4
            self[0] |= UInt64(toNibble(hex[i]) & 0x0f)
        }
        shouldEraseLeadingZeros = true
    }
    
    /// Creates a BN from an array object
    ///
    /// - Parameters:
    ///     - array: The array object
    init(_ array: [UInt64]) {
        self.array = array
    }
    
    // MARK: - Subscripts
    
    /// References the array value at the given index
    subscript (index: Int) -> UInt64 {
        get {
            return array[index]
        }
        set {
            array[index] = newValue
        }
    }
    
    /// Returns the indexed item of the array, or nil if it does not exist
    subscript (safe index: Int) -> UInt64? {
        get {
            return (size >= index) ? self[index] : nil
        }
    }
    
    /// Returns the indexed item of the array, or 0 if it does not exist
    subscript (zeroing index: Int) -> UInt64 {
        get {
            return (size > index) ? self[index] : 0
        }
        set {
            if size <= index {
                array.append(newValue)
            } else {
                self[index] = newValue
            }
        }
    }
    
}
