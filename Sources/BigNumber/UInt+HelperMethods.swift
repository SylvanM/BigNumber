//
//  File.swift
//  
//
//  Created by Sylvan Martin on 3/6/20.
//

import Foundation

public extension UInt {
    
    /// The size, in bytes, of this integery type
    @inlinable static var size: Int {
        MemoryLayout<UInt>.size
    }
    
    /// The size, in bits, of this integery type
    static var bitSize: Int {
        size * 8
    }
    
    /**
     * Computes the 128-bit result of the operation `a*b + c + d`
     *
     * This calls compiler intrinsic commands which just call processor instructions or whatever
     */
    static func addmul(lo: inout UInt, hi: inout UInt, a: UInt, b: UInt, c: UInt, d: UInt) {
        var overflow: Bool
        
        (lo, hi) = a.multipliedFullWidth(by: b)
        (lo, overflow) = lo.addingReportingOverflow(c)
        
        if overflow {
            hi &+= 1
        }
        
        (lo, overflow) = lo.addingReportingOverflow(d)
        
        if overflow {
            hi &+= 1
        }
        
    }
    
}
