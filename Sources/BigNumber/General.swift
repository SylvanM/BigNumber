//
//  Utilities.swift
//  BigNumber
//
//  Created by Sylvan Martin on 8/31/19.
//  Copyright © 2019 Sylvan Martin. All rights reserved.
//

import Foundation

/// Converts an ASCII character to a nibble, or a 4 bit number
func toNibble(_ char: Character) -> UInt8 {
    let n = UInt64(char.asciiValue!)
    return  ((n >= 0x30) && (n <= 0x39)) ? UInt8(n - 0x30):
            ((n >= 0x41) && (n <= 0x46)) ? UInt8(n - 0x37):
            ((n >= 0x61) && (n <= 0x66)) ? UInt8(n - 0x57):
            0x10
}

/// Converts a nibble to an ASCII character
func toChar(_ nibble: UInt64) -> Character {
    var c: Character
    let n = 0x0f & nibble
    
    if 0 <= n && n < 10 {
        c = String(n)[0]
    } else {
        c = Character(UnicodeScalar(UInt8(65 + (n % 10))))
    }
    
    return c
}
