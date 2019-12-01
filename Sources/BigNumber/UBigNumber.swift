//
//  BigNumber.swift
//  BigNumber
//
//  Created by Sylvan Martin on 8/31/19.
//  Copyright © 2019 Sylvan Martin. All rights reserved.
//

import Foundation

/// Convenience typealias
public typealias UBN = UBigNumber

/// A BigNumber object
///
/// An unsigned integer type that has dynamically allocated memory
public struct UBigNumber: CustomStringConvertible, ExpressibleByStringLiteral, ExpressibleByArrayLiteral, ExpressibleByIntegerLiteral, UnsignedInteger, Hashable {
    
    /// I have no idea what this means in this context
    public var words: UInt64.Words {
        return UInt64.Words(array[0])
    }
    
    public typealias Words = UInt64.Words
    
    // MARK: - Typealiases
    
    /// The element type in the ```UBN``` array
    public typealias ArrayLiteralElement = UInt64
    
    /// The integer literal type
    public typealias IntegerLiteralType = Int
    
    public var erasingLeadingZeros: UBigNumber {
        var a = self
        a.shouldEraseLeadingZeros = true
        return a
    }
    
    public var keepingLeadingZeros: UBigNumber {
        var a = self
        a.shouldEraseLeadingZeros = false
        return a
    }
    
    // MARK: - Properties
    
    /// The array representation of the ```BN```, in Little-Endian format
    public var array: [UInt64] = [] {
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
        array.count
    }
    
    /// The size of the integer represented by the ```BN```, in bytes
    public var sizeInBytes: Int {
        size * MemoryLayout<UInt64>.size
    }
    
    /// Size of the integer represented by the ```BN``` in bits
    public var bitWidth: Int {
        sizeInBytes * 8
    }
    
    /// The amount of trailing zero bits
    public var trailingZeroBitCount: Int {
        var zeros = 0
        for i in 0..<array.count {
            zeros += array[i].trailingZeroBitCount
            if array[i].trailingZeroBitCount != 64 {
                break
            }
        }
        return zeros
    }
    
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
        
