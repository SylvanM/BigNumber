//
//  Common Algorithms.swift
//
//  This file contains generic code that can be used with a signed or unsigned big number
//
//  Created by Sylvan Martin on 6/15/23.
//

import Foundation

/**
 * Finds the greatest common denominator of two bignumbers, signed or unsigned.
 *
 * This is for **internal use only** and is just so that I avoid code duplication
 */
internal func genericGcd<T: RawBNProtocol>(a: T, b: T) -> T {
    if a == 0 {
        if b == 0 {
            fatalError("gcd(0, 0) is undefined")
        }
        return b
    } else if b == 0 {
        if let abn = a as? BigNumber {
            // if T is a BigNumber, we need to make sure we are returning the absolute value.
            return abn.absoluteValue as! T
        } else {
            return a
        }
    }
    
    if a == 0 || b == 0 {
        return 1
    }
    
    return genericGcd(a: b, b: a % b)
}
