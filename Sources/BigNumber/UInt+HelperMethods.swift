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
        
        (hi, lo) = a.multipliedFullWidth(by: b)
        
        // now do addition
        
        var add = lo.addingReportingOverflow(c)
        lo = add.partialValue
        
        if add.overflow {
            hi &+= 1
        }
        
        add = lo.addingReportingOverflow(d)
        lo = add.partialValue
        
        if add.overflow {
            hi &+= 1
        }
        
    }
    
}
