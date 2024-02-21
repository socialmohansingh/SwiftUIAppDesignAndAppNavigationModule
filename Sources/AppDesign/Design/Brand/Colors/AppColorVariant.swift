//
//  File.swift
//  
//
//  Created by Mohan Singh Thagunna on 21/02/2024.
//

import Foundation
import SwiftUI

public protocol AppColor {
    var main: Color { get }
    
    func variant(_ variant: AppColorVariant) -> Color
    func custom(_ id: String) -> Color
}

extension AppColor {
    func variant(_ variant: AppColorVariant) -> Color {
        return main
    }
    func custom<T: RawRepresentable>(_ id: T) -> Color {
        return main
    }
}

public enum AppColorVariant {
    case v100
    case v200
    case v300
    case v400
    case v500
    case v600
    case v700
    case v800
    case v900
}