        return string
    }
    
    /// Binary string representation of thew ```BN```
    ///
    /// Leading zeros are not omitted
    public var binaryString: String {
        var string = ""
        for i in 0..<self.bitWidth {
            string = String(self[bit: i]) + string
        }
        return "0b" + string
    }
    
    /// Hex string representation of the ```BN```, with every 4 digits separated by a space
    public var formattedHexString: String {
        var string = hexString
        for i in (0..<hexString.count).reversed() {
            if (string.count - i) % 4 == 0 {
                string.insert(" ", at: .init(utf16Offset: i, in: string))
            }
        }
        return string
    }
    
    /// Hex string description of the BN used when being printed
    public var description: String {
        "0x" + hexString
    }
    
    // MARK: - Initializers
    
    /// Creates a new ```UBigNumber``` with the exact value of the passed ```BinaryFloatingPoint``` if it is representable. If not, this returns ```nil```
    ///
    /// - Parameters:
    ///     - source: Object conforming to ```BinaryFloatingPoint``` to convert to ```UBigNumber```
    ///
    /// - Returns: The exact value of ```source``` as a ```UBigNumber```, so long as ```source``` has no fractional component. If ```source``` has a fractional
    /// component, this returns ```nil```
    public init?<T>(exactly source: T) where T : BinaryFloatingPoint {
        
        if source < 0 {
            return nil
        }
        
        self.array = [UInt64(source)]
    }
    
    /// Creates a new ```UBigNumber``` with the integral component of whatever is passed into the initializer
    ///
    /// - Parameters:
    ///     - source: Object conforming to ```BinaryFloatingPoint``` to convert to ```UBigNumber```
    ///
    /// - Returns: The integral component of ```source``` as a ```UBigNumber```
    public init<T>(_ source: T) where T : BinaryFloatingPoint {
        self.array = [UInt64(source)]
    }
         
    /// Creates a new ```UBigNumber```, truncating or extending any bits as needed
    ///
    /// - Parameters:
    ///     - source: Object conforming to ```BinaryFloatingPoint``` to convert to ```UBigNumber```
    ///
    /// - Returns: ```source``` as a ```UBigNumber```
    public init<T>(truncatingIfNeeded source: T) where T : BinaryInteger {
        self.array = [UInt64(truncatingIfNeeded: source)]
    }
    
    /// Creates a new ```UBigNumber``` from a ```BinaryInteger```, clamping as needed
    ///
    /// This means that if ```source``` is less than 0, the ```UBIgNumber``` will be 0.
    ///
    /// - Parameters:
    ///     - source: Object conforming to ```BinaryInteger``` to convert to ```UBigNumber```
    ///
    /// - Returns: A ```UBigNumber``` with the value of ```source```, clamped to be within the range ```[0, ∞)```
    public init<T>(clamping source: T) where T : BinaryInteger {
        self.array = [UInt64(source)]
    }
    
    /// Creates a new ```UBigNumber```, truncating or extending any bits as needed
    ///
    /// - Parameters:
    ///     - source: Object conforming to ```BinaryInteger``` to convert to ```UBigNumber```
    ///
    /// - Returns: ```source``` as a ```UBigNumber```
    public init<T>(truncatingBits source: T) where T : BinaryInteger {
        self.array = [UInt64(source)]
    }
    
    /// Creates a new ```UBigNumber``` with the exact value of the passed ```BinaryFloatingPoint``` if it is representable. If not, this returns ```nil```
    ///
    /// - Parameters:
    ///     - source: Object conforming to ```BinaryFloatingPoint``` to convert to ```UBigNumber```
    ///
    /// - Returns: The exact value of ```source``` as a ```UBigNumber```, so long as ```source``` is greater than or equal to 0.
    public init?<T>(exactly source: T) where T : BinaryInteger {
        if source < 0 {
            return nil
        }
        self.array = [UInt64(source)]
    }

    /// Creates a new instance of ```UBigNumber``` from the given integer
    ///
    /// May result in a runtime error if ```source``` is not representable as a UBigNumber
    ///
    /// - Returns:
    public init<T>(_ source: T) where T : BinaryInteger {
        self.array = [UInt64(source)]
    }
    
    /// Creates a UBN from an integer literal
    ///
    /// - Parameters:
    ///     - value: The value of the integer literal
    public init(integerLiteral value: Int) {
        assert(value >= 0, "Integer literal must be an unsigned integer")
        self.init([UInt64(value)])
    }
    
    /// Creates a ```UBN``` from an array literal
    ///
    /// - Parameters:
    ///     - elements: Array of type ```[UInt64]```
    public init(arrayLiteral elements: UInt64...) {
        var arr = elements
        while arr.last == 0 && arr.count > 1 {
            arr.removeLast()
        }
        self.array = arr
    }
    
    /// Creates a ```UBN``` from a hexadecimal string
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
    
    /// Creates a UBN from an array object
    ///
    /// - Parameters:
    ///     - array: The array object
    init <T: BinaryInteger>(_ array: [T]) {
        self.array = array.map { UInt64($0) }
    }
    
    /// Creates a UBN with a given ```Int``` value
    ///
    /// - Parameters:
    ///     - integer: ```Int``` to be converted to a ```UBN```
    init(_ integer: Int) {
        self.array = [UInt64(integer)]
    }
    
    // MARK: - Methods
    
    /// Changes Whether or not the BN should automatically optimize storage
    ///
    /// When ```value``` is set to ```true```, the BN will always get rid of leading zeros
    ///
    /// In order to prevent errors where someone may forget to enable this after disabling it, you cannot directly set the ```shouldEraseLeadingZeros``` value. Instead, you can only
    /// get a copy of the BN with this value set to ```true``` or ```false```, or call this function.
    ///
    /// It is very much **not** reccommended to do
    /// ```swift
    /// let a: BN = 0
    /// a = a.keepingLeadingZeros
    /// ```
    /// or
    /// ```swift
    /// let a: BN = 0
    /// a.setShouldEraseLeadingZeros(to: false)
    /// ```
    /// Instead, just store it to another variable:
    /// ```swift
    /// let a: BN = 0
    /// let b = a.keepingLeadingZeros
    /// ```
    #warning("Erase this error flag eventually")
    @available(*, deprecated, message: "Note to myself so that I get a compiler warning wherever I use this function")
    mutating internal func setShouldEraseLeadingZeros(to value: Bool) {
        shouldEraseLeadingZeros = value
    }
    
    /// Hashes the ```UBigNumber```
    public func hash(into hasher: inout Hasher) {
        for element in array {
            hasher.combine(element)
        }
    }
    
    // MARK: - Subscripts
    
    /// References the array value at the given index
    subscript (index: Int) -> UInt64 {
        get {
            array[index]
        }
        set {
            array[index] = newValue
        }
    }
    
    /// References a bit with a specified index. No overflow handling will occur
    subscript (bit index: Int) -> UInt64 {
        get {
            // if the referenced bit is not actually in the array, just return 0
            (size * 64) - 1 > abs(index) ? (self >> index & UBN(1))[0] : 0
        }
        set {
            self &= ~(1 << index)
            self |= (newValue << index)
        }
    }
    
    /// References a bit with a specified index, with overflow handling.
    subscript (bitWithOverflowHandling index: Int) -> UInt64 {
        get {
            self[bit: index]
        }
        set {
            shouldEraseLeadingZeros = false
            
            for _ in 0..<((index / 8) + 1) {
                self.array.append(0x0)
            }
            
            self &= ~(1 << index)
            self |= (newValue << index)
            
            shouldEraseLeadingZeros = true
        }
    }
    
    /// Returns the indexed item of the array, or 0 if it does not exist
    subscript (safe index: Int) -> UInt64 {
        get {
            (size > index) ? self[index] : 0
        }
    }
    
    /// Returns the indexed item of the array, or 0 if it does not exist
    subscript (zeroing index: Int) -> UInt64 {
        get {
            (size > index) ? self[index] : 0
        }
        set {
            self.shouldEraseLeadingZeros = true
            
            while size <= index {
                array.append(0)
            }
            
            self[index] = newValue
            
            self.shouldEraseLeadingZeros = false
        }
    }
    
}
