//
//  File.swift
//  
//
//  Created by Mohan Singh Thagunna on 26/02/2024.
//

import Foundation

extension [Double] {
    public func nearestValue(target: Double) -> Double? {
        guard !self.isEmpty else { return nil }
        
        var closest = self[0]
        var minDifference = abs(target - closest)
        
        for value in self {
            let difference = abs(target - value)
            if difference < minDifference {
                minDifference = difference
                closest = value
            }
        }
        
        return closest
    }

}
