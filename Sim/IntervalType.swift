//
//  IntervalType.swift
//  Sim
//
//  Created by Tobin Bell on 8/20/16.
//  Copyright © 2016 Tobin Bell. All rights reserved.
//

import Foundation

extension IntervalType {
    
    func clip(value: Bound) -> Bound {
        return min(max(value, start), end)
    }
    
}