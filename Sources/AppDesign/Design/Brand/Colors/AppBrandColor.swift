//
//  File.swift
//  
//
//  Created by Mohan Singh Thagunna on 21/02/2024.
//

import Foundation
import SwiftUI

public protocol AppBrandColor {
    var primary: AppColor { get }
    var secondary: AppColor { get }
}

struct PrimaryColor: AppColor {
    var main: Color = Color.blue
    
    func variant(_ variant: AppColorVariant) -> Color {
        return main
    }
    
    func custom(_ id: String) -> Color {
        return main
    }
}

