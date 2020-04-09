//
//  String+Index.swift
//  BigNumber
//
//  Created by Sylvan Martin on 8/31/19.
//  Copyright © 2019 Sylvan Martin. All rights reserved.
//

import Foundation

internal extension String {
    
    // MARK: Subscripts
    
    /// References the ith character of a string
    subscript (i: Int) -> Character {
        self[index(startIndex, offsetBy: i)]
    }
    
}
