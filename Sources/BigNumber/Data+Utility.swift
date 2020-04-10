//
//  Data+Utility.swift
//  
//
//  Created by Sylvan Martin on 4/10/20.
//

import Foundation

public extension Data {
    
    // MARK: - Properties
    
    /**
     * Returns the bytes of this `Data` object as a `UBigNumber`
     */
    var bytesAsLargeNumber: UBigNumber {
        UBigNumber(data: self)
    }
    
    // MARK: - Initializers
    
    /**
     * Creates a `Data` object from the bytes of a `UBigNumber`
     *
     * - Parameters:
     *      - ubn: The raw bytes of the data as a `UBigNumber`
     */
    init(bytes ubn: UBigNumber) {
        
        let byteArray = ubn.words.withUnsafeBytes {
            $0.bindMemory(to: UInt8.self)
        }
        
        self.init(buffer: byteArray)
        
    }
    
}
