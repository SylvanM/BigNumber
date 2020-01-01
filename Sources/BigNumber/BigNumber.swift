//
//  File.swift
//
//
//  Created by Sylvan Martin on 12/10/19.
//

import Foundation

/// A signed ```BigNumber``` object
public typealias BN = BigNumber

/**
 * A signed integer of unfixed width
 */
public struct BigNumber: CustomStringConvertible, ExpressibleByStringLiteral, ExpressibleByArrayLiteral, ExpressibleByIntegerLiteral, SignedInteger, Hashable {

    // MARK: - Typealiases

    /// Word type of ```BigNumber```
    public typealias Words = UBigNumber.Words

    /// The element type of a ```BN``` array literal
    public typealias ArrayLiteralElement = UInt64

    /// The integer literal type
    public typealias IntegerLiteralType = Int64

    /// The magnitude type of a ```BigNumber```
    public typealias Magnitude = UBigNumber

    // MARK: - Public Properties

    /// The magnitude of this number as a ```UBigNumber```
    ///
    /// The default value of this is ```0```
    public var magnitude: Magnitude = 0 {
        didSet {
            if magnitude == 0 {
                sign = 0
            }
        }
    }

    /// Whether or not the number is positive
    ///
    /// Read only
    ///
    /// 1: Positive
    /// 0: Zero
    /// -1: Negative
    public var sign: Int = 0
    
    public var words: UBigNumber.Words {
        self.magnitude.words
    }
    
    public var bitWidth: Int {
        self.magnitude.bitWidth
    }
    
    public var trailingZeroBitCount: Int {
        self.magnitude.trailingZeroBitCount
    }

    // MARK: - Initializers

    /// Creates a new ```BigNumber``` with the exact value of the passed ```BinaryFloatingPoint``` if it is representable. If not, this returns ```nil```
    ///
    /// - Parameters:
    ///     - source: Object conforming to ```BinaryFloatingPoint``` to convert to ```BigNumber```
    ///
    /// - Returns: The exact value of ```source``` as a ```BigNumber```, so long as ```source``` has no fractional component. If ```source``` has a fractional
    /// component, this returns ```nil```
    public init?<T>(exactly source: T) where T : BinaryFloatingPoint {
        self.sign = source.sign.rawValue == 1 ? -1 : 1
        guard let magnitude = BigNumber.Magnitude(exactly: source.magnitude) else { return nil }
        self.magnitude = magnitude
    }

    /// Creates a new ```BigNumber``` with the integral component of whatever is passed into the initializer
    ///
    /// - Parameters:
    ///     - source: Object conforming to ```BinaryFloatingPoint``` to convert to ```UBigNumber```
    ///
    /// - Returns: The integral component of ```source``` as a ```UBigNumber```
    public init<T>(_ source: T) where T : BinaryFloatingPoint {
        self.sign = source.sign.rawValue == 1 ? -1 : 1
        self.magnitude = UBigNumber(source.magnitude)
    }

    /// Creates a new ```UBigNumber```, truncating or extending any bits as needed
    ///
    /// - Parameters:
    ///     - source: Object conforming to ```BinaryFloatingPoint``` to convert to ```UBigNumber```
    ///
    /// - Returns: ```source``` as a ```UBigNumber```
    public init<T>(truncatingIfNeeded source: T) where T : BinaryInteger {
        self.sign = source < 0 ? -1 : 1
        self.magnitude = UBigNumber(truncatingIfNeeded: source.magnitude)
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
       self.sign = source < 0 ? -1 : 1
        self.magnitude = UBigNumber(clamping: source.magnitude)
    }

    /// Creates a new ```UBigNumber```, truncating or extending any bits as needed
    ///
    /// - Parameters:
    ///     - source: Object conforming to ```BinaryInteger``` to convert to ```UBigNumber```
    ///
    /// - Returns: ```source``` as a ```UBigNumber```
    public init<T>(truncatingBits source: T) where T : BinaryInteger {
        self.sign = source < 0 ? -1 : 1
        self.magnitude = UBigNumber(truncatingBits: source.magnitude)
    }

    /// Creates a new ```UBigNumber``` with the exact value of the passed ```BinaryFloatingPoint``` if it is representable. If not, this returns ```nil```
    ///
    /// - Parameters:
    ///     - source: Object conforming to ```BinaryFloatingPoint``` to convert to ```UBigNumber```
    ///
    /// - Returns: The exact value of ```source``` as a ```UBigNumber```, so long as ```source``` is greater than or equal to 0.
    public init?<T>(exactly source: T) where T : BinaryInteger {
        self.sign = source < 0 ? -1 : 1
        guard let magnitude = BigNumber.Magnitude(exactly: source.magnitude) else { return nil }
        self.magnitude = magnitude
    }

    /// Creates a new instance of ```UBigNumber``` from the given integer
    ///
    /// May result in a runtime error if ```source``` is not representable as a UBigNumber
    ///
    /// - Returns:
    public init<T>(_ source: T) where T : BinaryInteger {
        self.sign = source < 0 ? -1 : 1
        self.magnitude = UBigNumber(source.magnitude)
    }

    /// Creates a UBN from an integer literal
    ///
    /// - Parameters:
    ///     - value: The value of the integer literal
    public init(integerLiteral value: Int64) {
        self.sign = value < 0 ? -1 : 1
        self.magnitude = BigNumber.Magnitude(value.magnitude)
    }

    /// Creates a positive ```BN``` from an array literal
    ///
    /// - Parameters:
    ///     - elements: Array of type ```[UInt64]```
    public init(arrayLiteral elements: UInt64...) {
        self.sign = 1
        var arr = elements
        while arr.last == 0 && arr.count > 1 {
            arr.removeLast()
        }
        self.magnitude = BigNumber.Magnitude(arr)
    }

    /// Creates a ```BN``` from a hexadecimal string
    ///
    /// Can be negative if the string begins with a ```-``` character
    ///
    /// - Parameters:
    ///     - hex: A value hexadecimal string
    public init(stringLiteral hex: String) {

        // sanitize the string, add leading zeros if necessary
        let isNegative = hex[0] == "-"

        var sanatizedString = hex

        if isNegative {
            sanatizedString.removeFirst()
        }

        self.magnitude = UBN(stringLiteral: sanatizedString)

        // change the sign if needed
        if self.magnitude != 0 {
            self.sign = isNegative ? -1 : 1
        }

        self.magnitude.setShouldEraseLeadingZeros(to: true)
    }

    /// Creates a UBN from an array object
    ///
    /// - Parameters:
    ///     - array: The array object
    init <T: BinaryInteger>(_ array: [T]) {
        self.magnitude.array = array.map { UInt64($0) }
    }

    /// Creates a UBN with a given ```Int``` value
    ///
    /// - Parameters:
    ///     - integer: ```Int``` to be converted to a ```UBN```
    init(_ integer: Int) {
        self.magnitude.array = [UInt64(integer)]
    }

    // MARK: - Subscripts

    /// References the array value at the given index
    subscript (index: Int) -> UInt64 {
        get {
            self.magnitude.array[index]
        }
        set {
            self.magnitude.array[index] = newValue
        }
    }

}
