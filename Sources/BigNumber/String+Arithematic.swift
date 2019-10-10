//
//  String+Addition.swift
//  BigNumber
//
//  Created by Sylvan Martin on 8/31/19.
//  Copyright © 2019 Sylvan Martin. All rights reserved.
//

import Foundation

public extension String {
    
    /// Adds a character and a string
    ///
    /// - Parameters:
    ///     - left: String
    ///     - right: Character
    ///
    /// - Returns: The string with the appended character
    static func +(left: String, right: Character) -> String {
        var newString = left
        newString.append(right)
        return newString
    }
    
    /// Adds a character to a given string, and assigns the new string to the original
    ///
    /// - Parameters:
    ///     - left: inout String
    ///     - right: Character
    ///
    /// - Returns: The string with the appended character
    @discardableResult static func +=(left: inout String, right: Character) -> String {
        left = left + right
        return left
    }
    
    /// Multiplies a string by an integer
    ///
    /// - Parameters:
    ///     - left: String
    ///     - right: Int
    static func * (left: String, right: Int) -> String {
        var s = ""
        for _ in 0..<right {
            s += left
        }
        return s
    }
    
}

