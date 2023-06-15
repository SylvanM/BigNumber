//
//  File.swift
//  
//
//  Created by Sylvan Martin on 6/6/23.
//

import Foundation

public extension Rational {
    
    // MARK: Comparison Operators
    
    static func < (lhs: Rational, rhs: Rational) -> Bool {
        lhs.numerator * rhs.denominator < rhs.numerator * lhs.denominator
    }
    
    static func <= (lhs: Rational, rhs: Rational) -> Bool {
        lhs.numerator * rhs.denominator <= rhs.numerator * lhs.denominator
    }
    
    static func > (lhs: Rational, rhs: Rational) -> Bool {
        lhs.numerator * rhs.denominator > rhs.numerator * lhs.denominator
    }
    
    static func >= (lhs: Rational, rhs: Rational) -> Bool {
        lhs.numerator * rhs.denominator >= rhs.numerator * lhs.denominator
    }
    
    // MARK: Arithmetic Operators
    
    static prefix func - (rhs: Rational) -> Rational {
        Rational(numerator: -rhs.numerator, denominator: rhs.denominator)
    }
    
    static func * (lhs: Rational, rhs: Rational) -> Rational {
        Rational(
            numerator: lhs.numerator * rhs.numerator,
            denominator: lhs.denominator * rhs.denominator
        )
    }
    
    static func *= (lhs: inout Rational, rhs: Rational) {
        lhs.numerator *= rhs.numerator
        lhs.denominator *= rhs.denominator
        lhs.simplify()
    }
    
    static func + (lhs: Rational, rhs: Rational) -> Rational {
        Rational(
            numerator: lhs.numerator * rhs.denominator + lhs.denominator * rhs.numerator,
            denominator: lhs.denominator * rhs.denominator
        )
    }
    
    static func - (lhs: Rational, rhs: Rational) -> Rational {
        lhs + (-rhs)
    }
    
}
